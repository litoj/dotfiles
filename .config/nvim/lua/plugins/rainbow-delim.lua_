local M = { 'HiPhish/rainbow-delimiters.nvim', ft = { 'markdown', 'txt', 'scheme' } }
function M.config()
	local rd = require 'rainbow-delimiters'
	vim.g.rainbow_delimiters = {
		strategy = {
			[''] = rd.strategy.noop,
			markdown = rd.strategy.global,
			scheme = rd.strategy.global,
			racket = rd.strategy.global,
		},
		highlight = {
			'LightRed',
			'LightViolet',
			'LightOrange',
			'LightMagenta',
			'LightCyan',
			'Yellow',
		},
	}
end
return M
