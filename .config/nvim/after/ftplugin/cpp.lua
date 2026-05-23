if vim.bo.bufhidden ~= '' then return end

local map = require('fthelper').once {
	mylsp = function(ml) ml.setup 'clangd' end,

	dap = function(dap)
		dap.configurations.cpp = {
			{
				name = 'Launch',
				type = 'codelldb',
				request = 'launch',
				cwd = '${workspaceFolder}',
				program = function()
					if exists 'main.out' then return 'main.out' end
					local name = vim.api.nvim_buf_get_name(0):gsub('.c[cp]p?$', '.out')
					if exists(name) then return name end
					vim.notify 'No executable found'

					-- name = nil
					-- vim.ui.input({ prompt = 'Enter name of executable: ' }, function(r) name = r end)
					-- vim.wait(math.huge, function() return name ~= nil end, 1000)
					-- return name
					-- LSAN_OPTIONS=verbosity=1:log_threads=1 gdb...
				end,
			},
		}
	end,
}

map(
	{ 'n', 'i' },
	'<A-S-B>',
	'<C-s><Cmd>!make debug||g++ -std=c++17 -Wall -pedantic -g -fsanitize=address,leak -DDEBUG %:p -o %:p:r.out<CR>',
	{ remap = true }
)
map({ 'n', 'i' }, '<A-S-M>', '<Cmd>w|!cd %:h && make<CR>')
