return {
	on_attach = function(client)
		local fname = client.root_dir .. '/.python-version'
		local f = io.open(fname, 'r')
		if not f then
			vim.notify(fname .. ' not found', vim.log.levels.WARN)
			return
		end

		local env = f:read '*l'
		local pth =
			{ pythonPath = client.config.settings.python.venvPath .. env .. '/bin/python', venv = env }
		f:close()
		if client.settings then
			client.settings.python = vim.tbl_deep_extend('force', client.settings.python, pth)
		else
			client.config.settings =
				vim.tbl_deep_extend('force', client.config.settings, { python = pth })
		end
	end,
	root_markers = { '.python-version' },
	settings = {
		pyright = {
			autoImportCompletion = true,
		},
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = 'openFilesOnly',
				useLibraryCodeForTypes = true,
				typeCheckingMode = 'basic',
			},
			venvPath = os.getenv 'HOME' .. '/.pyenv/versions/',
		},
	},
}
