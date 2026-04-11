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
	local csproj = fth.findUpFile('.*%.csproj', path)
	local dir = csproj:match '.+/'
	local label = csproj:match '([^/]+)%.csproj$'

	dir = fth.glob(dir .. 'bin/*/net*/')
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

vim.api.nvim_create_autocmd('InsertLeavePre', {
	buffer = 0,
	callback = function(s)
		local clients = vim.lsp.get_clients { name = 'roslyn_ls', bufnr = s.buf }
		if not clients or #clients == 0 then return end

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
	local cmd = vim.fn.glob '*.sln*' == '' and 'dotnet build -r linux-64' or 'dotnet build'
	vim.cmd[quick and '!' or 'term'](cmd)
	if quick and vim.v.shell_error == 0 then vim.api.nvim_input '\027' end
end
map({ 'n', 'i' }, '<A-b>', function() build(false) end)
map({ 'n', 'i' }, '<A-r>', function() build(true) end)

--- requires coroutine
---@param sources 'src'|'test'|'{src,test}'
function proj.pick(prompt, sources)
	local root = fth.findDirOf '%.sln.?$'
	if root == '' then return vim.notify 'No solution file found' end

	local projects = vim.split(vim.fn.glob(root .. sources .. '/*/'), '\n', { plain = true })
	if #projects == 0 or projects[1] == '' then return vim.notify 'No projects found' end
	table.insert(projects, 1, fth.findDirOf '.csproj$')

	---@diagnostic disable-next-line: missing-parameter
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

function proj.run_test(cfg, debug, filter)
	cfg.cmd = table.concat({
		'dotnet test -v detailed --project',
		cfg.csproj,
		filter,
	}, ' ')
	if debug then
		proj.debug_cfg(cfg)
	else
		proj.run_cfg(cfg)
	end
end

function proj.test()
	local cfg = proj.pick('test project', 'test')
	if not cfg then return end
	proj.run_test(cfg, false)
end

map('n', '<A-t>', function() coroutine.wrap(proj.test)() end)
map('n', '<A-S-R>', function() coroutine.wrap(proj.run)() end)
map('n', '<A-S-D>', function() coroutine.wrap(proj.debug)() end)
map('n', '<S-F6>', function() coroutine.wrap(proj.debug)() end)

local function test_active(debug)
	local cfg = proj.cfg(fth.findDirOf '.csproj$')
	local ts = require('manipulator').ts
	local class = ts.current({ types = { 'class_declaration' } }):field('name'):get_text()
	local fn = ts.current { types = { 'method_declaration' }, nil_wrap = false }
	local txt
	if fn then
		txt = ('--filter-method "*.%s.%s"'):format(class, fn:field('name'):get_text())
	elseif not debug then
		txt = ('--filter-class "*.%s"'):format(class)
	else
		print 'Debugging allowed only for individual methods'
		return
	end
	proj.run_test(cfg, debug, txt)
end
map('n', 't', test_active)
map('n', '<A-S-T>', function() test_active(true) end)

map('n', '<A-y>', function()
	local client = vim.lsp.get_clients({ name = 'roslyn_ls', bufnr = 0 })[1]
	if not client then return end

	local m = require 'manipulator'
	local pos = m.ts.current { types = { 'declaration$' } }
	local r = pos.range
	local indent = m.Range.get_text { r[1], 0, r[1], r[2] - 1 }
	---@diagnostic disable-next-line: cast-local-type
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

local function transform_endpoint()
	local m = require 'manipulator'

	local fn = m.ts.current { types = { 'method_declaration' } }
	local ret_type = fn:field 'returns'
	if not ret_type then return print 'weird method without return type' end
	local name_str = fn:field('name'):get_text()
	local ok_ret = ret_type:get_text():match '^Task<ActionResult<(.*)>>$'
	local anno_block = fn:descendant {
		query = [[(method_declaration (attribute_list)* @fold)]],
		types = { '@fold' },
	}
	if not anno_block then return print 'no anno block' end

	local annos = { others = {} }

	local results = {}

	-- 1. Filter into a map by iterating through lines
	for _, line in ipairs(anno_block:get_lines(false)) do
		if line:find '%[EndpointSummary' then
			annos.summary = line
		elseif line:find '%[EndpointDescription' then
			annos.desc = line
		elseif line:find '%[Consumes' then
			annos.consumes = line
		elseif line:find '%[Http' then
			annos.method = line
				:gsub('"%)', '", )')
				:gsub('([^)])%]', '%1()]')
				:gsub('%)', string.format('Name = nameof(%s))', name_str))
		elseif line:find 'ResponseType' then
			local code, name = line:match 'Status(%d+)(%w+)'
			if code and code ~= '401' and code ~= '403' then
				if code:match '^2' then
					local ok_t = { ['201'] = 'CreatedAtRoute', ['200'] = 'Ok<%s>', ['204'] = 'NoContent' }
					table.insert(results, string.format(ok_t[code] or (name .. '<%s>'), ok_ret))
				else
					table.insert(results, name .. '<ProblemDetails>')
				end
			end
		else
			table.insert(annos.others, line)
		end
	end

	-- 3. Construct Final Result
	local results_type = #results == 1 and results[1]
		or ('Results<' .. table.concat(results, ', ') .. '>')

	ret_type:paste { text = 'Task<' .. results_type .. '>' }

	for n in
		fn:field('body'):in_graph { inherit = 'super.descendant', types = { 'return_statement' } }
	do
		local result = n:get_text()
			:gsub('return ', 'return TypedResults.')
			:gsub('CreatedAtAction(.+),%s*null%)', 'CreatedAtRoute%1)')
			:gsub('Ok(.+ToListAsync%(%))', 'Ok(%1).AsEnumerable()')
			:gsub('Problem%((.*4[0-9][0-9](%w+).*)%);', '%2(new ProblemDetails { %1 });')
			:gsub('statusCode: (.-Status4[0-9][0-9](%w+))', 'Title = "%2", Status = %1')
			:gsub('detail: ("[^"]+")', 'Detail = %1')
			:gsub('\n%s+("[^"]+")', '\nDetail = %1')
		n:paste { text = result }
	end

	local out_annos = {}
	for _, v in ipairs { 'method', 'summary', 'desc', 'consumes' } do
		out_annos[#out_annos + 1] = annos[v]
	end
	for _, v in ipairs(annos.others) do
		out_annos[#out_annos + 1] = annos[v]
	end

	if #out_annos then
		local text = table.concat(out_annos, '\n')
		anno_block.range[2] = 0
		anno_block:paste { text = text, linewise = true, mode = 'over' }
	end
end

_G.map('n', 'e', transform_endpoint)
