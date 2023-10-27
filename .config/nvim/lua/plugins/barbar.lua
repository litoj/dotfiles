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
	map('n', '<M-S-,>', '<Cmd>BufferMovePrevious<CR>')
	map('n', '<M-S-.>', '<Cmd>BufferMoveNext<CR>')
	map('n', ',', '<Cmd>BufferPrevious<CR>')
	map('i', '<M-,>', '<C-o><Cmd>BufferPrevious<CR>')
	map('t', '<M-,>', '<C-\\><C-o><Cmd>BufferPrevious<CR>')
	map('n', '.', '<Cmd>BufferNext<CR>')
	map('i', '<M-.>', '<C-o><Cmd>BufferNext<CR>')
	map('t', '<M-.>', '<C-\\><C-o><Cmd>BufferNext<CR>')
	map('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>')
	map('n', '<Tab>', '<Cmd>BufferNext<CR>')
	-- Closing
	map('n', '<C-w>', '<Cmd>bdelete<CR>')
	map('i', '<C-w>', '<C-o><Cmd>bdelete<CR>')
	map('n', '<C-S-W>', '<Cmd>bdelete!<CR>')
	map('i', '<C-S-W>', '<C-o><Cmd>bdelete!<CR>')
	map('t', '<C-S-D>', '<C-d><C-\\><C-o><Cmd>bdelete!<CR>')
	-- Direct selection
	map({ 'n', 'i' }, '<M-1>', '<Cmd>BufferGoto 1<CR>')
	map({ 'n', 'i' }, '<M-2>', '<Cmd>BufferGoto 2<CR>')
	map({ 'n', 'i' }, '<M-3>', '<Cmd>BufferGoto 3<CR>')
	map({ 'n', 'i' }, '<M-4>', '<Cmd>BufferGoto 4<CR>')
	map({ 'n', 'i' }, '<M-5>', '<Cmd>BufferGoto 5<CR>')
	map({ 'n', 'i' }, '<M-6>', '<Cmd>BufferGoto 6<CR>')
	map({ 'n', 'i' }, '<M-7>', '<Cmd>BufferGoto 7<CR>')
	map({ 'n', 'i' }, '<M-8>', '<Cmd>BufferGoto 8<CR>')
	map({ 'n', 'i' }, '<M-9>', '<Cmd>BufferGoto 9<CR>')
end
return M
