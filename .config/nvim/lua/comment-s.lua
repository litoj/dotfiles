require'Comment'.setup {
	ignore = '^$',
	padding = true,
	mappings = {basic = true, extra = false},
}
map("n", "<C-S-C>", "gcc")
map("v", "<C-S-C>", "gc")
map("i", "<C-S-C>", "<Esc>gcca")
map("x", "<C-S-X>", "gc")
map("n", "<C-S-X>", "gbc")
map("i", "<C-S-X>", "<Esc>gbca")
map("x", "<C-S-X>", "gb")
map("n", "<M-x>", "gca}")
map("i", "<M-x>", "<Esc>gca}a")
map("x", "<M-x>", "gb")
map("n", "<M-S-X>", "gbip")
map("i", "<M-S-X>", "<Esc>gbipa")
map("x", "<M-S-X>", "gb")
map("x", "<M-c>", "gc")
map("n", "<M-C>", "gcip")
map("i", "<M-C>", "<Esc>gcipa")
map("x", "<M-C>", "gc")
