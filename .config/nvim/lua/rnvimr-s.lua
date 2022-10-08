vim.g.rnvimr_enable_ex = 1
vim.g.rnvimr_enable_picker = 1
vim.g.rnvimr_enable_bw = 1
vim.g.rnvimr_draw_border = 1
vim.g.rnvimr_border_attr = {fg = 5}
vim.g.rnvimr_layout = {
	relative = "editor",
	style = "minimal",
	width = 255,
	height = 127,
	col = 0,
	row = 0,
}

-- Rnvimr yw: current dir to Neovim's cwd; gw: goto Neovim's cwd
nmap("n", "<C-o>", "<Cmd>RnvimrToggle<CR>")
nmap("n", "R", "<Cmd>RnvimrToggle<CR>")
automap("t", "rnvimr", "<M-e>", "<Cmd>RnvimrToggle<CR>")
automap("t", "rnvimr", "<C-Esc>", "<Cmd>RnvimrToggle<CR>")
automap("t", "rnvimr", "<C-q>", "q")
