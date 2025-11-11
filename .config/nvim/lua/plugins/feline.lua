local M = {
	'famiu/feline.nvim',
	dependencies = { 'kyazdani42/nvim-web-devicons', 'nerdcontrast.nvim' },
	event = 'VeryLazy',
}
function M.config()
	vim.o.laststatus = 3
	local mode_color = {
		n = 'Magenta',
		i = 'Green',
		v = 'Yellow',
		[''] = 'Yellow',
		V = 'Yellow',
		c = 'LightBlue',
		t = 'Red',
		no = 'Violet',
		s = 'LightCyan',
		S = 'LightCyan',
		[''] = 'LightCyan',
		ic = 'Cyan',
		R = 'Orange',
		Rv = 'Orange',
	}
	require('feline').setup {
		force_inactive = {
			filetypes = { '^NvimTree', '^dap.*', '^packer', '^alpha', '^help', '^rnvimr' },
		},
		components = {
			active = {
				{
					{
						provider = '▊',
						hl = function() return { fg = mode_color[vim.fn.mode()] } end,
					},
					{
						provider = { name = 'file_type', opts = { filetype_icon = true } },
						enabled = function() return vim.bo.filetype ~= '' end,
						left_sep = ' ',
						right_sep = ' ',
					},
				},
				{
					{
						provider = function() return tostring(#vim.lsp.get_clients { bufnr = 0 }) end,
						icon = ' ',
						hl = { fg = 'Fg4' },
					},
				},
				{
					{
						provider = 'diagnostic_errors',
						icon = ' ',
						hl = { fg = 'Red' },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_warnings',
						icon = ' ',
						hl = { fg = 'Orange' },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_hints',
						icon = ' ',
						hl = { fg = 'Fg5' },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_info',
						icon = ' ',
						hl = { fg = 'Olive' },
						right_sep = ' ',
					},
					{
						provider = function() return (vim.bo.et and '_' or 't') .. vim.bo.sw end,
						hl = { fg = 'Yellow' },
						right_sep = ' ',
					},
					{
						provider = function()
							return string.format(
								'<%d %d:%d/%d',
								vim.bo.tw,
								vim.fn.line '.',
								vim.fn.virtcol '.',
								vim.fn.line '$'
							)
						end,
						hl = { fg = 'Fg4' },
						right_sep = ' ',
					},
				},
			},
			inactive = {
				{},
				{
					{
						provider = { name = 'file_type', opts = { filetype_icon = true } },
					},
				},
				{},
			},
		},
	}
	local _ = require('nerdcontrast.plugs.feline').feline.fg
end
return M
