local actions = require "telescope.actions"
local telescope = require "telescope"

-- telescope.load_extension "media_files"
telescope.setup {
	defaults = {
		find_command = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		prompt_prefix = " ",
		selection_caret = " ",
		path_display = {"smart"},
		winblend = 0,
		borderchars = {"─", "│", "─", "│", "╭", "╮", "╯", "╰"},
		set_env = {["COLORTERM"] = "truecolor"}, -- default = nil,
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
				-- To disable a keymap, put [map] = false
				["<Esc>"] = actions.close,
				-- Add up multiple actions
				["<CR>"] = actions.select_default + actions.center,
			},
		},
	},
}

nmap("n", "<Leader>t", "<Cmd>Telescope<CR>")
nmap("n", "<Leader>f",
     "<Cmd>lua require'telescope.builtin'.find_files(require'telescope.themes'.get_dropdown{previewer=false})<CR>")
nmap("n", "<Leader>a",
     "<Cmd>lua require'telescope.builtin'.find_files(vim.tbl_extend('force',require'telescope.themes'.get_dropdown{previewer=false},{find_command={'fd','--type','f','-L','--search-path',os.getenv'HOME'..'/.config','--search-path',os.getenv'HOME','-E','Android','-E',os.getenv'HOME'..'.config/libreoffice'}}))<CR>")
nmap("n", "<Leader>o",
     "<Cmd>lua require'telescope.builtin'.oldfiles(require'telescope.themes'.get_dropdown{previewer=false})<CR>")
nmap("n", "<Leader>g", "<Cmd>Telescope live_grep<CR>")
