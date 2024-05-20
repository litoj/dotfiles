local M = {
	'pmizio/typescript-tools.nvim',
	ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
	dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lspconfig' },
}
M.config = function()
	require('typescript-tools').setup(require('mylsp').setup(nil, {
		format = false,
		inlay = true,
		folding = true,
		root_dir = require('lspconfig.util').root_pattern(
			'src',
			'package.json',
			'tsconfig.json',
			'jsconfig.json',
			'.git'
		),
		init_options = {
			suggestFromUnimportedLibraries = false,
			closingLabels = true,
			preferences = { includeCompletionsForModuleExports = false },
		},
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
	require('mylsp').setup('eslint', {
		format = true,
		settings = {
			rulesCustomizations = {
				{ rule = '*', severity = 'info' },
				{ rule = '*/no-unused-vars-experimental', severity = 'off' },
			},
		},
		single_file_support = false, -- runs but gives no useful information
		inlay = false,
		setCwd = false,
	})

	local dap = require 'dap'
	local dapcfg = {
		{
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch file',
			program = '${file}',
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
		},
		{
			type = 'pwa-node',
			request = 'attach',
			name = 'Attach (for "npx --inspect" cmds)',
			processId = require('dap.utils').pick_process,
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
		},
		{
			type = 'pwa-chrome',
			request = 'launch',
			name = 'Debug Browser Client',
			url = function()
				local co = coroutine.running()
				return coroutine.create(function()
					vim.ui.input({
						prompt = 'Enter URL: ',
						default = 'http://localhost:3000',
					}, function(url)
						if url == nil or url == '' then
							return
						else
							coroutine.resume(co, url)
						end
					end)
				end)
			end,
			webRoot = vim.fn.getcwd(),
			protocol = 'inspector',
			sourceMaps = true,
			userDataDir = false,
		},
		-- Divider for the launch.json derived configs
		{
			name = '----- ↓ launch.json configs ↓ -----',
			type = '',
			request = 'launch',
		},
	}

	for _, l in ipairs(M.ft) do
		dap.configurations[l] = dapcfg
	end
end
return M
