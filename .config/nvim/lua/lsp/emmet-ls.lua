lsp_setup("emmet_ls", {
	cmd = {"node", DATA_PATH .. "lsp_servers/emmet_ls/node_modules/emmet-ls/src/server.ts", "--stdio"},
	filetypes = {"html", "css"},
	root_dir = require'lspconfig'.util.root_pattern(".git", vim.fn.getcwd())
})
