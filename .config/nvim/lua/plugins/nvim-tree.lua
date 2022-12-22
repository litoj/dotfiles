local M = { 'kyazdani42/nvim-tree.lua', event = 'VeryLazy' }
function M.config()
	local api = require 'nvim-tree.api'
	require('nvim-tree').setup {
		disable_netrw = true,
		respect_buf_cwd = true,
		update_focused_file = { enable = true, update_root = true, ignore_list = { 'term://' } },
		sync_root_with_cwd = true,
		filters = { dotfiles = true, custom = { '.git', 'node_modules', '.cache' } },
		renderer = {
			indent_markers = { enable = true },
			icons = { show = { git = false } },
			root_folder_label = function(path)
				path = path:gsub(os.getenv 'HOME', '~', 1)
				return path:gsub('([a-zA-Z])[a-z]+', '%1') .. path:gsub('.*[^a-zA-Z].?', '', 1)
			end,
		},
		actions = {
			open_file = { quit_on_open = true, window_picker = { enable = true } },
			change_dir = { global = true },
			file_popup = { open_win_config = { border = 'single', col = -1 } },
		},
		on_attach = function(bufnr)
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
			map({ 'K', 'P', '<S-Left>' }, api.node.navigate.parent)
			map('<', api.node.navigate.sibling.prev)
			map('>', api.node.navigate.sibling.next)
			map('-', api.node.navigate.parent_close)
			map('e', api.tree.expand_all)
			map('<M-e>', api.tree.collapse_all)
			map({ '<C-h>', '<BS>' }, api.tree.toggle_hidden_filter)
			map('<C-g>', api.tree.toggle_gitignore_filter)
			map('<F5>', api.tree.reload)
			map('n', api.fs.create)
			map({ 'D', '<Del>' }, api.fs.remove)
			map('X', api.fs.cut)
			map('C', api.fs.copy.node)
			map('V', api.fs.paste)
			map({ 'R', '<F2>' }, api.fs.rename)
			map('q', api.tree.close)
			map({ 'cd', 'O', '<S-CR>' }, api.tree.change_root_to_node)
			map('/', api.tree.search_node)
			map('<M-i>', api.node.show_info_popup)
			map('S', api.node.run.cmd)
			vim.keymap.set('n', '<M-Tab>', '<C-w>l', { buffer = bufnr })
		end,
	}

	map('n', '<M-Tab>', '<Cmd>NvimTreeToggle<CR>')
	local file = vim.api.nvim_buf_get_name(0)
	if vim.fn.isdirectory(file) == 1 then
		vim.loop.chdir(file)
		require('nvim-tree.api').tree.open()
	end
end
return M
