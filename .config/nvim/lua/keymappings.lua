function _G.nmap(mode, _in, _out, opts) vim.keymap.set(mode, _in, _out, opts) end
function _G.map(mode, _in, _out, opts)
	local options = {remap = true, silent = true}
	if opts then options = vim.tbl_extend("force", options, opts) end
	vim.keymap.set(mode, _in, _out, options)
end

function _G.automap(mode, filetype, _in, _out, recursive)
	recursive = recursive and "" or "nore"
	vim.cmd(string.format("autocmd FileType %s %s%smap <buffer> <silent> %s %s", filetype, mode,
			recursive, _in, _out))
end

vim.g.mapleader = " "

-- Better indenting
nmap("n", "<C-S-lt>", "<<")
nmap("i", "<C-S-lt>", "<C-d>")
nmap("i", "<C-S-T>", "<C-d>")
nmap("n", "<C-S-,>", ">>")
nmap("i", "<C-S-.>", "<C-t>")

-- Clipboard management
nmap("n", "<C-x>", "dd")
nmap("x", "<C-x>", "d")
nmap("i", "<C-x>", "<C-o>dd")
nmap("n", "<C-c>", "Y")
nmap("x", "<C-c>", "y")
nmap("i", "<C-c>", "<C-o>Y")
nmap("n", "<C-v>", "p")
nmap("x", "<C-v>", "\"ddP")
nmap("i", "<C-v>", "<Esc>pa")
nmap("i", "<C-S-V>", "<Esc>Pa")
nmap("n", "f", "p")
nmap("n", "F", "P")

-- Text management
nmap({"", "i"}, "<C-s>", "<Cmd>w<CR>")
nmap({"n", "i"}, "<M-S-Up>", "<Cmd>m-2<CR>")
nmap({"n", "i"}, "<M-S-Down>", "<Cmd>m+<CR>")
nmap("n", "<C-S-Up>", "md\"dY\"dp`d")
nmap("i", "<C-S-Up>", "<Esc>md\"dY\"dp`da")
nmap("n", "<C-S-Down>", "md\"dY\"dP`d")
nmap("i", "<C-S-Down>", "<Esc>md\"dY\"dP`da")
nmap("n", "<C-a>", "<Esc>mdggVG")
nmap("i", "<C-a>", "<Esc>mdggi<C-o>VG")
nmap({"n", "i"}, "<C-S-A>", "<Esc>mdggVGy`da")
nmap("i", "<C-S-U>", "<C-v>u")
nmap("i", "<C-BS>", "<C-W>")
nmap("i", "<S-Enter>", "<C-o>o")
nmap("i", "<C-Enter>", "<C-o>O")
nmap("i", "<M-Enter>", "<Esc>mdO<Esc>`da")
nmap("i", "<M-S-Enter>", "<Esc>mdo<Esc>`da")
nmap("n", "<M-a>", "<C-a>") -- increase value
nmap("i", "<M-a>", "<C-o><C-a>") -- increase value
nmap("n", "<M-A>", "<C-x>") -- decrease value
nmap("i", "<M-A>", "<C-o><C-x>") -- decrease value
nmap("n", "C", "vg~") -- toggle text case; gu for lowercase, gU for UPPERCASE
nmap("x", "C", "g~")
nmap("i", "<M-t>", "<C-o>vg~")

-- Deleting text
nmap("n", "<C-S-D>", "\"_diW")
nmap("i", "<C-S-D>", "<C-o>\"_diW")
nmap("n", "<C-d>", "\"_dd")
nmap("i", "<C-d>", "<C-o>\"_dd")
nmap("i", "<C-Del>", "<C-o>\"_de")
nmap("", "<Del>", "\"_x")

-- Undotree
nmap("n", "r", "<Cmd>redo<CR>")
nmap({"", "i"}, "<C-z>", "<Cmd>undo<CR>")
nmap({"", "i"}, "<C-y>", "<Cmd>redo<CR>")

-- Moving around
nmap("", "K", "{")
nmap("i", "<M-K>", "<C-o>{")
nmap("", "J", "}")
nmap("i", "<M-J>", "<C-o>}")
nmap({"", "i"}, "<C-h>", "<C-Left>")
nmap({"", "i"}, "<C-j>", "<PageDown>")
nmap({"", "i"}, "<C-k>", "<PageUp>")
nmap({"", "i"}, "<C-l>", "<C-Right>")
nmap({"", "i"}, "<M-S-H>", "<Home>")
nmap("", "<M-S-J>", "L")
nmap("i", "<M-S-J>", "<C-o>L")
nmap("", "<M-S-K>", "H")
nmap("i", "<M-S-K>", "<C-o>H")
nmap({"", "i"}, "<M-S-L>", "<End>")
nmap("i", "<M-h>", "<Left>")
nmap("i", "<M-j>", "<Down>")
nmap("i", "<M-k>", "<Up>")
nmap("i", "<M-l>", "<Right>")
nmap("i", "<M-m>", "<C-o>m")
nmap("i", "<C-g>", "<C-o>`")
-- With arrows
nmap({"", "i"}, "<C-Up>", "<PageUp>")
nmap("", "<S-Up>", "K")
nmap({"", "i"}, "<C-Down>", "<PageDown>")
nmap("", "<S-Down>", "J")
nmap("i", "<S-Left>", "<Left><C-o>v")
nmap("i", "<S-Down>", "<C-o>v<Down>")
nmap("i", "<S-Up>", "<C-o>v<Up>")
nmap("i", "<S-Right>", "<C-o>v")
nmap("i", "<S-Home>", "<Left><C-o>v^")
nmap("i", "<S-End>", "<C-o>v$")

-- Closing
nmap({"", "i"}, "<C-q>", "<Cmd>q<CR>")
nmap({"", "i"}, "<C-S-Q>", "<Cmd>q!<CR>")
nmap("t", "<C-Esc>", "<C-\\><C-n>")

-- Tab management through nvim, Buffers in barbar-s.lua
nmap("", "<C-t>", "<Cmd>tabnew %<CR>")
nmap("", "<C-Tab>", "<Cmd>tabnext<CR>")
nmap("", "<M-C-Tab>", "<Cmd>tabprevious<CR>")
nmap({"", "i"}, "<C-.>", "<Cmd>tabnext<CR>")
nmap({"", "i"}, "<C-,>", "<Cmd>tabprevious<CR>")
nmap({"", "i"}, "<M-C-w>", "<Cmd>tabclose<CR>")
nmap({"", "i"}, "<C-1>", "<Cmd>tabnext 1<CR>")
nmap({"", "i"}, "<C-2>", "<Cmd>tabnext 2<CR>")
nmap({"", "i"}, "<C-3>", "<Cmd>tabnext 3<CR>")
nmap({"", "i"}, "<C-4>", "<Cmd>tabnext 4<CR>")
nmap({"", "i"}, "<C-5>", "<Cmd>tabnext 5<CR>")
nmap({"", "i"}, "<C-6>", "<Cmd>tabnext 6<CR>")
nmap({"", "i"}, "<C-7>", "<Cmd>tabnext 7<CR>")
nmap({"", "i"}, "<C-8>", "<Cmd>tabnext 8<CR>")
nmap({"", "i"}, "<C-9>", "<Cmd>tabnext 9<CR>")

-- Switching splits
nmap("n", "<Leader>v", "<Cmd>split<CR>")
nmap("n", "<Leader>h", "<Cmd>vsplit<CR>")
nmap("n", "<C-S-H>", "<C-w>h")
nmap("i", "<C-S-H>", "<C-o><C-w>h")
nmap("t", "<C-S-H>", "<C-\\><C-o><C-w>h")
-- <C-S-J> shows as <S-NL>
nmap("n", "<S-NL>", "<C-w>j")
nmap("i", "<S-NL>", "<C-o><C-w>j")
nmap("t", "<S-NL>", "<C-\\><C-o><C-w>j")
nmap("n", "<C-S-K>", "<C-w>k")
nmap("i", "<C-S-K>", "<C-o><C-w>k")
nmap("t", "<C-S-K>", "<C-\\><C-o><C-w>k")
nmap("n", "<C-S-L>", "<C-w>l")
nmap("i", "<C-S-L>", "<C-o><C-w>l")
nmap("t", "<C-S-L>", "<C-\\><C-o><C-w>l")

-- Resize windows
nmap("n", "<M-j>", "<Cmd>resize -2<CR>")
nmap("n", "<M-k>", "<Cmd>resize +2<CR>")
nmap("n", "<M-h>", "<Cmd>vertical resize -2<CR>")
nmap("n", "<M-l>", "<Cmd>vertical resize +2<CR>")

nmap("n", "S", "<Cmd>cd %:h<CR><Cmd>term<CR><Cmd>setlocal nonu<CR>i")
nmap("n", "<Leader>d", "<Cmd>cd %:h<CR>")

-- Refresh and reload
nmap("n", "<C-n>", "<Cmd>enew | Startify<CR>")
nmap({"n", "i"}, "<F5>", "<Cmd>e<CR>")
nmap({"n", "i"}, "<F17>", "<Cmd>e!<CR>")
nmap("n", "<Leader>l", "<Cmd>luafile %<CR>")
nmap("n", "<Leader>/", "<Cmd>noh<CR>") -- clears all highlights/searches

nmap("n", "<Leader>c", function()
	vim.g.WhiteTheme = not vim.g.WhiteTheme
	vim.cmd "colorscheme nerdcontrast"
	vim.cmd "luafile ~/.config/nvim/lua/galaxyline-s.lua"
end)

-- Treesitter Debugging
nmap("n", "X", function()
	local res = vim.treesitter.get_captures_at_cursor(0)
	if type(res) == "table" then
		local str = {}
		for _, v in ipairs(res) do
			v = "@" .. v .. "." .. vim.bo.filetype
			table.insert(str, {" " .. v, v})
		end
		vim.api.nvim_echo(str, 0, {})
	else
		vim.api.nvim_echo("ERROR")
	end
end)
-- Ignore key
nmap({"", "!"}, "<kInsert>", "")

-- Compiling
local mdC = '<C-s><Cmd>!firefox-nightly --new-tab (compiler "%:p") & && swaymsg [app_id="firefox-nightly"] focus<CR><CR>'
automap("n", "markdown", "<M-r>", mdC, true)
automap("i", "markdown", "<M-r>", mdC, true)
local cC = "<C-s><Cmd>cd %:h<CR><Cmd>term compiler %:p<CR><Cmd>setlocal nonu<CR>"
automap("n", "cpp,c", "<M-b>", cC, true)
automap("i", "cpp,c", "<M-b>", cC, true)
local cR = "<C-s><Cmd>!compiler %:p<CR><CR>"
automap("n", "cpp,c", "<M-r>", cR, true)
automap("i", "cpp,c", "<M-r>", cR, true)
local cT = "<C-s><Cmd>!compiler %:p<CR><Cmd>!set p (find . -type f -executable);$p<CR>"
automap("n", "cpp,c", "<M-S-D>", cT, true)
automap("i", "cpp,c", "<M-S-D>", cT, true)
local rR = "<C-s><Cmd>cd %:h<CR><Cmd>!cargo build --release<CR>" -- release
automap("n", "rust", "<M-r>", rR, true)
automap("i", "rust", "<M-r>", rR, true)
local rB = "<C-s><Cmd>cd %:h<CR><Cmd>!cargo build<CR>" -- debug
automap("n", "rust", "<M-b>", rB, true)
automap("i", "rust", "<M-b>", rB, true)
local rT = "<C-s><Cmd>cd %:h<CR><Cmd>!cargo run<CR>" -- test run
automap("n", "rust", "<M-S-D>", rT, true)
automap("i", "rust", "<M-S-D>", rT, true)
local rC = "<C-s><Cmd>cd %:h<CR><Cmd>!cargo check<CR>" -- check for mistakes
automap("n", "rust", "<M-c>", rC, true)
automap("i", "rust", "<M-c>", rC, true)
