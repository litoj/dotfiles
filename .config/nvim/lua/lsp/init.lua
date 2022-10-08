function _G.lsp_setup(server, opts)
	opts.handlers = {
		["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = true,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		}),
		["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {border = "rounded"}),
	}
	local on_attach = opts.on_attach
	if not opts.capabilities then opts.capabilities = capabilities end
	opts.on_attach = function(client, bufnr)
		if on_attach then on_attach(client, bufnr) end
		if opts.folding then require'folding'.on_attach() end
		client.server_capabilities.documentFormattingProvider = (opts.settings and
				                                                        opts.settings.documentFormatting)
		vim.cmd "setlocal formatoptions-=cro"
		if client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_augroup("lsp_document_highlight", {clear = true})
			vim.api.nvim_clear_autocmds {buffer = bufnr, group = "lsp_document_highlight"}
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = vim.lsp.buf.document_highlight,
				buffer = bufnr,
				group = "lsp_document_highlight",
			})
			vim.api.nvim_create_autocmd("CursorMoved", {
				callback = vim.lsp.buf.clear_references,
				buffer = bufnr,
				group = "lsp_document_highlight",
			})
			vim.opt_local.signcolumn = "yes"
		end
	end
	require'lspconfig'[server].setup(opts)
end

vim.fn.sign_define("DiagnosticSignError",
		{texthl = "DiagnosticError", text = "", numhl = "DiagnosticError"})
vim.fn.sign_define("DiagnosticSignWarn",
		{texthl = "DiagnosticWarn", text = "", numhl = "DiagnosticWarn"})
vim.fn.sign_define("DiagnosticSignHint",
		{texthl = "DiagnosticHint", text = "", numhl = "DiagnosticHint"})
vim.fn.sign_define("DiagnosticSignInfo",
		{texthl = "DiagnosticInfo", text = "", numhl = "DiagnosticInfo"})

lsp_setup("bashls", {})
lsp_setup("clangd", {capabilities = {offsetEncoding = 'utf-16'}})
-- require "lsp.go-ls"
require "lsp.js-ts-ls"
-- lsp_setup("texlab", {})
require "lsp.tex-ls"
require "lsp.lua-ls"
lsp_setup("pyright", {})
lsp_setup("rust_analyzer", {settings = {documentFormatting = true}})
-- require "lsp.tailwindcss-ls"
require "lsp.vscode-ls"
lsp_setup("yamlls", {})

-- LSP general code actions
nmap({"n", "i"}, "<M-g>", function()
	for _, s in ipairs(vim.lsp.get_active_clients()) do
		if s.server_capabilities.definitionProvider and s.name ~= "bashls" then
			vim.lsp.buf.definition()
			return
		end
	end
	local cur = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local cwd = vim.loop.cwd()
	vim.loop.chdir(vim.api.nvim_buf_get_name(0):gsub("[^/]*$", ""))
	local path = line:sub(0, cur):gsub("^.*[^a-zA-Z0-9/.~_-]", "") ..
			             line:sub(cur + 1, -1):gsub("[^a-zA-Z0-9/.~_-].*$", "")
	vim.cmd('e ' .. path:gsub('~', os.getenv('HOME')))
	vim.loop.chdir(cwd)
end)
nmap("n", "gD", vim.lsp.buf.declaration)
nmap("n", "gd", vim.lsp.buf.definition)
nmap("n", "gr", vim.lsp.buf.references)
nmap("n", "gi", vim.lsp.buf.implementation)
nmap({"n", "i"}, "<C-r>", vim.lsp.buf.rename)
nmap("n", "<F2>", "<Cmd>Lspsaga rename<CR>")
nmap("i", "<F2>", "<C-o><Cmd>Lspsaga rename<CR>")
nmap({"n", "i"}, "<M-i>", vim.lsp.buf.hover)
nmap({"n", "i"}, "<M-s>", "<Cmd>Lspsaga signature_help<CR>")
nmap("i", "<C-S-Space>", "<Cmd>Lspsaga signature_help<CR>")
-- Lsp diagnostic
nmap({"n", "i"}, "<M-d>", "<Cmd>Lspsaga show_line_diagnostics<CR>")
nmap({"n", "i"}, "<M-S-N>", "<Cmd>Lspsaga diagnostic_jump_prev<CR>")
nmap({"n", "i"}, "<M-n>", "<Cmd>Lspsaga diagnostic_jump_next<CR>")
-- Lspsaga
nmap("n", "ca", "<Cmd>Lspsaga code_action<CR>")
nmap("i", "<M-S>", "<Esc><Cmd>Lspsaga code_action<CR>")
nmap({"n", "i"}, "<M-f>", "<Cmd>Lspsaga lsp_finder<CR>")
nmap({"n", "i"}, "<M-I>", "<Cmd>Lspsaga preview_definition<CR>")

nmap({"n", "i"}, "<M-F>", function()
	vim.lsp.buf.format({
		tabSize = vim.o.tabstop,
		insertSpaces = vim.o.expandtab,
		trimTrailingWhitespace = true,
		insertFinalNewline = false,
		async = true,
	})
end)
