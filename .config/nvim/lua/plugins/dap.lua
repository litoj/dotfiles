local M = {
	'rcarriga/nvim-dap-ui',
	dependencies = { 'mfussenegger/nvim-dap', 'theHamsta/nvim-dap-virtual-text' },
	ft = { 'c', 'cpp', 'rust', 'java' },
}
function M.config()
	local dap, dapui = require 'dap', require 'dapui'
	dap.adapters.codelldb = {
		type = 'server',
		port = '${port}',
		executable = {
			command = '/usr/bin/codelldb', -- adjust as needed, must be absolute path
			args = { '--port', '${port}' },
		},
	}
	dap.configurations.c = {
		{
			name = 'Launch',
			type = 'codelldb',
			request = 'launch',
			cwd = '${workspaceFolder}',
			program = function()
				if vim.loop.fs_stat 'main.out' then return 'main.out' end
				local name = vim.api.nvim_buf_get_name(0)
				return name:gsub('%.[ch].*$', '.out')
				-- LSAN_OPTIONS=verbosity=1:log_threads=1 gdb...
			end,
		},
	}
	dap.configurations.cpp = dap.configurations.c
	dap.configurations.rust = {
		{
			name = 'Launch',
			type = 'codelldb',
			request = 'launch',
			cwd = '${workspaceFolder}',
			program = function()
				os.execute 'cargo b'
				return vim.api.nvim_buf_get_name(0):gsub('(/%w+)/src/.*$', '%1/target/debug%1')
			end,
		},
	}

	local function run()
		local config = dap.configurations[vim.o.filetype]
		if config == nil then
			vim.notify('No configuration found for `' .. vim.o.filetype .. '`.', vim.log.levels.INFO)
			return
		end
		config = config[1]
		if config.type == 'codelldb' then
			config.args = {}
			config.stdio = { nil, nil, nil }
			vim.ui.input({ prompt = 'Args: ' }, function(res)
				if res == '' then return end
				for arg in res:gmatch '[^ ]+' do
					table.insert(config.args, arg)
				end
				if config.args[#config.args - 1] == '<' then
					config.stdio = { config.args[#config.args], nil, nil }
					config.args[#config.args] = nil
					config.args[#config.args] = nil
				end
				dap.run(config)
			end)
		end
	end

	dap.defaults.fallback.external_terminal = { command = 'xterm' }
	-- dap.defaults.fallback.force_external_terminal = true
	dap.defaults.fallback.focus_terminal = true
	vim.fn.sign_define(
		'DapBreakpoint',
		{ text = '', texthl = 'DiagnosticSignError', numhl = 'Fg' }
	)
	vim.fn.sign_define('DapStopped', {
		text = '',
		texthl = 'DiagnosticSignInfo',
		linehl = 'Visual',
		numhl = 'DiagnosticSignInfo',
	})

	dap.listeners.after.event_initialized['dapui_config'] = dapui.open
	dap.listeners.before.event_terminated['dapui_config'] = dapui.close
	dap.listeners.before.event_exited['dapui_config'] = dapui.close()

	dapui.setup {
		layouts = {
			{
				elements = {
					{ id = 'scopes', size = 0.45 },
					{ id = 'watches', size = 0.35 },
					{ id = 'stacks', size = 0.1 },
					{ id = 'breakpoints', size = 0.1 },
				},
				size = 0.25,
				position = 'right',
			},
			{ elements = { { id = 'console', size = 1 } }, size = 0.3, position = 'bottom' },
		},
		mappings = {
			expand = { '<RightMouse>', 'o', '<CR>', '<Left>', 'l' },
			remove = { 'D', '<Del>' },
			edit = { 'R', 'E', '<S-CR>', 'e' },
			open = { 'O', '<M-CR>', '<Left>', 'l' },
			toggle = 'T',
		},
	}
	require('nvim-dap-virtual-text').setup { highlight_new_as_changed = true, enabled_commands = false }

	map('n', '<Leader>b', dap.toggle_breakpoint)
	map('n', '<Leader>B', dap.clear_breakpoints)
	map('n', 'gt', dap.goto_)
	map('n', 'gB', function() dap.list_breakpoints(true) end)
	map('n', 'dr', dap.run_to_cursor)
	map('n', '<M-e>', dapui.eval)
	map('n', '<Leader>e', function()
		vim.ui.input(
			{ prompt = 'Eval: ', default = vim.fn.expand '/nat' },
			function(res) dapui.eval(res) end
		)
	end)
	map('n', '<F6>', dap.continue)
	map('n', '<F18>', run)
	map('n', '<F7>', dap.step_into)
	map('n', '<F8>', dap.step_over)
	map('n', '<F9>', dap.step_out)
	map('n', '<F10>', dap.terminate)
end
return M
