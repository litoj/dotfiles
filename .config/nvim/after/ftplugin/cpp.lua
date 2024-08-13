map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!compiler %:p<CR><CR>', { buffer = true })
map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o '%:r'.out<CR><CR>", { buffer = true })
map(
	{ 'n', 'i' },
	'<A-B>',
	'<C-s><Cmd>!make debug||g++ -std=c++17 -Wall -pedantic -g -fsanitize=address,leak -DDEBUG %:p -o %:p:r.out<CR>',
	{ buffer = true, remap = true }
)
map({ 'n', 'i' }, '<A-M>', '<Cmd>w|!cd %:h && make<CR>', { buffer = true })

map({ 'n', 'i' }, '<A-R>', function()
	local name = vim.api.nvim_buf_get_name(0)
	local out = name:gsub('%.cpp$', '.out')
	if not exists(out) then vim.fn.glob(name:gsub('/[^/]*$', '/*.out')) end
	if not exists(out) then return vim.notify 'No executable found' end
	vim.cmd.term(out)
end, { buffer = true })

if vim.g.loaded then
	if vim.g.loaded['cpp'] then return end
	vim.g.loaded['cpp'] = true
end
vim.g.loaded = { ['cpp'] = true }

withMod('dap', function(dap)
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
end)

withMod('mylsp', function(ml)
	ml.setup 'clangd'
	vim.cmd.LspStart 'clangd'
end)
