local M = { 'kyazdani42/nvim-tree.lua', event = 'VeryLazy' }
function M.config()
	local api = require 'nvim-tree.api'
	local function label(path)
		path = path:gsub(os.getenv 'HOME', '~', 1)
		return path:gsub('([a-zA-Z])[a-z0-9]+', '%1') .. (path:match '[a-zA-Z]([a-z0-9]*)$' or '')
	end
	local nt = require 'nvim-tree'
	nt.setup {
		disable_netrw = true,
		respect_buf_cwd = true,
		update_focused_file = {
			enable = true,
			update_root = { enable = true },
			ignore_list = { 'term://' },
		},
		sync_root_with_cwd = true,
		filters = {
			dotfiles = true,
			custom = { '^.git$', '^node_modules$', '^\\.cache$' },
			exclude = { '.config', '.scripts' },
		},
		renderer = {
			indent_markers = { enable = true },
			icons = { show = { git = false } },
			root_folder_label = label,
			group_empty = label,
			highlight_opened_files = 'all',
		},
		actions = {
			open_file = { quit_on_open = true, window_picker = { enable = true } },
			change_dir = { global = true },
			file_popup = { open_win_config = { border = 'single', col = -1 } },
			expand_all = { max_folder_discovery = 100, exclude = {} },
		},
		on_attach = function(bufnr)
			-- vim.wo.wrap = true
			local function map(keys, fn)
				for _, key in ipairs(keys[1] and keys or { keys }) do
					vim.keymap.set('n', key, fn, { buffer = bufnr, nowait = true })
				end
			end
			map({ 'h', '<Left>' }, api.tree.change_root_to_parent)
			map({ 'l', '<Right>', '<CR>' }, api.node.open.edit)
			map({ '<A-k>', ',' }, api.node.navigate.sibling.prev)
			map({ '<A-j>', '.' }, api.node.navigate.sibling.next)
			map({ 'K', '<' }, api.node.navigate.parent)
			map({ 'J', '>' }, function()
				api.node.navigate.parent()
				api.node.navigate.sibling.next()
			end)

			map('<Tab>', api.node.open.preview)
			map({ 'E', '=' }, api.tree.expand_all)
			map('+', function()
				local cursor = vim.api.nvim_win_get_cursor(0)
				vim.api.nvim_win_set_cursor(0, { 1, 0 })
				api.tree.expand_all()
				vim.api.nvim_win_set_cursor(0, cursor)
			end)
			map('F', function()
				vim.api.nvim_win_set_cursor(0, { 1, 0 })
				api.tree.expand_all()
				api.filter.live.start()
			end)
			map('/', function()
				vim.api.nvim_win_set_cursor(0, { 1, 0 })
				api.tree.expand_all()

				vim.api.nvim_feedkeys('/', 'n', false)
				vim.keymap.set('c', '<CR>', function()
					if vim.fn.getcmdtype() == '/' then
						vim.schedule(function()
							api.node.open.edit()
							vim.cmd.nohlsearch()
						end)
					end
					return '<CR>'
				end, { expr = true, buffer = true })
			end)
			map('-', api.node.navigate.parent_close)
			map('_', api.tree.collapse_all)

			map({ '<C-h>', '<BS>' }, api.filter.dotfiles.toggle)
			map('<C-g>', api.filter.git.ignored.toggle)
			map('<F5>', api.tree.reload)
			map({ 'n', '<C-n>' }, api.fs.create)
			map({ 'D', '<Del>' }, api.fs.remove)
			map({ 'X', '<C-x>' }, api.fs.cut)
			map({ 'C', '<C-c>' }, api.fs.copy.node)
			map({ 'V', '<C-v>' }, api.fs.paste)
			map({ 'R', '<F2>' }, api.fs.rename)
			map('q', vim.cmd.bwipeout)
			map('<Esc>', function()
				-- Check if live filter is active by looking for filter prefix in first line
				local first_line = vim.api.nvim_buf_get_lines(0, 1, 2, false)[1] or ''
				if first_line:match '%[FILTER%]:' then
					api.filter.live.clear()
				else
					api.tree.close()
				end
			end)
			map({ 'cd', 'O', '<S-CR>' }, api.tree.change_root_to_node)
			map('<A-i>', api.node.show_info_popup)
			map('S', function()
				local cwd = vim.uv.cwd()
				vim.api.nvim_set_current_dir(
					vim.api.tree.get_node_under_cursor().absolute_path:match '(.+/)'
				)
				vim.cmd.terminal()
				vim.api.nvim_set_current_dir(cwd)
				vim.cmd.startinsert()
			end)
			map('s', api.node.run.cmd)
			map('<A-Tab>', '<C-w>l')
		end,
	}

	map('n', '<A-Tab>', function() api.tree.open { find_file = true } end)
	local file = vim.api.nvim_buf_get_name(0)
	if vim.fn.isdirectory(file) == 1 then
		vim.api.nvim_set_current_dir(file)
		api.tree.open()
	end
end
return M
