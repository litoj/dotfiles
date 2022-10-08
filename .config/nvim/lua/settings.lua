vim.cmd([[
set tw=100 noet ts=2 sw=2 sts=2
set wrap undofile noswapfile
set cc=0 cul cuc nu nornu
set lbr bri ai si fdc=0 fdl=100 nofen
set iskeyword+=- shortmess+=ca formatoptions-=cro
]])
vim.o.signcolumn = "no" -- Always show the signcolumn
vim.o.incsearch = true
vim.o.title = true
vim.o.titlestring = "%{expand('%:t')} - NVim"
vim.o.mouse = "a" -- Enable mouse
vim.o.clipboard = "unnamedplus" -- Enable clipboard
vim.o.termguicolors = true -- use gui, not cterm
vim.o.showtabline = 2 -- Always show buffers
vim.o.hidden = true -- Keep multiple buffers in memory
vim.o.showmode = false
vim.cmd "set whichwrap+=<,>,[,],h,l" -- move to next line with these
vim.o.cmdheight = 1 -- More space for displaying messages
vim.o.pumheight = 10 -- Makes popup menu smaller
vim.o.backup = false
vim.o.writebackup = false
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.smarttab = true
vim.o.updatetime = 300 -- Faster completion
vim.o.timeoutlen = 500 -- By default timeoutlen is 1000 ms
vim.g.markdown_fenced_languages = {"sh", "html", "xml", "javascript", "lua"}
