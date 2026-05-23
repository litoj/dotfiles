if vim.bo.bufhidden ~= '' or vim.bo.ft ~= 'c' then return end

local map = require('fthelper').once {
	mylsp = function(ml) ml.setup 'clangd' end,

	dap = function(dap)
		dap.configurations.c = {
			{
				name = 'Launch',
				type = 'codelldb',
				request = 'launch',
				cwd = '${workspaceFolder}',
				program = function()
					local name = vim.api.nvim_buf_get_name(0):sub(#vim.uv.cwd() + 2) -- relative path
					local seek = {
						'main.out',
						name:gsub('[^/]+$', 'main.out'),
						name:gsub('%.c$', '.out'),
						name:gsub('%.c$', ''),
					}
					for _, main in ipairs(seek) do
						if exists(main) then return main end
					end
					vim.notify 'No executable found'

					-- name = nil
					-- vim.ui.input({ prompt = 'Enter name of executable: ' }, function(r) name = r end)
					-- vim.wait(math.huge, function() return name ~= nil end)
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
	"<C-s><Cmd>!make debug||gcc -Wall -pedantic -g -fsanitize=address,leak,undefined -DDEBUG '%:p' -o '%:r'.out<CR>",
	{ remap = true }
)
map({ 'n', 'i' }, '<A-S-T>', "<C-s><Cmd>!cd '%:h' && make test<CR>", { remap = true })
map({ 'n', 'i' }, '<A-S-M>', "<Cmd>w|!cd '%:h' && make all<CR>")
