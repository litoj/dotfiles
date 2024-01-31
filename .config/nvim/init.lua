require 'settings'

_G.map = vim.keymap.set

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
function _G.exists(f)
	f = io.open(f)
	if f then
		f:close()
		return true
	else
		return false
	end
end
if not exists(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'--depth=1',
		'https://github.com/folke/lazy.nvim.git',
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup {
	change_detection = { enabled = false },
	defaults = { lazy = true },
	dev = {
		path = '/home/kepis/Documents/personal/nvim',
		patterns = { 'JosefLitos' },
		fallback = true,
	},
	lockfile = vim.fn.stdpath 'state' .. '/lazy-lock.json',
	performance = {
		cache = { enabled = false },
		rtp = {
			disabled_plugins = {
				'gzip',
				'matchit',
				-- 'matchparen',
				'netrwPlugin',
				'tarPlugin',
				'tohtml',
				'tutor',
				'zipPlugin',
			},
		},
	},
	readme = { enabled = false },
	spec = 'plugins',
}

vim.api.nvim_create_autocmd('User', {
	pattern = 'VeryLazy',
	once = true,
	callback = function()
		require 'autocommands'
		require 'keymappings'
	end,
})
