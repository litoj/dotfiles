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
		update_focused_file = { enable = true, update_root = true, ignore_list = { 'term://' } },
		sync_root_with_cwd = true,
		filters = {
			dotfiles = true,
			custom = { '.git$', 'node_modules', '.cache' },
			exclude = { '.config', '.scripts' },
		},
		renderer = {
			indent_markers = { enable = true },
			icons = { show = { git = false } },
			root_folder_label = label,
			group_empty = label,
		},
		actions = {
			open_file = { quit_on_open = true, window_picker = { enable = true } },
			change_dir = { global = true },
			file_popup = { open_win_config = { border = 'single', col = -1 } },
		},
		on_attach = function(bufnr)
			-- vim.wo.wrap = true
			local function map(keys, fn)
				if type(keys) == 'table' then
					for _, key in pairs(keys) do
						vim.keymap.set('n', key, fn, { buffer = bufnr, nowait = true })
					end
				else
					vim.keymap.set('n', keys, fn, { buffer = bufnr, nowait = true })
				end
			end
			map({ 'h', '<Left>' }, api.tree.change_root_to_parent)
			map({ 'l', '<Right>', '<CR>' }, api.node.open.edit)
			map({ 'K', ',' }, api.node.navigate.sibling.prev)
			map({ 'J', '.' }, api.node.navigate.sibling.next)
			map({ '<A-k>', '<' }, api.node.navigate.parent)
			map({ '<A-j>', '>' }, function()
				api.node.navigate.parent()
				api.node.navigate.sibling.next()
			end)
			map('-', api.node.navigate.parent_close)
			map('+', api.tree.expand_all)
			map('_', api.tree.collapse_all)
			map({ '<C-h>', '<BS>' }, api.tree.toggle_hidden_filter)
			map('<C-g>', api.tree.toggle_gitignore_filter)
			map('<F5>', api.tree.reload)
			map({ 'n', '<C-n>' }, api.fs.create)
			map({ 'D', '<Del>' }, api.fs.remove)
			map({ 'X', '<C-x>' }, api.fs.cut)
			map({ 'C', '<C-c>' }, api.fs.copy.node)
			map({ 'V', '<C-v>' }, api.fs.paste)
			map({ 'R', '<F2>' }, api.fs.rename)
			map('q', vim.cmd.bwipeout)
			map({ 'cd', 'O', '<S-CR>' }, api.tree.change_root_to_node)
			map('<A-i>', api.node.show_info_popup)
			map('S', api.node.run.cmd)
			map('<A-Tab>', '<C-w>l')
		end,
	}

	map('n', '<A-Tab>', api.tree.open)
	local file = vim.api.nvim_buf_get_name(0)
	if vim.fn.isdirectory(file) == 1 then
		vim.loop.chdir(file)
		api.tree.open()
	end
end
return M
