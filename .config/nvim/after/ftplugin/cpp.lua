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
					local name = vim.api.nvim_buf_get_name(0)
					return name:gsub('%.cpp$', '.out')
					-- LSAN_OPTIONS=verbosity=1:log_threads=1 gdb...
				end,
			},
		}
	end,
}

map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>')
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!compiler %:p<CR><CR>')
map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o '%:r'.out<CR><CR>")
map(
	{ 'n', 'i' },
	'<A-S-B>',
	'<C-s><Cmd>!make debug||g++ -std=c++17 -Wall -pedantic -g -fsanitize=address,leak -DDEBUG %:p -o %:p:r.out<CR>',
	{ remap = true }
)
map({ 'n', 'i' }, '<A-S-M>', '<Cmd>w|!cd %:h && make<CR>')

map({ 'n', 'i' }, '<A-S-R>', function()
	local name = vim.api.nvim_buf_get_name(0)
	local out = name:gsub('%.cpp$', '.out')
	if not exists(out) then vim.fn.glob(name:gsub('/[^/]*$', '/*.out')) end
	if not exists(out) then return vim.notify 'No executable found' end
	vim.cmd.term(out)
end)
