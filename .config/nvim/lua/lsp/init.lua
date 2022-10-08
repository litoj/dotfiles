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

function _G.format_code()
	vim.lsp.buf.format({
		tabSize = vim.o.tabstop,
		insertSpaces = vim.o.expandtab,
		trimTrailingWhitespace = true,
		insertFinalNewline = false,
		async = true,
	})
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
local clangd_capabilities = require'cmp_nvim_lsp'.update_capabilities(vim.lsp.protocol
		                                                                      .make_client_capabilities())
clangd_capabilities.offsetEncoding = 'utf-16'
clangd_capabilities.textDocument = {completion = {editsNearCursor = true}}
lsp_setup("clangd", {capabilities = clangd_capabilities})
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
nmap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")
nmap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
nmap("i", "<M-g>", "<Cmd>lua vim.lsp.buf.definition()<CR>")
nmap("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>")
nmap("n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>")
nmap("n", "<C-r>", "<Cmd>lua vim.lsp.buf.rename()<CR>")
nmap("i", "<C-r>", "<C-o><Cmd>lua vim.lsp.buf.rename()<CR>")
nmap("n", "<F2>", "<Cmd>Lspsaga rename<CR>")
nmap("i", "<F2>", "<C-o><Cmd>Lspsaga rename<CR>")
nmap("n", "<M-i>", "<Cmd>lua vim.lsp.buf.hover()<CR>")
nmap("i", "<M-i>", "<Cmd>lua vim.lsp.buf.hover()<CR>")
nmap("n", "<M-s>", "<Cmd>Lspsaga signature_help<CR>")
nmap("i", "<M-s>", "<Cmd>Lspsaga signature_help<CR>")
nmap("i", "<C-S-Space>", "<Cmd>Lspsaga signature_help<CR>")
-- Lsp diagnostic
nmap("n", "<M-d>", "<Cmd>Lspsaga show_line_diagnostics<CR>")
nmap("i", "<M-d>", "<Cmd>Lspsaga show_line_diagnostics<CR>")
nmap("n", "<M-S-N>", "<Cmd>Lspsaga diagnostic_jump_prev<CR>")
nmap("i", "<M-S-N>", "<Cmd>Lspsaga diagnostic_jump_prev<CR>")
nmap("n", "<M-n>", "<Cmd>Lspsaga diagnostic_jump_next<CR>")
nmap("i", "<M-n>", "<Cmd>Lspsaga diagnostic_jump_next<CR>")
-- Lspsaga
nmap("n", "ca", "<Cmd>Lspsaga code_action<CR>")
nmap("i", "<M-S>", "<Esc><Cmd>Lspsaga code_action<CR>")
nmap("n", "<M-f>", "<Cmd>Lspsaga lsp_finder<CR>")
nmap("i", "<M-f>", "<Cmd>Lspsaga lsp_finder<CR>")
nmap("n", "<M-I>", "<Cmd>Lspsaga preview_definition<CR>")
nmap("i", "<M-I>", "<Cmd>Lspsaga preview_definition<CR>")

nmap("n", "<M-F>", "<Cmd>lua format_code()<CR>")
nmap("i", "<M-F>", "<Cmd>lua format_code()<CR>")
