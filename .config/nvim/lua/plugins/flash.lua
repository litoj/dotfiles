local M = { 'folke/flash.nvim', keys = { '<M-q>', '<M-f>', '?' } }
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
	map('n', '<M-q>', flash.treesitter_search)
	map('i', '<M-q>', '<C-o><M-q>', { remap = true }) -- to avoid selection in insert mode
	map('n', '<M-f>', flash.jump)
	map('i', '<M-f>', '<C-o><M-f>', { remap = true })
	map('v', '<M-s>', 'o<Esc>i')
	map('v', '<M-e>', 'A')
end
return M
