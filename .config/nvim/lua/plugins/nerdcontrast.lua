local M = { 'JosefLitos/nerdcontrast.nvim', lazy = false, priority = 72 }
function M.config()
	local day = io.open('/tmp/my/day', 'r')
	if day then day:close() end
	vim.o.bg = day and 'light' or 'dark'
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
