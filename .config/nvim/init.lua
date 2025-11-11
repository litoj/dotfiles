require 'settings'

_G.map = vim.keymap.set

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
function _G.exists(f)
	f = io.open(f)
	if f then f:close() end
	return f ~= nil
end

function _G.withMod(mod, cb)
	if package.loaded[mod] then return cb(package.loaded[mod]) end
	local old = package.preload[mod]
	package.preload[mod] = function()
		package.preload[mod] = nil
		if old then
			old()
		else
			package.loaded[mod] = nil
			package.loaded[mod] = package.loaders[2](mod)()
		end
		vim.schedule(function() cb(package.loaded[mod]) end)
	end
end

-- determine whether to disable some functionality
local f = io.open '/sys/class/power_supply/BAT0/status'
vim.g.features_level = (os.getenv 'USER' ~= 'root' and 1 or 0) -- only for unprivileged user
	+ (f and f:read '*l' ~= 'Discharging' and 2 or 0) -- only when plugged in
	+ (exists(os.getenv 'HOME' .. '/Documents/work') and 4 or 0) -- only on the main system
if f then f:close() end

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
		patterns = { 'litoj' },
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
