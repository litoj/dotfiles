local M = {}
vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = { focusable = false, border = 'rounded', source = 'if_many' },
}
vim.lsp.handlers['textDocument/hover'] =
	vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

-- buf, win, cur_row, cur_col, previous_label, active_parameter
local b, w, cr, cc, pl, ap, ac = 0, -1, 0, 0, '', -1, -1
local function winValid(close)
	if w < 0 or not vim.api.nvim_win_is_valid(w) then return end
	local s = vim.api.nvim_win_get_position(w)[1] + vim.fn.line 'w0' - 1 -- adjust by window scroll
	local e = vim.api.nvim_win_get_height(w) + s + 1
	local c = vim.api.nvim_win_get_cursor(0)
	-- Δ5 lines, Δ20 horizontal
	local ok = (c[1] < s or e < c[1]) -- cursor outside window
		and (cr - 5 < c[1] and c[1] < cr + 5)
		and (cc - 20 < c[2] and c[2] < cc + 20)
	if not ok or close then
		pl = ''
		vim.api.nvim_win_close(w, false)
		w = -1
	end
	return ok, c
end
local showSig = true
vim.lsp.handlers['textDocument/signatureHelp'] = function(_, sig, ctx, config)
	-- Ignore result since buffer changed. This happens for slow language servers.
	if vim.api.nvim_get_current_buf() ~= ctx.bufnr then return end
	local noSig = not (sig and sig.signatures and sig.signatures[1])
	local update, c = winValid()
	c = c or vim.api.nvim_win_get_cursor(0)
	if noSig or vim.api.nvim_get_mode().mode ~= 'i' then return end

	-- ensure update on change only
	local s = sig.signatures[(sig.activeSignature or 0) + 1]
	local newAp = s.activeParameter or sig.activeParameter or -1
	if update and pl == s.label and ap == newAp and ac == sig.activeSignature then return end
	pl, ap, ac = s.label, newAp, sig.activeSignature

	local lines, hl =
		vim.lsp.util.convert_signature_help_to_markdown_lines(sig, vim.bo[ctx.bufnr].filetype, {})
	if not lines or #lines == 0 then return end
	if update then
		vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
	else
		config = config or {}
		config.max_height = config.max_height or math.floor(vim.api.nvim_win_get_height(0) * 0.3)
		config.border = 'rounded'
		config.focus_id = ctx.method
		config.close_events = { 'BufLeave', 'ModeChanged', 'WinScrolled' }
		b, w = vim.lsp.util.open_floating_preview(lines, 'markdown', config)
		cr = c[1]
		cc = c[2]
		vim.bo[b].modifiable = true
	end
	if hl then vim.api.nvim_buf_add_highlight(b, -1, 'LspSignatureActiveParameter', 1, unpack(hl)) end
	return b, w
end

for k, v in pairs { Error = '', Warn = '', Hint = '', Info = '' } do
	k = 'DiagnosticSign' .. k
	vim.fn.sign_define(k, { texthl = k, text = v, numhl = k })
end

local lsc = require 'lspconfig'

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local function setup(server, opts)
	opts = opts or require('mylsp.' .. server)
	local on_attach = opts.on_attach
	opts.on_attach = function(client, bufnr)
		vim.bo.formatoptions = 'tcqjl1'
		client.server_capabilities.documentFormattingProvider = opts.format == true
		--[[ if client.server_capabilities.inlayHintProvider and opts.inlay then
			vim.lsp.inlay_hint.enable(bufnr, true)
		end ]]
		if opts.setCwd ~= false then
			local bname = vim.api.nvim_buf_get_name(bufnr)
			for _, ws in ipairs(client.config.workspace_folders) do
				ws = ws.name
				if ws and bname:sub(1, #ws) == ws then
					vim.b[bufnr].cwd = ws
					vim.api.nvim_set_current_dir(ws)
					break
				end
			end
		end
		if client.server_capabilities.signatureHelpProvider then
			vim.api.nvim_create_autocmd({ 'CursorHoldI', 'CompleteDone', 'CursorMovedI' }, {
				callback = function(state)
					if state.event == 'CursorMovedI' then
						-- TODO: base detection of context change off of treesitter
						winValid()
						return
					end
					if showSig then vim.lsp.buf.signature_help() end
				end,
				buffer = bufnr,
			})
		end
		if on_attach then on_attach(client, bufnr) end
	end
	return server and lsc[server].setup(opts) or opts
end
M.setup = setup

setup('bashls', { root_dir = function(fname) return fname:match '.+/' end })
setup 'clangd'
setup('pyright', {})
setup('rust_analyzer', {})
setup 'texlab'
-- setup("cssls", {cmd = {"vscode-css-language-server", "--stdio"}})
-- setup("html", {cmd = {"vscode-html-language-server", "--stdio"}, format = true})
-- setup "jsonls"
-- setup("yamlls", {})

map('i', '<A-g>', '<C-o>g', { remap = true })
map('i', '<A-[>', '<C-o>[', { remap = true })
map('i', '<A-]>', '<C-o>]', { remap = true })
map('i', '<A->>', '<C-o>>', { remap = true })
map('i', '<A-<>', '<C-o><', { remap = true })
-- Lsp diagnostic
map({ 'n', 'i' }, '<A-d>', vim.diagnostic.open_float)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
-- Lsp code helpers
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'gt', vim.lsp.buf.type_definition)
-- gd,gr in plugins.fzf
map('n', 'gI', vim.lsp.buf.implementation)
map({ 'n', 'i' }, '<A-i>', vim.lsp.buf.hover)
map({ 'n', 'i' }, '<C-I>', vim.lsp.buf.document_highlight)
map({ 'n', 'i' }, '<C-S-I>', vim.lsp.buf.clear_references)
map('i', '<C-S-Space>', function()
	if vim.api.nvim_win_is_valid(w) == showSig then
		if showSig then
			vim.api.nvim_win_close(w, false)
			w = -1
		else
			vim.lsp.buf.signature_help()
		end
	else
		showSig = not showSig
		vim.print('show signature: ' .. tostring(showSig))
	end
end)
map({ 'n', 'i' }, '<A-c>', vim.lsp.buf.code_action)
map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)
map(
	{ 'n', 'i' },
	'<A-F>',
	function()
		vim.lsp.buf.format {
			tabSize = vim.bo.tabstop,
			insertSpaces = vim.bo.expandtab,
			trimTrailingWhitespace = true,
			insertFinalNewline = false,
			async = true,
		}
	end
)

return M
