local M = { 'JosefLitos/nerdcontrast.nvim', lazy = false, priority = 72 }
function M.config()
	vim.o.bg = exists '/tmp/my/day' and 'light' or 'dark'
	require('nerdcontrast').setup {
		export = true,
		light = { opacity = 'ff' },
		dark = { opacity = 'cc' },
		theme = { override = { StatusLine = 'Bg0' } },
	}
	-- Dark/Light theme toggle
	map('n', '<Leader>t', function() vim.o.bg = vim.o.bg == 'light' and 'dark' or 'light' end)
end
return M
