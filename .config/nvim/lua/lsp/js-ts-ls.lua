lsp_setup("tsserver", {
	cmd = {"typescript-language-server", "--stdio"},
	folding = true,
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx"
	},
	root_dir = require'lspconfig/util'.root_pattern("package.json", "tsconfig.json", "jsconfig.json",
	                                                ".git"),
	init_options = {suggestFromUnimportedLibraries = true, closingLabels = true}
})
