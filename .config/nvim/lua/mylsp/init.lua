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

for k, v in pairs { Error = '', Warn = '', Hint = '', Info = '' } do
	k = 'DiagnosticSign' .. k
	vim.fn.sign_define(k, { texthl = k, text = v, numhl = k })
end

local lsc = require 'lspconfig'
local lsu = require 'lspconfig.util'

lsu.default_config.capabilities = vim.tbl_deep_extend(
	'force',
	lsu.default_config.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
	-- ../plugins/ufo.lua
	-- { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
)

lsu.on_setup = lsu.add_hook_before(lsu.on_setup, function(opts)
	opts.on_attach = lsu.add_hook_before(opts.on_attach, function(client, bufnr)
		vim.bo.formatoptions = 'tcqjl1'
		-- custom settings for dynamic capability override
		if client.server_capabilities.documentFormattingProvider then
			client.server_capabilities.documentFormattingProvider = opts.format ~= false
		end
		if client.server_capabilities.inlayHintProvider and opts.inlay then
			vim.lsp.inlay_hint.enable(bufnr, true)
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
	end)
end)

local function setup(server, opts)
	if server and lsc[server].autostart ~= nil then return end
	opts = opts or require('mylsp.' .. server)
	return server and lsc[server].setup(opts) or opts
end
M.setup = setup

setup('bashls', { root_dir = function(fname) return fname:match '.+/' end })
setup('pyright', {})
setup 'volar'
-- setup("cssls", {cmd = {"vscode-css-language-server", "--stdio"}})
-- setup("html", {cmd = {"vscode-html-language-server", "--stdio"}, format = true})
setup 'jsonls'
-- setup("yamlls", {})

-- Lsp diagnostic
map({ 'n', 'i' }, '<A-d>', vim.diagnostic.open_float)
map('n', '[d', vim.diagnostic.goto_prev)
map('n', ']d', vim.diagnostic.goto_next)
-- Lsp code helpers
map('n', 'gD', vim.lsp.buf.declaration)
map('n', 'gt', vim.lsp.buf.type_definition)
-- gd,gr in ../plugins/fzf.lua
map('n', 'gI', vim.lsp.buf.implementation)
map({ 'n', 'i' }, '<A-i>', vim.lsp.buf.hover)
map(
	{ 'n', 'i' },
	'<A-I>',
	function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end
)
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
