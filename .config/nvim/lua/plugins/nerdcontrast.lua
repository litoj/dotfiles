local M = {
	'JosefLitos/nerdcontrast.nvim',
	lazy = false,
	priority = 1000,
}
function M.config()
	local m = os.time() % 86400 / 60 + 120
	local dayF = io.open('/tmp/day', 'r')
	local rise = dayF:read '*n'
	local set = dayF:read '*n'
	dayF:close()
	vim.o.background = (rise < m and m < set) and 'light' or 'dark'
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
