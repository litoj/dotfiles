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
	map('n', '<S-Tab>', '<Cmd>BufferPrevious<CR>')
	map('n', '.', '<Cmd>BufferNext<CR>')
	map('n', '<Tab>', '<Cmd>BufferNext<CR>')
	map({ 'i', 't' }, '<M-,>', '<Cmd>BufferPrevious<CR>')
	map({ 'i', 't' }, '<M-.>', '<Cmd>BufferNext<CR>')
	-- Closing
	local function close()
		local name = vim.api.nvim_buf_get_name(0)
		if
			name:find('.git/', 7, true)
			-- or name:match 'node_modules'
			-- or name:match '%.cache'
			or not vim.loop.fs_stat(name)
		then
			vim.cmd.bwipeout()
		else
			vim.cmd.bdelete()
		end
	end
	local modes = { 'n', 'i' }
	map(modes, '<C-w>', close)
	map('n', '<C-S-W>', '<Cmd>bdelete!<CR>')
	map('i', '<C-S-W>', '<C-o><Cmd>bdelete!<CR>')
	map('t', '<C-S-D>', '<C-d><C-\\><C-o><Cmd>bdelete!<CR>')
	-- Direct selection
	map(modes, '<M-1>', '<Cmd>BufferGoto 1<CR>')
	map(modes, '<M-2>', '<Cmd>BufferGoto 2<CR>')
	map(modes, '<M-3>', '<Cmd>BufferGoto 3<CR>')
	map(modes, '<M-4>', '<Cmd>BufferGoto 4<CR>')
	map(modes, '<M-5>', '<Cmd>BufferGoto 5<CR>')
	map(modes, '<M-6>', '<Cmd>BufferGoto 6<CR>')
	map(modes, '<M-7>', '<Cmd>BufferGoto 7<CR>')
	map(modes, '<M-8>', '<Cmd>BufferGoto 8<CR>')
	map(modes, '<M-9>', '<Cmd>BufferGoto 9<CR>')
end
return M
