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

---@param server? string
---@param opts? string|vim.lsp.Config|{setCwd:boolean, format:boolean}
local function setup(server, opts)
	opts = type(opts) == 'table' and opts or require('mylsp.' .. (opts or server))

	local on_attach = opts.on_attach
	opts.on_attach = function(client, bufnr)
		vim.bo.formatoptions = 'tcqjl1'
		-- custom settings for dynamic capability override
		if client.server_capabilities.documentFormattingProvider then
			client.server_capabilities.documentFormattingProvider = opts.format ~= false
		end
		if opts.setCwd ~= false then
			local bname = vim.api.nvim_buf_get_name(bufnr)
			for _, ws in ipairs(client.config.workspace_folders or { { name = client.root_dir } }) do
				---@diagnostic disable-next-line: cast-local-type
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

	if not server then return opts end

	if opts.root_markers then
		vim.list_extend(opts.root_markers, vim.lsp.config[server].root_markers or {})
	end
	opts = vim.tbl_deep_extend('keep', opts, vim.lsp.config[server])

	vim.lsp.config(server, opts)
	vim.lsp.enable(server)
	return opts
end
M.setup = setup

setup 'bashls'
setup 'vue_ls'
-- setup("cssls", {cmd = {"vscode-css-language-server", "--stdio"}})
-- setup("html", {cmd = {"vscode-html-language-server", "--stdio"}, format = true})
-- setup 'jsonls'
-- setup("yamlls", {})

-- Lsp diagnostic
map('n', '<A-d>', vim.diagnostic.open_float)
map('i', '<A-d><A-d>', vim.diagnostic.open_float)
map('n', '[d', function() vim.diagnostic.jump { count = -1, float = true } end)
map('n', ']d', function() vim.diagnostic.jump { count = 1, float = true } end)

-- Remove default mappings to give space for `gr` as direct references
vim.keymap.del('', 'gra')
vim.keymap.del('', 'grn')
vim.keymap.del('', 'gri')
vim.keymap.del('', 'grt')
vim.keymap.del('', 'grr')

map('n', 'gt', vim.lsp.buf.type_definition)
-- wrapped to use fzf implementation
map('n', 'gD', function() vim.lsp.buf.declaration() end)
map('n', 'gd', function() vim.lsp.buf.definition() end)
map('n', 'gr', function() vim.lsp.buf.references() end)
map({ 'n', 'i' }, '<A-S-C>', vim.lsp.codelens.refresh)
map({ 'n', 'i' }, '<A-i>', function() vim.lsp.buf.hover { border = 'rounded' } end)
map('i', '<A-S-I>', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
map({ 'n', 'i' }, '<C-m>', vim.lsp.buf.document_highlight)
map({ 'n', 'i' }, '<C-S-M>', vim.lsp.buf.clear_references)
map({ 'n', 'i' }, '<A-c>', vim.lsp.buf.code_action)
map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename)
map({ 'n', 'i' }, '<C-r>', vim.lsp.buf.rename)
map(
	{ 'n', 'i' },
	'<A-S-F>',
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
