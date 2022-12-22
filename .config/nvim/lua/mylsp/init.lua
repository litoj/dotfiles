vim.diagnostic.config {
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { focusable = false, border = 'rounded', source = 'always' },
}
vim.lsp.handlers['textDocument/hover'] =
	vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
vim.lsp.handlers['textDocument/signatureHelp'] =
	vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' })
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
			vim.lsp.inlay_hint(bufnr, true)
		end
		vim.api.nvim_set_current_dir(client.config.root_dir)
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
map('n', 'gd', vim.lsp.buf.definition)
map('n', 'gr', vim.lsp.buf.references)
map('n', 'gI', vim.lsp.buf.implementation)
map({ 'n', 'i' }, '<M-i>', vim.lsp.buf.hover)
map({ 'n', 'i' }, '<C-I>', vim.lsp.buf.document_highlight)
map({ 'n', 'i' }, '<C-S-I>', vim.lsp.buf.clear_references)
map({ 'n', 'i' }, '<C-S-Space>', vim.lsp.buf.signature_help)
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
