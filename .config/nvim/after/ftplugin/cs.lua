if vim.bo.bufhidden ~= '' then return end

local runcfg = {
	env = 'ASPNETCORE_ENVIRONMENT=Development',
	args = {
		'/p:EnvironmentName=Development', -- this is a msbuild jk
		'--environment=Development',
		'--urls=http://localhost:3001',
	},
}

local function getProjCfg(path)
	local csproj = vim.fs.find(
		function(name) return vim.endswith(name, '.csproj') end,
		{ path = path or vim.api.nvim_buf_get_name(0), upward = true }
	)[1]
	local dir = csproj:match '.+/'
	local label = csproj:match '([^/]+)%.csproj$'

	dir = vim.split(vim.fn.glob(dir .. 'bin/*/net*/'), '\n', { plain = true })
	dir = dir[#dir]
	if dir == '' then return vim.notify 'No build dir found' end
	if exists(dir .. 'linux-x64/') then dir = dir .. 'linux-x64/' end

	local executable = dir .. label
	local dll = executable .. '.dll'
	if not exists(dll) then return vim.notify('No executable "' .. dll .. '"') end

	return {
		dir = dir,
		label = label,
		csproj = csproj,
		cmd = executable,
		dll = dll,
	}
end

local map = require 'fthelper' {
	mylsp = function(ml) ml.setup 'omnisharp' end,

	dap = function(dap)
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
					local cfg = getProjCfg()
					if not cfg then return dap.ABORT end

					vim.api.nvim_set_current_dir(cfg.dir)
					return cfg.dll
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
	end,
}

local function build(quick)
	vim.cmd.w()
	local cmd = vim.fn.glob '*.sln' == '' and 'dotnet build -r linux-64' or 'dotnet build'
	vim.cmd[quick and '!' or 'term'](cmd)
	if quick and vim.v.shell_error == 0 then vim.api.nvim_input '\027' end
end
map({ 'n', 'i' }, '<A-b>', function() build(false) end)
map({ 'n', 'i' }, '<A-r>', function() build(true) end)

local function findUp(ext)
	return vim.fs.find(
		function(name) return vim.endswith(name, ext) end,
		{ path = vim.api.nvim_buf_get_name(0), upward = true }
	)[1]
end

-- requires coroutine
local function pickProj(prompt)
	local root = findUp('.sln'):match '.+/'
	if root == '' then return vim.notify 'No solution file found' end

	local projects = vim.split(vim.fn.glob(root .. '{src,test}/*/'), '\n', { plain = true })
	if #projects == 0 or projects[1] == '' then return vim.notify 'No projects found' end
	table.insert(projects, 1, findUp('.csproj'):match '.+/')

	local _, pos = vim.ui.select(
		vim.tbl_map(function(v) return v:match '([^/]+)/$' end, projects),
		{ prompt = prompt or 'Pick project' }
	)
	return projects[pos]
end

local proj = {}
function proj.runInDir(cfg)
	vim.cmd.term(table.concat({
		'cd',
		cfg.dir,
		'&&',
		cfg.cmd,
	}, ' '))
end

function proj.run(cfg)
	vim.cmd.term(table.concat({
		'cd',
		cfg.dir,
		'&&',
		runcfg.env,
		cfg.cmd,
		table.concat(runcfg.args, ' '),
	}, ' '))
end

function proj.debugCfg(cfg)
	cfg.cmd = cfg.cmd:gsub('dotnet ', 'VSTEST_HOST_DEBUG=1 dotnet ')
	local bufnr = vim.api.nvim_get_current_buf()
	proj.runInDir(cfg)

	vim.defer_fn(function()
		local dap = require 'dap'
		vim.api.nvim_set_current_buf(bufnr)
		dap.continue()
	end, 3000)
end

function proj.debug(cfg)
	cfg.cmd = table.concat({
		'dotnet',
		cfg.dir:match '[tT]est' and 'test' or 'run --project',
		cfg.csproj,
	}, ' ')
	proj.debugCfg(cfg)
end

function proj.test(cfg, debug)
	cfg.cmd = table.concat({
		'dotnet',
		'test -v detailed',
		cfg.dll,
		'--filter DisplayName~' .. vim.ui.input { prompt = 'DisplayName filter' },
	}, ' ')
	proj[debug and 'debugCfg' or 'runInDir'](cfg)
end

for bind, name in pairs {
	['<A-R>'] = 'run',
	['<A-D>'] = 'debug',
	['<F18>'] = 'debug',
	['<A-t>'] = 'test',
} do
	map(
		{ 'n', 'i' },
		bind,
		coroutine.wrap(function() proj[name](getProjCfg(pickProj(name .. ' project'))) end)
	)
end
map(
	{ 'n', 'i' },
	'<A-T>',
	coroutine.wrap(function() proj.test(getProjCfg(pickProj 'Debug test'), true) end)
)
