local M = { 'numToStr/Comment.nvim', event = 'VeryLazy' }
function M.config()
	require('Comment').setup {
		ignore = '^$',
		padding = true,
		mappings = { basic = true, extra = false },
	}
	local opt = { remap = true, silent = true }
	map('n', '<C-S-C>', 'gcc', opt)
	map('v', '<C-S-C>', 'gc', opt)
	map('i', '<C-S-C>', '<C-o>gcc', opt)
end
return M
