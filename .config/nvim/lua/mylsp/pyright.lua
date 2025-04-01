return {
	-- nothing works
	-- on_attach = function(client)
	-- 	local f = io.open(client.config.root_dir .. '/.python-version')
	-- 	if not f then return end
	-- 	client.config.settings.venv = f:read '*l'
	-- 	-- vim.env.PYENV_VERSION = vim.fn.system('pyenv version'):match '(%S+)%s+%(.-%)'
	-- 	f:close()
	-- 	client.notify 'workspace/didChangeConfiguration'
	-- end,
	-- settings = {
	-- 	python = {
	-- 		venvPath = os.getenv 'HOME' .. '/.pyenv/versions/',
	-- 		venv = "nrdb"
	-- 	},
	-- },
}
