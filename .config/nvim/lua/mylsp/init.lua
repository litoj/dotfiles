local M = {}
vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = true,
	severity_sort = true,
	float = { focusable = false, border = 'rounded', source = 'if_many' },
}
vim.diagnostic.config {
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = '',
			[vim.diagnostic.severity.WARN] = '',
			[vim.diagnostic.severity.HINT] = '',
			[vim.diagnostic.severity.INFO] = '',
		},
	},
}

vim.lsp.config(
	'*',
	{ capabilities = require('cmp_nvim_lsp').default_capabilities() }
	-- ../plugins/ufo.lua
	-- { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
)

local function setup(server, opts)
	opts = type(opts) == 'table' and opts or require('mylsp.' .. (opts or server))
	if not server then return opts end

	local on_attach = opts.on_attach
	opts.on_attach = function(client, bufnr)
		vim.bo.formatoptions = 'tcqjl1'
		-- custom settings for dynamic capability override
		if client.server_capabilities.documentFormattingProvider then
			client.server_capabilities.documentFormattingProvider = opts.format ~= false
		end
		if opts.setCwd ~= false then
			local bname = vim.api.nvim_buf_get_name(bufnr)
			for _, ws in ipairs(client.config.workspace_folders or {}) do
				ws = ws.name
				if ws and bname:sub(1, #ws) == ws then
					vim.b[bufnr].cwd = ws
					vim.api.nvim_set_current_dir(ws)
					break
				end
			end
		end

		if on_attach then on_attach(client, bufnr) end
	end

	vim.lsp.config(server, opts)
	vim.lsp.enable(server)
	return opts
end
M.setup = setup

setup 'bashls'
setup 'pyright'
setup 'vue_ls'
-- setup("cssls", {cmd = {"vscode-css-language-server", "--stdio"}})
-- setup("html", {cmd = {"vscode-html-language-server", "--stdio"}, format = true})
-- setup 'jsonls'
-- setup("yamlls", {})

-- Lsp diagnostic
map('n', '<A-d>', vim.diagnostic.open_float)
map('i', '<A-d>s', vim.diagnostic.open_float)
map('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end)
map('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end)
-- Lsp code helpers gd,gr... in ../plugins/fzf.lua
map('n', 'gt', vim.lsp.buf.type_definition)
map('n', 'gr', function() vim.lsp.buf.references() end)
map({ 'n', 'i' }, '<A-i>', function() vim.lsp.buf.hover { border = 'rounded' } end)
map('i', '<A-I>', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
map({ 'n', 'i' }, '<C-i>', vim.lsp.buf.document_highlight)
map({ 'n', 'i' }, '<C-S-I>', vim.lsp.buf.clear_references)
map({ 'n', 'i' }, '<A-c>', vim.lsp.buf.code_action)
map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)
map({ 'n', 'i' }, '<C-r>', vim.lsp.buf.rename)
map(
	{ 'n', 'i' },
	'<A-F>',
	function()
		vim.lsp.buf.format {
			tabSize = vim.bo.tabstop,
			insertSpaces = vim.bo.expandtab,
			trimTrailingWhitespace = true,
			insertFinalNewline = true,
			async = true,
		}
	end
)

return M
