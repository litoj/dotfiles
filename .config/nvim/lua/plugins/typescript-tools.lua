local M = {
	'pmizio/typescript-tools.nvim',
	ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
	dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lspconfig' },
}
M.config = function()
	require('typescript-tools').setup(require 'mylsp'(nil, {
		inlay = true,
		folding = true,
		root_dir = require('lspconfig.util').root_pattern(
			'src',
			'package.json',
			'tsconfig.json',
			'jsconfig.json',
			'.git'
		),
		init_options = { suggestFromUnimportedLibraries = false, closingLabels = true },
		settings = {
			separate_diagnostic_server = false,
			expose_as_code_action = { 'add_missing_imports' },
			tsserver_path = '/usr/bin/tsserver',
			tsserver_file_preferences = {
				includeInlayParameterNameHints = 'all',
				includeInlayVariableTypeHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeCompletionsForModuleExports = true,
				includeCompletionsWithInsertText = true,
				includeAutomaticOptionalChainCompletions = true,
				lazyConfiguredProjectsFromExternalProject = true,
			},
		},
	}))
	require 'mylsp'('eslint', {
		format = true,
		settings = {
			rulesCustomizations = {
				{ rule = '*', severity = 'info' },
				{ rule = '*/no-unused-vars-experimental', severity = 'off' },
			},
		},
	})
end
return M
