local function build(quick)
	vim.cmd.w()
	local cmd = vim.fn.glob '*.sln' == '' and 'dotnet build -r linux-64' or 'dotnet build'
	vim.cmd[quick and '!' or 'term'](cmd)
	if quick and vim.v.shell_error == 0 then vim.api.nvim_feedkeys('\015', 'n', false) end
end
map({ 'n', 'i' }, '<A-b>', function() build(false) end, { buffer = true })
map({ 'n', 'i' }, '<A-r>', function() build(true) end, { buffer = true })

local function getProjectCfg(dll)
	local dir = vim.api.nvim_buf_get_name(0)
	local label = ''
	while label == '' do
		dir = dir:gsub('/[^/]+$', '')
		label = vim.fn.glob(dir .. '/*.csproj')
	end

	local cfg = { dir = dir, csproj = label }

	dir = vim.fn.glob(dir .. '/bin/Debug/net*/')
	if dir == '' then return vim.notify 'No "Debug" dir found' end
	if exists(dir .. 'linux-x64/') then dir = dir .. 'linux-x64/' end
	label = dir .. label:match '([^/]+)%.csproj$'
	if not exists(label) then return vim.notify('No executable "' .. label .. '"') end

	cfg.cmd = dll and label .. '.dll' or label
	return cfg
end

local runcfg = {
	env = 'ASPNETCORE_ENVIRONMENT=Development',
	args = {
		'/p:EnvironmentName=Development', -- this is a msbuild jk
		'--environment=Development',
		'--urls=http://localhost:3001',
	},
}

local function runWithConfig(cmd)
	if not cmd then return vim.notify 'No command supplied' end
	vim.cmd.term(table.concat({
		runcfg.env,
		cmd,
		table.concat(runcfg.args, ' '),
	}, ' '))
end

-- map({ 'n', 'i' }, '<A-B>', function() runWithConfig 'dotnet watch' end, { buffer = true })
map({ 'n', 'i' }, '<A-R>', function()
	local cfg = getProjectCfg()
	if not cfg then return end
	vim.cmd.term(table.concat({
		'cd',
		cfg.dir,
		"&&",
		runcfg.env,
		cfg.cmd,
		table.concat(runcfg.args, ' '),
	}, ' '))
end, { buffer = true })
map(
	{ 'n', 'i' },
	'<A-B>',
	function() runWithConfig('dotnet run --project ' .. getProjectCfg().csproj) end,
	{ buffer = true }
)

if vim.g.loaded then
	if vim.g.loaded['cs'] then return end
	vim.g.loaded['cs'] = true
end
vim.g.loaded = { ['cs'] = true }

withMod('dap', function(dap)
	dap.adapters.netcoredbg = {
		type = 'executable',
		command = 'netcoredbg',
		args = { '--interpreter=vscode' },
	}
	dap.configurations.cs = {
		{
			name = 'Launch',
			type = 'netcoredbg',
			request = 'launch',
			env = runcfg.env,
			args = runcfg.args,
			program = function()
				local cfg = getProjectCfg(true)
				if not cfg then return dap.ABORT end

				vim.fn.chdir(cfg.dir)
				return cfg.cmd
			end,
		},
		{
			name = [[Attach 'dotnet test']],
			type = 'netcoredbg',
			request = 'attach',
			processId = function()
				-- attaches to VSTEST_HOST_DEBUG=1 dotnet test test/APITest/bin/Debug/net8.0/APITest.dll
				local p = io.popen [[ps axf | grep 'dotnet exec --runtimeconfig' |
					grep -v grep | awk '{print $1}' ]]
				if not p then return dap.ABORT end
				local pid = tonumber(p:read '*a') or dap.ABORT
				p:close()
				return pid
			end,
		},
	}
end)

withMod('mylsp', function(ml)
	ml.setup 'omnisharp'
	vim.cmd.LspStart 'omnisharp'
end)
