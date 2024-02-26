vim.g.barbar_auto_setup = false
local M = {
	'romgrk/barbar.nvim',
	dependencies = 'kyazdani42/nvim-web-devicons',
	event = 'VeryLazy',
}
function M.config()
	require('barbar').setup {
		animation = false,
		maximum_padding = 0,
		minimum_padding = 0,
		icons = {
			button = ' ✖',
			modified = { button = ' ●' },
			separator = { left = '▍' },
			inactive = { separator = { left = '▏' }, button = ' ' },
			visible = { button = ' ' },
		},
	}

	-- Moving between
	map('n', '<A-S-,>', '<Cmd>BufferMovePrevious<CR>')
	map('n', '<A-S-.>', '<Cmd>BufferMoveNext<CR>')
	map('n', ',', '<Cmd>BufferPrevious<CR>')
	map('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>')
	map('n', '.', '<Cmd>BufferNext<CR>')
	map('n', '<Tab>', '<Cmd>BufferNext<CR>')
	map({ 'i', 't' }, '<A-,>', '<Cmd>BufferPrevious<CR>')
	map({ 'i', 't' }, '<A-.>', '<Cmd>BufferNext<CR>')
	-- Closing
	local function close()
		local name = vim.api.nvim_buf_get_name(0)
		if
			name:find('.git/', 7, true)
			-- or name:match 'node_modules'
			-- or name:match '%.cache'
			or not exists(name)
		then
			vim.cmd.BufferWipeout()
		else
			vim.cmd.BufferClose() -- barbar commands keep window splits
		end
	end
	local modes = { 'n', 'i' }
	map(modes, '<C-w>', close)
	map('n', '<C-S-W>', '<Cmd>BufferClose!<CR>')
	map('i', '<C-S-W>', '<C-o><Cmd>BufferClose!<CR>')
	map('t', '<C-S-D>', '<C-d><C-\\><C-o><Cmd>BufferClose!<CR>')
	-- Direct selection
	map(modes, '<A-1>', '<Cmd>BufferGoto 1<CR>')
	map(modes, '<A-2>', '<Cmd>BufferGoto 2<CR>')
	map(modes, '<A-3>', '<Cmd>BufferGoto 3<CR>')
	map(modes, '<A-4>', '<Cmd>BufferGoto 4<CR>')
	map(modes, '<A-5>', '<Cmd>BufferGoto 5<CR>')
	map(modes, '<A-6>', '<Cmd>BufferGoto 6<CR>')
	map(modes, '<A-7>', '<Cmd>BufferGoto 7<CR>')
	map(modes, '<A-8>', '<Cmd>BufferGoto 8<CR>')
	map(modes, '<A-9>', '<Cmd>BufferGoto 9<CR>')
end
return M
