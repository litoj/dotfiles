local M = {
	'freddiehaddad/feline.nvim',
	dependencies = { 'kyazdani42/nvim-web-devicons', 'nerdcontrast.nvim' },
	event = 'VeryLazy',
}
function M.config()
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
						update = { 'ModeChanged' },
						hl = function() return { fg = mode_color[vim.fn.mode()] } end,
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
						provider = function() return (vim.bo.et and '_' or 't') .. vim.bo.ts end,
						hl = { fg = 'Yellow' },
						right_sep = ' ',
					},
					{
						provider = function()
							return vim.fn.line '.' .. ':' .. vim.fn.virtcol '.' .. '/' .. vim.fn.line '$'
						end,
						hl = { fg = 'Green' },
						right_sep = ' ',
					},
					{
						provider = function() return math.modf(vim.fn.line '.' * 100 / vim.fn.line '$') .. '%%' end,
						update = { 'CursorMoved', 'CursorMovedI' },
						hl = { fg = 'Cyan' },
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
	local _ = require('nerdcontrast.plugs.feline').feline.fg
end
return M
