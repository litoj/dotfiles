vim.g.startify_custom_header = {"  NEOVIM"}
vim.g.startify_lists = {
	{type = "files", header = {"Files"}},
	{type = "bookmarks", header = {"Bookmarks"}},
}
vim.g.startify_session_delete_buffers = 1
vim.g.startify_fortune_use_unicode = 1
vim.g.startify_session_persistence = 1
vim.g.startify_change_to_vcs_root = 1
vim.g.startify_session_autoload = 1
vim.g.startify_enable_special = 0
vim.g.startify_bookmarks = {
	{ic = "~/.config/sway/binds.i3conf"},
	{i3 = "~/.config/sway/"},
	{ib = "~/.config/i3blocks/"},
	{ra = "~/.config/ranger/rc.conf"},
	{rf = "~/.config/rofi/config.rasi"},
	{fn = "~/.config/fontconfig/fonts.conf"},
	{fc = "~/.config/fish/config.fish"},
	{vi = "~/.config/nvim/lua"},
	{dd = "~/Documents/"},
	{ds = "~/Documents/PG/litosjos/"},
	{dc = "~/dotfiles/.config/"},
}

automap("n", "startify", "<Esc>", "<Cmd>BufferClose<CR>")
