local M = { 'goolord/alpha-nvim', keys = '<C-n>' }
function M.config()
	local function buttons(name, btns)
		local home = os.getenv 'HOME'
		local group = { type = 'group', val = { { type = 'text', val = '  ' .. name, opts = {} } } }
		local key
		if name:byte(1) == 91 then
			key = string.char(name:byte(2) + 32)
			group.val[1].opts.hl = { { 'LightRed', 2, 5 }, { 'LightBlue', 3, 4 }, { 'Title', 5, -1 } }
		else
			key = ''
			group.val[1].opts.hl = 'Title'
		end
		for i, val in ipairs(btns) do
			val[2] = val[2]:gsub(home .. '/?', '~/')
			local path = val[2]:match '.*/'
			local cmd = 'cd ' .. path .. '|e ' .. val[2]
			local hi = {
				{ '.*/nvim/lua/', ' ', 'Cyan' },
				{ '.*/.config/', ' ', 'Orange' },
				{ '~/Documents/work/', '󱫋 ', 'LightBlue' },
				{ '~/Documents/school/', '󰑴 ', 'Blue' },
				{ '.*/nvim/[^/]+/lua/', ' ', 'Green' },
				{ '.*/nvim/', ' ', 'Green' },
				{ '~/Documents/personal/', '󰚝 ', 'Magenta' },
			}
			local hlCol = 'FloatTitle'
			local hlStart = 2
			for _, kind in ipairs(hi) do
				if val[2]:find(kind[1]) then
					val[2] = val[2]:gsub(kind[1], kind[2])
					hlCol = kind[3]
					hlStart = #kind[2]
					break
				end
			end
			if hlCol == 'FloatTitle' then hlStart = val[2]:find '/' end

			local filename = val[2]:match '[^/]*$'
			local hlPath = #val[2] - #filename
			local hlFt = filename:find('.', nil, true)
			if hlFt then
				hlFt = hlFt + hlPath - 1
			else
				hlFt = #val[2]
			end

			group.val[i + 2] = {
				type = 'button',
				val = val[2],
				on_press = function() vim.api.nvim_command(cmd) end,
				opts = {
					keymap = { 'n', key .. val[1], ':' .. cmd .. '<CR>', { silent = true, nowait = true } },
					position = 'left',
					shortcut = '   [' .. val[1] .. ']' .. (' '):rep(4 - #val[1]),
					cursor = 1,
					align_shortcut = 'left',
					hl_shortcut = { { 'LightRed', 3, #val[1] + 5 }, { 'LightBlue', 4, #val[1] + 4 } },
					hl = {
						{ hlCol, 0, hlStart },
						{ 'Fg3', hlStart, hlPath },
						{ 'LightRed', hlFt, hlFt + 1 },
						{ 'Fg1', hlFt + 1, -1 },
					},
				},
			}
		end
		group.val[#group.val + 1] = { type = 'padding', val = 1 }
		return group
	end

	local function oldfiles(max)
		local recent = {}
		for _, v in ipairs(vim.v.oldfiles) do
			if exists(v) and not v:find('.git/', 1, true) then
				recent[#recent + 1] = { '' .. #recent, v }
				if #recent == max then break end
			end
		end
		return buttons('Recent', recent)
	end

	local config = {
		layout = {
			{
				type = 'group',
				val = function()
					map('n', 'q', function() vim.api.nvim_buf_delete(0, {}) end, { buffer = true })
					map('n', '<Esc>', 'q', { remap = true, buffer = true })
					map('n', '<Right>', '<CR>', { remap = true, buffer = true })
					map('n', 'l', '<CR>', { remap = true, buffer = true })
					return { oldfiles(10) }
				end,
			},
			buttons('Bookmarks', {
				{ 'dp', '~/Documents/personal/' },
				{ 'ds', '~/Documents/school/' },
				{ 'dw', '~/Documents/work/' },
				{ 'dn', '~/Documents/personal/nvim/' },
				{ 'nn', '~/Documents/personal/nvim/nerdcontrast.nvim/lua/nerdcontrast/' },
				{ 'nr', '~/Documents/personal/nvim/reform.nvim/' },
			}),
			buttons('[P]rojects', {
				{ 'p', '~/Documents/school/PG/' },
				{ 'k', '~/Documents/school/PG/Theory/KAB/' },
				{ 's', '~/Documents/school/PG/SP/' },
			}),
			buttons('[C]onfigs', {
				{ 'c', '~/dotfiles/.config/' },
				{ 'n', '~/.config/nvim/lua/' },
				{ 's', '~/.config/sway/' },
				{ 'i', '~/.config/swayimg/config' },
				{ 'b', '~/.config/i3blocks/' },
				{ 'r', '~/.config/ranger/' },
				{ 'f', '~/.config/fish/config.fish' },
			}),
		},
	}
	local alpha = require 'alpha'
	alpha.setup(config)

	map({ '', 'i' }, '<C-n>', alpha.start)
end
return M
