local M = { 'windwp/nvim-autopairs', event = 'InsertEnter', dependencies = 'nvim-cmp' }
function M.config()
	local nap = require 'nvim-autopairs'
	nap.setup {
		ts_config = {
			lua = { 'string' }, -- it will not add pair on that treesitter node
			javascript = { 'template_string' },
		},
		disable_filetype = { 'rnvimr', 'NvimTree' },
		fast_wrap = {
			map = '<A-w>',
			chars = { '{', '[', '(', '"', "'", '`' },
			pattern = '[ ,]',
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

	local on_confirm_done = require('nvim-autopairs.completion.cmp').on_confirm_done
	local cmp = require 'cmp' -- does line unwrap for blocks ({...})
	cmp.event:on('confirm_done', on_confirm_done)
	cmp.event:off('confirm_done', on_confirm_done)
end
return M
