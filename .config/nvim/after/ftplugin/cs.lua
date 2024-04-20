local function build(quick)
	vim.cmd.w()
	local cmd = vim.fn.glob '*.sln' == '' and 'dotnet build -r linux-64' or 'dotnet build'
	vim.cmd[quick and '!' or 'term'](cmd)
	if quick and vim.v.shell_error == 0 then vim.api.nvim_feedkeys('\015', 'n', false) end
end
map({ 'n', 'i' }, '<A-b>', function() build(false) end, { buffer = true })
map({ 'n', 'i' }, '<A-r>', function() build(true) end, { buffer = true })
map({ 'n', 'i' }, '<A-m>', '<Cmd>w|term dotnet msbuild<CR>', { buffer = true })

local function getExecPath(dll)
	local dir = vim.api.nvim_buf_get_name(0)
	local label = ''
	while label == '' do
		dir = dir:gsub('/[^/]+$', '')
		label = vim.fn.glob(dir .. '/*.csproj')
	end

	dir = vim.fn.glob(dir .. '/bin/Debug/net*/')
	if dir == '' then return vim.notify 'No "Debug" dir found' end
	if exists(dir .. 'linux-x64/') then dir = dir .. 'linux-x64/' end
	label = dir .. label:match '([^/]+)%.csproj$'
	if not exists(label) then return vim.notify('No executable "' .. label .. '"') end
	return dll and label .. '.dll' or label
end

local runcfg = {
	env = 'ASPNETCORE_ENVIRONMENT=Development',
	args = {
		'/p:EnvironmentName=Development', -- this is a msbuild jk
		'--urls=http://localhost:5002',
		'--environment=Development',
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

map({ 'n', 'i' }, '<A-B>', function() runWithConfig 'dotnet watch' end, { buffer = true })
map({ 'n', 'i' }, '<A-R>', function() runWithConfig(getExecPath()) end, { buffer = true })

if vim.g.loaded then
	if vim.g.loaded['cs'] then return end
	vim.g.loaded['cs'] = true
end
vim.g.loaded = { ['cs'] = true }

withMod('dap', function(dap)
	dap.adapters.coreclr = {
		type = 'executable',
		command = 'netcoredbg',
		args = { '--interpreter=vscode' },
	}
	dap.configurations.cs = {
		{
			name = 'Launch',
			type = 'coreclr',
			request = 'launch',
			env = runcfg.env,
			args = runcfg.args,
			program = function() return getExecPath(true) end,
		},
	}
end)

withMod('mylsp', function(ml)
	ml.setup 'omnisharp'
	vim.cmd.LspStart 'omnisharp'
end)
