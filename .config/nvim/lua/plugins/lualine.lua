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
		SLOlive = { bg = 'StatusLine', fg = 'Olive' },
		SLBg = { bg = 'StatusLine' },
	}
	require('lualine').setup {
		options = {
			theme = 'nerdcontrast',
			sections_separators = { left = ' ', right = ' ' },
			component_separators = { left = '', right = '' },
			disabled_filetypes = {
				statusline = { 'NvimTree', 'lazy', 'alpha', 'help', 'rnvimr' },
			},
			always_divide_middle = false,
			icon = false,
		},
		sections = {
			lualine_a = { { function() return '▊' end, padding = 0 } },
			lualine_b = { { 'filetype', color = 'SLBg' } },
			lualine_c = {
				{
					function() return #vim.lsp.get_active_clients { bufnr = 0 } end,
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
						warn = 'SLYellow',
						info = 'SLOlive',
						hint = 'StatusLineDef',
					},
				},
			},
			lualine_y = {
				{ function() return (vim.bo.et and '_' or 't') .. vim.bo.ts end, color = 'SLYellow' },
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
