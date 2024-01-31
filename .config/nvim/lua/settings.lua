vim.opt.iskeyword:append '-'
vim.o.shortmess = 'asWIcCFt'
vim.o.formatoptions = 'tcqjl1'
vim.o.tw = 100
vim.o.et = false
vim.o.ts = 2
vim.o.sw = 2
vim.o.list = true
vim.o.lcs = 'tab:│ ,leadmultispace:│ '
vim.o.sts = 2

vim.o.wrap = true
vim.o.sta = true
vim.o.bri = true
vim.o.si = true

vim.o.udf = true
vim.o.swf = false
vim.o.cuc = true
vim.o.cul = true
vim.o.nu = true
vim.o.rnu = true
vim.o.signcolumn = 'number'
vim.o.incsearch = true
vim.o.title = true
vim.o.titlestring = "nvim - %{expand('%:t')}"
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.hidden = true
vim.o.showmode = false
vim.o.whichwrap = '<,>,[,],h,l'
vim.o.cmdheight = 1
vim.o.pumheight = 10
vim.o.backup = false
vim.o.writebackup = false
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.synmaxcol = 127
vim.o.history = 100
vim.o.ssop = 'buffers,terminal'
-- ↓ '%' loads last opened on start
vim.o.shada = "%,'500,<0,s1,f0,h,rterm:,rjdt:,r/usr/share/nvim/runtime/"
vim.g.rust_recommended_style = 0
vim.g.omni_sql_no_default_maps = 1
vim.g.mapleader = ' '
-- hotfix to prevent overwriting shada on cli opening/commits
if #vim.v.argv > 2 and not vim.v.argv[3]:match '^-[iu]' then vim.o.sdf = 'NONE' end
