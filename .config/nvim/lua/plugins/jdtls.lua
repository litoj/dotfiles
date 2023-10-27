local M = { 'mfussenegger/nvim-jdtls', --[[ ft = 'java' ]] }
function M.config()
	vim.wo.signcolumn = 'number'
	local cfgPath = os.getenv 'HOME' .. '/.config/jdtls/'
	local function root_dir()
		return vim.fs.dirname(vim.fs.find({
			'src',
			'build.xml',
			'build.gradle',
			'pom.xml',
			'.gradlew',
			'.git',
		}, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1])
	end
	local jdtls = require 'jdtls'
	local eCC = jdtls.extendedClientCapabilities
	eCC.resolveAdditionalTextEditsSupport = true

	local config = {
		cmd = {
			'java',
			'-Declipse.application=org.eclipse.jdt.ls.core.id1',
			'-Dosgi.bundles.defaultStartLevel=4',
			'-Declipse.product=org.eclipse.jdt.ls.core.product',
			'-Dlog.protocol=true',
			'-Dlog.level=ERROR',
			'-Xmx2G',
			'--add-modules=ALL-SYSTEM',
			'--add-opens',
			'java.base/java.util=ALL-UNNAMED',
			'--add-opens',
			'java.base/java.lang=ALL-UNNAMED',
			'-jar',
			vim.fn.glob '/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_*.jar',
			'-configuration',
			cfgPath .. 'config_linux',
			'-data',
		},
		flags = { server_side_fuzzy_completion = true, allow_incremental_sync = true },
		settings = {
			java = {
				signatureHelp = { enabled = true },
				codeGeneration = {
					toString = {
						template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
					},
					useBlocks = true,
					generateComments = true,
				},
				contentProvider = { preferred = 'fernflower' },
				configuration = {
					updateBuildConfiguration = 'interactive',
					runtimes = {
						{
							default = true,
							path = '/usr/lib/jvm/default-runtime/',
							-- sources = '/usr/lib/jvm/default-runtime/lib/src.zip',
							-- javadoc = '/usr/share/doc/java17-openjdk/',
						},
					},
				},
				eclipse = { downloadSources = true },
				maven = { downloadSources = true },
				references = { includeDecompiledSources = false },
				format = { enabled = false },
			},
		},
		init_options = {
			bundles = vim.split(vim.fn.glob '~/.local/share/vscode-java-test/server/*.jar', '\n'),
			extendedClientCapabilities = eCC,
		},
		on_attach = function(client)
			jdtls.setup_dap { hotcodereplace = 'auto' }
			vim.api.nvim_set_current_dir(client.config.root_dir)
		end,
	}
	table.insert(
		config.init_options.bundles,
		vim.fn.glob '~/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'
	)

	local init = function()
		if not config.capabilities then
			config.capabilities = require('cmp_nvim_lsp').default_capabilities()
			config.capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
		end
		if
			vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
			and vim.api.nvim_buf_get_option(0, 'modifiable')
		then
			config.root_dir = root_dir()
			config.cmd[#config.cmd + 1] = '/tmp/' .. config.root_dir:gsub('.*/', '')
		end
		vim.api.nvim_buf_set_option(0, 'formatoptions', 'tcqjl1')
		jdtls.start_or_attach(config)
		local opts = { buffer = true }
		map('n', 'gtc', jdtls.test_class, opts)
		map('n', 'gtf', jdtls.test_nearest_method, opts)
		map('n', 'gjd', require('jdtls.dap').setup_dap_main_class_configs, opts)

		vim.cmd [[
        command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require'jdtls'.compile(<f-args>)
        command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require'jdtls'.set_runtime(<f-args>)
        command! -buffer JdtUpdateConfig lua require'jdtls'.update_project_config()
        command! -buffer JdtJol lua require'jdtls'.jol()
        command! -buffer JdtBytecode lua require'jdtls'.javap()
        ]]
		map({ 'n', 'i' }, '<M-r>', function() jdtls.compile 'full' end, opts)
		map({ 'n', 'i' }, '<M-I>', jdtls.organize_imports, opts)
	end

	if vim.g.initialized then
		init()
	else
		vim.api.nvim_create_autocmd('User', { pattern = 'Initialized', callback = init, once = true })
	end
	vim.api.nvim_create_autocmd('FileType', {
		pattern = 'java',
		callback = function(state)
			if vim.api.nvim_buf_get_option(state.buf, 'bufhidden') == '' then init() end
		end,
	})
end
return M
