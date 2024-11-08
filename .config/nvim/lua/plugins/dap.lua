local M = {
	'rcarriga/nvim-dap-ui',
	dependencies = {
		'mfussenegger/nvim-dap',
		'theHamsta/nvim-dap-virtual-text',
		'nvim-neotest/nvim-nio',
	},
	keys = { ' db' },
}
function M.config()
	local dap, dapui = require 'dap', require 'dapui'
	dap.adapters.codelldb = {
		type = 'server',
		port = '${port}',
		executable = { command = '/usr/bin/codelldb', args = { '--port', '${port}' } },
	}

	local function run()
		if dap.sessions()[1] then return dap.run_to_cursor() end

		local config = dap.configurations[vim.o.filetype]
		if config == nil then return vim.notify('No config for `' .. vim.o.filetype .. '`') end
		config = config[1] --[[@as {}]]

		config.stdio = { nil, nil, nil }
		vim.ui.input(
			{ prompt = 'Args: ', cancelreturn = false, default = table.concat(config.args or {}, ' ') },
			function(res)
				if not res then return end
				local args = {}
				local concat = false
				for arg in res:gmatch '[^ ]+' do
					if concat then
						args[#args] = args[#args]:sub(1, -2) .. ' ' .. arg
						concat = false
					else
						args[#args + 1] = arg
					end
					if arg:sub(-1) == '\\' then concat = true end
				end
				if args[#args - 1] == '<' then
					config.stdio = { args[#args], nil, nil }
					args[#args] = nil
					args[#args] = nil
				end
				config.args = args
				dap.run(config)
			end
		)
	end

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
	dap.listeners.before.event_exited['dapui_config'] = dapui.close

	---@diagnostic disable-next-line: missing-fields
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
			{ elements = { { id = 'console', size = 1 }, --[[ {id = 'repl', size = 0.5} ]] }, size = 0.3, position = 'bottom' },
		},
		mappings = {
			expand = { '<RightMouse>', 'o', '<CR>', '<Left>', 'l' },
			remove = { 'D', '<Del>' },
			edit = { 'R', 'E', '<S-CR>', 'e' },
			open = { 'O', '<A-CR>', '<Left>', 'l' },
			toggle = 'T',
		},
	}
	require('nvim-dap-virtual-text').setup { highlight_new_as_changed = true, enabled_commands = false }

	map('n', ' db', dap.toggle_breakpoint)
	map('n', ' dB', dap.clear_breakpoints)
	map('n', ' dg', dap.goto_)
	map('n', ' dL', function() dap.list_breakpoints(true) end)
	map('n', ' du', dapui.toggle)
	map('n', ' dE', dapui.eval)
	map('n', ' de', function()
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
