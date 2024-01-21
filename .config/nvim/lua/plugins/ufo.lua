local M = {
	'kevinhwang91/nvim-ufo',
	dependencies = 'kevinhwang91/promise-async',
	event = 'BufEnter',
}
function M.config()
	local ufo = require 'ufo'
	ufo.setup {
		open_fold_hl_timeout = 0,
		provider_selector = function(buf, ft, type)
			return ft == 'markdown' and 'indent' or { 'treesitter', 'indent' }
		end,
	}
	vim.o.fdl = 99
	vim.o.fdls = 99
	vim.o.fen = true
	vim.o.fml = 4
	map('n', '_', ufo.closeAllFolds)
	map('n', '+', ufo.openAllFolds)
	map('n', '-', 'za')
	map('n', '=', 'zA')
	map('n', 'K', ufo.peekFoldedLinesUnderCursor)
end
return M
