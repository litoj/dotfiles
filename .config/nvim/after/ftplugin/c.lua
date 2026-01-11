if vim.bo.bufhidden ~= '' then return end

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
					vim.notify('None of the expected executables found:\n' .. table.concat(seek, '\n'))
					-- LSAN_OPTIONS=verbosity=1:log_threads=1 gdb...
				end,
			},
		}
		dap.configurations.cpp = dap.configurations.c
	end,
}

map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>')
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|make||!compiler %:p<CR><CR>')
map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o '%:r'.out<CR><CR>")
map(
	{ 'n', 'i' },
	'<A-S-B>',
	"<C-s><Cmd>!make debug||gcc -Wall -pedantic -g -fsanitize=address,leak,undefined -DDEBUG '%:p' -o '%:r'.out<CR>",
	{ remap = true }
)
map({ 'n', 'i' }, '<A-S-T>', "<C-s><Cmd>!cd '%:h' && make test<CR>", { remap = true })
map({ 'n', 'i' }, '<A-S-M>', "<Cmd>w|!cd '%:h' && make all<CR>")

map({ 'n', 'i' }, '<A-S-R>', function()
	local name = vim.api.nvim_buf_get_name(0)
	local out = name:gsub('%.c$', '.out')
	if not exists(out) then out = vim.fn.glob(name:gsub('/[^/]*$', '/*.out')) end
	if not exists(out) then return vim.notify 'No executable found' end
	vim.cmd.term(out)
end)
