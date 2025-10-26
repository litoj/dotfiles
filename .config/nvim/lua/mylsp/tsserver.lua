-- loaded on first opening of a js/ts file only

withMod('dap', function(dap)
	local dapcfg = {
		--[[ {
			type = 'pwa-node',
			request = 'launch',
			name = 'Launch file',
			program = '${file}',
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
		}, ]]
		{
			type = 'pwa-node',
			request = 'attach',
			name = 'Attach to "npx --inspect" cmds',
			processId = function()
				return require('dap.utils').pick_process { filter = '^%S*node.*--inspect' }
			end,
			cwd = vim.fn.getcwd(),
			sourceMaps = true,
		},
		{
			type = 'pwa-chrome',
			request = 'launch',
			name = 'Debug Browser Client',
			url = function()
				return 'http://localhost:3000'
				--[[ local co = coroutine.running()
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
				end) ]]
			end,
			webRoot = vim.fn.getcwd(),
			protocol = 'inspector',
			sourceMaps = true,
			userDataDir = false,
		},
		-- Divider for the launch.json derived configs
		--[[ {
			name = '----- ↓ launch.json configs ↓ -----',
			type = '',
			request = 'launch',
		}, ]]
	}

	require('dap-vscode-js').setup {
		adapters = { 'pwa-node', 'pwa-chrome', 'node-terminal' },
		debugger_path = os.getenv 'HOME' .. '/.local/share/vscode-js-debug',
	}
	for _, l in ipairs {
		'typescript',
		'javascript',
		'typescriptreact',
		'javascriptreact',
		'vue',
	} do
		dap.configurations[l] = dapcfg
	end
end)

require('mylsp').setup('eslint', {
	settings = {
		rulesCustomizations = {
			{ rule = '*', severity = 'info' },
			{ rule = '*/no-unused-vars-experimental', severity = 'off' },
		},
	},
	single_file_support = false,
	setCwd = false,
	handlers = {
		['textDocument/diagnostic'] = function(error, result, ctx, config)
			if error and error.code == -32603 then
				vim.lsp.buf_detach_client(ctx.bufnr, ctx.client_id)
				vim.notify('eslint: no config', vim.log.levels.WARN)
				return
			end
			vim.lsp.handlers['textDocument/diagnostic'](error, result, ctx, config)
		end,
	},
})

return {
	format = false,
	folding = true,
	root_markers = {
		'src',
		'package.json',
		'tsconfig.json',
		'jsconfig.json',
		'.git',
	},
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
}
