local M = { 'HiPhish/rainbow-delimiters.nvim', ft = { 'markdown', 'txt', 'scheme' } }
function M.config()
	local rd = require 'rainbow-delimiters'
	vim.g.rainbow_delimiters = {
		strategy = {
			[''] = rd.strategy.noop,
			markdown = rd.strategy['local'],
			scheme = rd.strategy['local'],
			racket = rd.strategy['local'],
		},
		highlight = {
			'LightRed',
			'LightMagenta',
			'LightOrange',
			'LightOlive',
			'Cyan',
		},
	}
end
return M
