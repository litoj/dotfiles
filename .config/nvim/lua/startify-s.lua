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
	{st = "~/st/config.h"},
	{ic = "~/.config/i3/binds.i3conf"},
	{i3 = "~/.config/i3/"},
	{ib = "~/.config/i3blocks/"},
	{pi = "~/.config/picom/picom.conf"},
	{ra = "~/.config/ranger/rc.conf"},
	{rf = "~/.config/rofi/config.rasi"},
	{fn = "~/.config/fontconfig/fonts.conf"},
	{fc = "~/.config/fish/config.fish"},
	{vi = "~/.config/nvim/lua"},
	{dd = "~/Documents/"},
	{dp = "~/Documents/PG/"},
	{ds = "~/Documents/PG/litosjos/"},
	{dc = "~/dotfiles/.config/"},
}

nmap("n", "<C-n>", "<Cmd>enew | Startify<CR>")
automap("n", "startify", "<Esc>", "<Cmd>BufferClose<CR>")
