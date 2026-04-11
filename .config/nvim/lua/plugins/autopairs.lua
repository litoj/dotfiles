local M = { 'windwp/nvim-autopairs', event = 'InsertEnter' }
M.opts = {
	-- map_cr = false,
	-- check_ts = true,
	ts_config = {
		lua = { 'string' }, -- it will not add pair on that treesitter node
		javascript = { 'template_string' },
	},
	disable_filetype = { 'rnvimr', 'NvimTree' },
	fast_wrap = {
		map = '<A-w>',
		chars = { '{', '[', '(', '"', "'", '`' },
		pattern = '[/+*%-%%)>%]},]',
		end_key = '$',
		before_key = 'q',
		after_key = 'e',
		keys = "qwertasdfgzxcvb12345[poiu';lkjh/.,mny-0987",
		check_comma = true,
		highlight = 'IncSearch',
		highlight_grey = '',
		use_virt_lines = false,
		check_ts = true,
	},
	ignored_next_char = '[^ .,)%]}]',
}
return M
