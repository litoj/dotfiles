require 'settings'

_G.map = vim.keymap.set
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'--single-branch',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
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
	install = { colorscheme = { 'nerdcontrast' } },
	lockfile = vim.fn.stdpath 'state' .. '/lazy-lock.json',
	performance = {
		rtp = {
			disabled_plugins = {
				'gzip',
				'matchit',
				-- "matchparen",
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
	callback = function()
		require 'keymappings'
		require 'autocommands'
	end,
})
