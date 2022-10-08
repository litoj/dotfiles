local tree_cb = require'nvim-tree.config'.nvim_tree_callback
require'nvim-tree'.setup {
	hijack_directories = {enable = false}, -- disable as directory opener
	disable_netrw = true,
	hijack_netrw = true,
	respect_buf_cwd = true,
	ignore_ft_on_setup = {"startify"},
	update_focused_file = {enable = true, update_cwd = true},
	filters = {dotfiles = true, custom = {".git", "node_modules", ".cache"}},
	renderer = {
		indent_markers = {enable = true},
		icons = {
			glyphs = {
				default = "",
				symlink = "",
				folder = {default = "", open = "", empty = "", empty_open = "", symlink = ""},
				git = {unstaged = "", staged = "✓", unmerged = "", renamed = "➜", untracked = ""},
			},
		},
	},
	actions = {open_file = {quit_on_open = true, window_picker = {enable = false}}},
	view = {
		mappings = {
			custom_only = true,
			list = {
				{key = "h", cb = tree_cb("dir_up")},
				{key = "<Left>", cb = tree_cb("dir_up")},
				{key = "l", cb = tree_cb("edit")},
				{key = "<Right>", cb = tree_cb("edit")},
				{key = "E", cb = tree_cb("edit")},
				{key = "<C-t>", cb = tree_cb("tabnew")},
				{key = "<", cb = tree_cb("prev_sibling")},
				{key = ">", cb = tree_cb("next_sibling")},
				{key = "-", cb = tree_cb("close_node")},
				{key = "<Tab>", cb = vim.api.nvim_replace_termcodes("<C-w><C-l>", true, true, true)},
				{key = "<M-e>", cb = vim.api.nvim_replace_termcodes("<C-w><C-l>", true, true, true)},
				{key = "<M-Tab>", cb = vim.api.nvim_replace_termcodes("<C-w><C-l>", true, true, true)},
				{key = "<C-h>", cb = tree_cb("toggle_dotfiles")},
				{key = "<BS>", cb = tree_cb("toggle_dotfiles")},
				{key = "<F5>", cb = tree_cb("refresh")},
				{key = "n", cb = tree_cb("create")},
				{key = "<Del>", cb = tree_cb("remove")},
				{key = "D", cb = tree_cb("remove")},
				{key = "X", cb = tree_cb("cut")},
				{key = "C", cb = tree_cb("copy")},
				{key = "V", cb = tree_cb("paste")},
				{key = "R", cb = tree_cb("rename")},
				{key = "q", cb = tree_cb("close")},
				{key = "<Leader>d", cb = tree_cb("cd")},
			},
		},
	},
}

nmap("n", "E", "<Cmd>NvimTreeToggle<CR>")
nmap("n", "<M-e>", "<Cmd>NvimTreeFocus<CR>")
nmap("n", "<M-Tab>", "<Cmd>NvimTreeFocus<CR>")
