local M = { 'folke/flash.nvim', keys = { '<A-q>', '<A-f>', '?' } }
function M.config()
	local flash = require 'flash'
	flash.setup {
		search = { multi_window = false, incremental = true },
		jump = { nohlsearch = true, pos = 'end', autojump = true },
		prompt = { win_config = { relative = 'cursor', row = -3, border = 'rounded' } },
		modes = {
			char = { enabled = false },
			treesitter_search = { search = { incremental = true } },
		},
	}
	map('n', '<A-q>', flash.treesitter_search)
	map('i', '<A-q>', '<C-o><A-q>', { remap = true }) -- to avoid selection in insert mode
	map('n', '<A-f>', flash.jump)
	map('i', '<A-f>', '<C-o><A-f>', { remap = true })
	map('v', '<A-s>', 'o<Esc>i')
	map('v', '<A-e>', 'A')
end
return M
