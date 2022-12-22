local M = { 'windwp/nvim-autopairs', event = 'InsertEnter', dependencies = 'nvim-cmp' }
function M.config()
	require('nvim-autopairs').setup {
		check_ts = true,
		ts_config = {
			lua = { 'string' }, -- it will not add pair on that treesitter node
			javascript = { 'template_string' },
		},
		disable_filetype = { 'TelescopePrompt', 'spectre_panel', 'rnvimr', 'NvimTree' },
		fast_wrap = {
			map = '<M-w>',
			chars = { '{', '[', '(', '"', "'", '`' },
			pattern = '[\'")>%]},:`]',
			offset = 0, -- Offset from pattern match
			end_key = '$',
			keys = 'qwertyuiopzxcvbnmasdfghjkl',
			check_comma = true,
			highlight = 'Search',
			highlight_grey = 'LineNr',
		},
	}

	local on_confirm_done = require('nvim-autopairs.completion.cmp').on_confirm_done
	local cmp = require 'cmp'
	cmp.event:on('confirm_done', on_confirm_done)
	cmp.event:off('confirm_done', on_confirm_done)
end
return M
