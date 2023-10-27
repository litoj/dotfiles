local M = {
	'feline-nvim/feline.nvim',
	dependencies = 'kyazdani42/nvim-web-devicons',
	event = 'VeryLazy',
}
function M.config()
	local colors = require('nerdcontrast').palette
	local mode_color = {
		n = 'Magenta',
		i = 'Green',
		v = 'Yellow',
		[''] = 'Yellow',
		V = 'Yellow',
		c = 'LightBlue',
		t = 'Red',
		no = 'LightMagenta',
		s = 'LightCyan',
		S = 'LightCyan',
		[''] = 'LightCyan',
		ic = 'Cyan',
		R = 'Orange',
		Rv = 'Orange',
	}
	local fl = require 'feline'
	fl.setup {
		force_inactive = {
			filetypes = { '^NvimTree', '^dap.*', '^packer', '^alpha', '^help', '^rnvimr' },
		},
		components = {
			active = {
				{
					{
						provider = '▊',
						update = { 'ModeChanged' },
						hl = function() return { fg = colors[mode_color[vim.fn.mode()]][1] } end,
					},
					{
						provider = { name = 'file_type', opts = { filetype_icon = true } },
						enabled = function() return vim.bo.filetype ~= '' end,
						update = { 'FileType' },
						left_sep = ' ',
						right_sep = ' ',
					},
				},
				{
					{
						provider = 'lsp_client_names',
						truncate_hide = true,
						icon = ' ',
						update = { 'FileType' },
						hl = { fg = colors.Fg4[1] },
					},
				},
				{
					{
						provider = 'diagnostic_errors',
						icon = ' ',
						hl = { fg = colors['Red'][1] },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_warnings',
						icon = ' ',
						hl = { fg = colors['Orange'][1] },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_hints',
						icon = ' ',
						hl = { fg = colors['Fg5'][1] },
						right_sep = ' ',
					},
					{
						provider = 'diagnostic_info',
						icon = ' ',
						hl = { fg = colors['LightOlive'][1] },
						right_sep = ' ',
					},
					{
						provider = function() return (vim.bo.et and '_' or 't') .. vim.bo.sw end,
						hl = { fg = colors['Yellow'][1] },
						right_sep = ' ',
					},
					{
						provider = function()
							return vim.fn.line '.' .. ':' .. vim.fn.virtcol '.' .. '/' .. vim.fn.line '$'
						end,
						hl = { fg = colors['Green'][1] },
						right_sep = ' ',
					},
					{
						provider = function()
							return math.modf(vim.fn.line '.' * 100 / vim.fn.line '$') .. '%%'
						end,
						update = {'CursorMoved', 'CursorMovedI'},
						hl = { fg = colors['Cyan'][1] },
						right_sep = ' ',
					},
				},
			},
			inactive = {
				{},
				{
					{
						provider = { name = 'file_type', opts = { filetype_icon = true } },
						update = {
							'FileType',
						},
					},
				},
				{},
			},
		},
	}
	fl.use_theme { fg = colors.Fg1[1], bg = colors.Bg2[1] }
end
return M
