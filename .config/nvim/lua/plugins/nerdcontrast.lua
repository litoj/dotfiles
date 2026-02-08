local M = { 'litoj/nerdcontrast.nvim', lazy = false, priority = 72 }
function M.config()
	vim.o.bg = exists '/tmp/my/day' and 'light' or 'dark'
	require('nerdcontrast').setup {
		export = true,
		light = {
			opacity = 'ff',
			palette = { override = { Bg1 = { bg = '#f5f5f5' }, Bg2 = {
				bg = '#ffffff',
			} } },
		},
		dark = { opacity = 'dd' },
		theme = { override = { StatusLine = 'Bg0', Visual = 'BgBlue', Parameter = 'FgGreen' } },
	}
	-- Dark/Light theme toggle
	map('n', ' mt', function() vim.o.bg = vim.o.bg == 'light' and 'dark' or 'light' end)
	map('n', ' mb', function()
		local matcher = {
			luapat = '(#[a-z0-9]+)',
			use = function(match) vim.api.nvim_set_hl(0, 'Normal', { bg = match }) end,
		}
		local ev = {
			filter = {
				tolerance = { startPost = 100, endPre = 100 }, -- allow match anywhere on the line
			},
		}
		require('reform.util').apply_matcher(matcher, ev)
	end, { desc = 'update bg colour to the one under cursor' })
	map('n', ' mT', function()
		local nc = require 'nerdcontrast'
		local theme = nc.config[vim.go.background].theme == 'nc_christmas' and 'nc' or 'nc_christmas'
		nc.setup { theme = theme }
	end, { desc = 'toggle theme between nc and nc_christmas' })
end

return {
	M,
	{
		'catgoose/nvim-colorizer.lua',
		keys = ' mC',
		opts = {
			user_default_options = {
				names = false,
				names_custom = function()
					local palette = require('nerdcontrast').palette
					local ret = {}
					for k, v in pairs(palette) do
						if palette[k] ~= 'NONE' then ret[k] = v end
					end
					return ret
				end,
				mode = 'foreground',
				virtualtext_inline = true,
				virtualtext = '■ [Test{c:o<=d|&e()}]',
				virtualtext_mode = 'background',
			},
		},
		config = function(_, opts)
			local c = require 'colorizer'
			local custom = opts.user_default_options.names_custom
			c.setup(opts)
			map('n', '<Leader>mC', function()
				local state = opts.user_default_options.mode
				local modes = { 'foreground', 'background', 'off' }
				for i, v in ipairs(modes) do
					if v == state then
						state = modes[(i % 3) + 1]
						break
					end
				end
				opts.user_default_options.mode = state
				if state == 'off' then
					c.detach_from_buffer(0)
					return
				end

				opts.user_default_options.names_custom = custom
				c.setup(opts)
				c.attach_to_buffer(0, opts.user_default_options)
			end)
		end,
	},
}
