map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!compiler %:p<CR><CR>', { buffer = true })
map(
	{ 'n', 'i' },
	'<A-B>',
	'<Cmd>w|!make debug||g++ -std=c++17 -Wall -pedantic -g -fsanitize=address,leak -DDEBUG %:p -o %:p:r.out<CR>',
	{ buffer = true }
)
map({ 'n', 'i' }, '<A-M>', '<Cmd>w|!cd %:h && make<CR>', { buffer = true })

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
				return name:gsub('%.[chp]+$', '.out')
				-- LSAN_OPTIONS=verbosity=1:log_threads=1 gdb...
			end,
		},
	}
end)

withMod('mylsp', function(ml) ml.setup 'clangd' end)
