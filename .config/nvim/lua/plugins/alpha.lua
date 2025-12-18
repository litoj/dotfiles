local M = { 'goolord/alpha-nvim', keys = '<C-n>' }
function M.config()
	local alpha = require 'alpha'
	local function dashboard()
		vim.g.old_buf = vim.api.nvim_get_current_buf()
		alpha.start()

		vim.bo.bufhidden = nil
		-- FIXME: this fails with bg tasks making windows (spinner)
		_G.protectWindow = #vim.api.nvim_list_wins() > 1

		require 'autocommands'('BufLeave', function(state)
			vim.bo[state.buf].bufhidden = 'wipe'
			vim.g.old_buf = nil
		end, vim.api.nvim_get_current_buf())

		map('n', 'q', function() vim.api.nvim_set_current_buf(vim.g.old_buf) end, { buffer = true })
		map('n', '<Esc>', 'q', { remap = true, buffer = true })
		map('n', '<Right>', '<CR>', { remap = true, buffer = true })
		map('n', 'l', '<CR>', { remap = true, buffer = true })
	end

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

			local file = val[2]
			local cmd = function()
				if _G.protectWindow and path == file then -- dirs open NvimTree and discard current window
					vim.api.nvim_set_current_buf(vim.g.old_buf)
					vim.cmd.split()
				end
				vim.cmd.cd(path)
				vim.cmd.edit(file)
			end

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
				on_press = cmd,
				opts = {
					keymap = { 'n', key .. val[1], cmd, { silent = true, nowait = true } },
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
				val = function() return { oldfiles(10) } end,
			},
			buttons('Bookmarks', {
				{ 'dp', '~/Documents/personal/' },
				{ 'ds', '~/Documents/school/' },
				{ 'dw', '~/Documents/work/' },
				{ 'dn', '~/Documents/personal/nvim/' },
				{ 'nn', '~/Documents/personal/nvim/nerdcontrast.nvim/lua/nerdcontrast/' },
				{ 'nr', '~/Documents/personal/nvim/reform.nvim/' },
				{ 'nm', '~/Documents/personal/nvim/manipulator.nvim/lua/manipulator/'}
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
	alpha.setup(config)

	map({ '', 'i' }, '<C-n>', dashboard)
end
return M
