local M = {
	'JosefLitos/nerdcontrast.nvim',
	lazy = false,
	priority = 1000,
}
function M.config()
	local day = io.open('/tmp/day', 'r')
	if day then day:close() end
	vim.o.background = day and 'light' or 'dark'
	require('nerdcontrast').setup {
		bg = false,
		export = 1,
		overlay = true,
		opacity = vim.o.background == 'light' and 'ff' or 'cc',
	}
	-- Dark/Light theme toggle
	map('n', '<Leader>t', function()
		vim.o.background = vim.o.background == 'light' and 'dark' or 'light'
		require('nerdcontrast').setup { opacity = vim.o.background == 'light' and 'ff' or 'cc' }
	end)
end
return M
