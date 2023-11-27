vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { focusable = false, border = 'rounded', source = 'if_many' },
}
vim.lsp.handlers['textDocument/hover'] =
	vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

-- buf, win, cursor_row, cursor_col, previous_label, active_parameter
local b, w, cr, cc, pl, ap, ac = 0, -1, 0, 0, '', -1, -1
vim.lsp.handlers['textDocument/signatureHelp'] = function(_, sig, ctx, config)
	-- Ignore result since buffer changed. This happens for slow language servers.
	if vim.api.nvim_get_current_buf() ~= ctx.bufnr then return end
	local c, v = vim.api.nvim_win_get_cursor(0), vim.api.nvim_win_is_valid(w)
	local update = v and c[1] == cr and cc - 20 < c[2] and c[2] < cc + 20
	local noSig = not (sig and sig.signatures and sig.signatures[1])
	if v and (not update or noSig) then
		pl = ''
		vim.api.nvim_win_close(w, false)
	end
	if noSig or vim.api.nvim_get_mode().mode ~= 'i' then return end

	-- ensure update on change only
	local s = sig.signatures[(sig.activeSignature or -1) + 1] or sig.signatures[1]
	local newAp = s.activeParameter or sig.activeParameter or -1
	if v and pl == s.label and ap == newAp and ac == sig.activeSignature then return end
	pl, ap, ac = s.label, newAp, sig.activeSignature

	local lines, hl =
		vim.lsp.util.convert_signature_help_to_markdown_lines(sig, vim.bo[ctx.bufnr].filetype)
	if not lines or #lines == 0 then return end
	if update then
		vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)
	else
		config = config or {}
		config.border = 'rounded'
		config.focus_id = ctx.method
		config.close_events = { 'BufLeave', 'ModeChanged', 'WinScrolled' }
		b, w = vim.lsp.util.open_floating_preview(lines, 'markdown', config)
		vim.bo[b].modifiable = true
		cr, cc = c[1], c[2]
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
-- Ufo
capabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
lsc.util.default_config.capabilities =
	vim.tbl_deep_extend('force', lsc.util.default_config.capabilities, capabilities)

local function setup(server, opts)
	if not opts then opts = require('mylsp.' .. server) end
	local on_attach = opts.on_attach
	opts.on_attach = function(client, bufnr)
		vim.bo.formatoptions = 'tcqjl1'
		client.server_capabilities.documentFormattingProvider = opts.format == true
		if client.server_capabilities.inlayHintProvider and opts.inlay then
			vim.lsp.inlay_hint.enable(bufnr, true)
		end
		if client.config.root_dir then vim.api.nvim_set_current_dir(client.config.root_dir) end
		if client.server_capabilities.signatureHelpProvider then
			vim.api.nvim_create_autocmd({ 'CursorHoldI', 'CompleteDone' }, {
				callback = function()
					if b ~= -1 then vim.lsp.buf.signature_help() end
				end,
				buffer = bufnr,
			})
		end
		if on_attach then on_attach(client, bufnr) end
	end
	if not server then
		return opts
	else
		lsc[server].setup(opts)
	end
end

setup('bashls', { root_dir = function(fname) return fname:match '.+/' end })
setup 'clangd'
setup('pyright', {})
setup('rust_analyzer', {})
setup 'texlab'
-- setup("cssls", {cmd = {"vscode-css-language-server", "--stdio"}})
-- setup("html", {cmd = {"vscode-html-language-server", "--stdio"}, format = true})
-- setup "jsonls"
-- setup("yamlls", {})

map('i', '<M-g>', '<C-o>g', { remap = true })
map('i', '<M-[>', '<C-o>[', { remap = true })
map('i', '<M-]>', '<C-o>]', { remap = true })
map('i', '<M->>', '<C-o>>', { remap = true })
map('i', '<M-<>', '<C-o><', { remap = true })
-- Lsp diagnostic
map({ 'n', 'i' }, '<M-d>', vim.diagnostic.open_float)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
-- Lsp code helpers
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'gt', vim.lsp.buf.type_definition)
-- gd,gr in plugins.fzf
map('n', 'gI', vim.lsp.buf.implementation)
map({ 'n', 'i' }, '<M-i>', vim.lsp.buf.hover)
map({ 'n', 'i' }, '<C-I>', vim.lsp.buf.document_highlight)
map({ 'n', 'i' }, '<C-S-I>', vim.lsp.buf.clear_references)
map('i', '<C-S-Space>', function()
	if vim.api.nvim_win_is_valid(w) then
		b = -1
		vim.api.nvim_win_close(w, false)
	else
		vim.lsp.buf.signature_help()
	end
end)
map({ 'n', 'i' }, '<M-c>', vim.lsp.buf.code_action)
map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)
map(
	{ 'n', 'i' },
	'<M-F>',
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

return setup
