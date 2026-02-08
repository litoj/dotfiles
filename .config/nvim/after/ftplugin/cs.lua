if vim.bo.bufhidden ~= '' then return end

vim.bo.formatoptions = vim.bo.formatoptions .. 'cro'

local runcfg = {
	env = 'ASPNETCORE_ENVIRONMENT=Development',
	args = {
		'/p:EnvironmentName=Development', -- this is a msbuild jk
		'--environment=Development',
		'--urls=http://localhost:3001',
	},
}

local fth = require 'fthelper'
local proj = {}
function proj.cfg(path)
	local csproj = fth.findUpFile(path or vim.fn.bufname(0), '.*%.csproj')
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

vim.api.nvim_create_autocmd({ 'InsertLeave' }, {
	buffer = 0,
	callback = function(s)
		local clients = vim.lsp.get_clients { name = 'roslyn' }
		if not clients or #clients == 0 then return end
		if #clients > 1 then vim.notify 'Multiple Roslyn clients!' end

		local params = { textDocument = vim.lsp.util.make_text_document_params(s.buf) }
		clients[1]:request('textDocument/diagnostic', params, nil, s.buf)
	end,
})

local map, modmap = fth.once {
	mylsp = function(ml) ml.setup 'roslyn_ls' end,

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
					local cfg = proj.cfg()
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

modmap {
	['manipulator.call_path'] = function(mcp, buf)
		local mapAll = require('plugins.manipulator').mapAll
		mapAll(
			'docs',
			{ opts = { langs = false, query = [[(comment)+ @docs]], types = { '@docs' } } },
			{ buffer = buf }
		)
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

--- requires coroutine
---@param sources 'src'|'test'|'{src,test}'
function proj.pick(prompt, sources)
	local root = fth.findDir(nil, '.sln$')
	if root == '' then return vim.notify 'No solution file found' end

	local projects = vim.split(vim.fn.glob(root .. sources .. '/*/'), '\n', { plain = true })
	if #projects == 0 or projects[1] == '' then return vim.notify 'No projects found' end
	table.insert(projects, 1, fth.findDir(nil, '.csproj$'))

	local _, pos = vim.ui.select(
		vim.tbl_map(function(v) return v:match '([^/]+)/$' end, projects),
		{ prompt = prompt or 'Pick project' }
	)
	return proj.cfg(projects[pos])
end

function proj.run_cfg(cfg) vim.cmd.term(table.concat({ 'cd', cfg.dir, '&&', cfg.cmd }, ' ')) end

function proj.debug_cfg(cfg) vim.notify 'Load dap first to enable debugging (set a breakpoint).' end

fth.withMod('dap', function(dap)
	function proj.debug_cfg(cfg)
		cfg.cmd = cfg.cmd:gsub('dotnet ', 'VSTEST_HOST_DEBUG=1 dotnet ')
		local bufnr = vim.api.nvim_get_current_buf()
		proj.run_cfg(cfg)

		vim.defer_fn(function()
			vim.api.nvim_set_current_buf(bufnr)
			dap.continue()
		end, 3000)
	end
end)

function proj.run()
	local cfg = proj.pick('run project', 'src')
	if not cfg then return end

	vim.cmd.term(table.concat({
		'cd',
		cfg.dir,
		'&&',
		runcfg.env,
		cfg.cmd,
		table.concat(runcfg.args, ' '),
	}, ' '))
end

function proj.debug()
	local cfg = proj.pick('debug project', '{src,test}')
	if not cfg then return end

	cfg.cmd = table.concat({
		'dotnet',
		cfg.dir:match 'test' and 'test' or 'run --project',
		cfg.csproj,
	}, ' ')
	proj.debug_cfg(cfg)
end

function proj.test(debug)
	local cfg = proj.pick('debug project', 'test')
	if not cfg then return end

	local filter = vim.ui.input { prompt = 'DisplayName filter' }
	if not filter then return end
	cfg.cmd = table.concat({
		'dotnet',
		'test -v detailed',
		cfg.dll,
		filter ~= '' and '--filter DisplayName~' .. filter or nil,
	}, ' ')
	if debug then
		proj.debug_cfg(cfg)
	else
		proj.run_cfg(cfg)
	end
end

function proj.debug_test() proj.test(true) end

for bind, name in pairs {
	['<A-S-R>'] = 'run',
	['<A-S-D>'] = 'debug',
	['<F18>'] = 'debug',
	['<A-t>'] = 'test',
	['<A-S-T>'] = 'debug_test',
} do
	map({ 'n', 'i' }, bind, function()
		coroutine.wrap(function() proj[name]() end)()
	end)
end

map('n', '<A-y>', function()
	local client = vim.lsp.get_clients({ name = 'roslyn_ls', bufnr = 0 })[1]
	if not client then return end

	local m = require 'manipulator'
	local pos = m.ts.current { types = { 'declaration$' } }
	local r = pos.range
	local indent = m.Range.get_text { r[1], 0, r[1], r[2] - 1 }
	pos = pos:paste {
		text = indent .. '///',
		mode = 'before',
		linewise = true,
	}
	pos:jump { end_ = true, start_insert = true }

	local params = {
		_vs_textDocument = { uri = vim.uri_from_bufnr(0) },
		_vs_position = { line = pos.range[3], character = pos.range[4] + 1 },
		_vs_ch = '/',
		_vs_options = {
			tabSize = vim.bo.tabstop,
			insertSpaces = vim.bo.expandtab,
		},
	}

	client:request('textDocument/_vs_onAutoInsert', params, function(err, result, _)
		if err or not result then return end

		-- remove indent, because vim is stupid and prepends it to the snippet
		local text = string.gsub(result._vs_textEdit.newText, indent, '')
		vim.snippet.expand(text)
	end, 0)
end)
