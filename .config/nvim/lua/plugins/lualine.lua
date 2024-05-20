local M = {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons', 'nerdcontrast.nvim' },
	event = 'VeryLazy',
}
function M.config()
	vim.o.laststatus = 3 -- show only one statusline at the bottom
	require('nerdcontrast').hi {
		SLRed = { bg = 'StatusLine', fg = 'Red' },
		SLYellow = { bg = 'StatusLine', fg = 'Yellow' },
		SLOrange = { bg = 'StatusLine', fg = 'LightOrange' },
		SLOlive = { bg = 'StatusLine', fg = 'Olive' },
		SLBg = { bg = 'StatusLine' },
	}
	require('lualine').setup {
		options = {
			theme = 'nerdcontrast',
			section_separators = { left = '', right = '' },
			component_separators = { left = '', right = '' },
			disabled_filetypes = {
				statusline = { 'NvimTree', 'lazy', 'alpha', 'help', 'rnvimr', 'fzf' },
			},
			always_divide_middle = false,
			icon = false,
		},
		sections = {
			lualine_a = { { function() return '▊' end, padding = 0 }, { 'filetype', color = 'SLBg' } },
			lualine_b = {},
			lualine_c = {
				{
					function() return #vim.lsp.get_clients { bufnr = 0 } end,
					icon = '%=',
				},
			},
			lualine_x = {
				{
					'diagnostics',
					sources = { 'nvim_diagnostic' },
					symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
					diagnostics_color = {
						error = 'SLRed',
						warn = 'SLOrange',
						info = 'SLOlive',
						hint = 'StatusLineDef',
					},
				},
			},
			lualine_y = {
				{
					function() return (vim.bo.et and '_' or 't') .. vim.bo.sw end,
					color = 'SLYellow',
				},
				{ function() return '<' .. vim.bo.tw end, padding = 0 },
			},
			lualine_z = {
				{
					function() return vim.fn.line '.' .. ':' .. vim.fn.virtcol '.' .. '/' .. vim.fn.line '$' end,
				},
			},
		},
	}
end
return M
