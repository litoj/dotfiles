-- Text management
map({ '', 'i' }, '<C-s>', '<Cmd>w<CR>')
map({ 'n', 'i' }, '<M-S-Up>', '<Cmd>m-2<CR>')
map({ 'n', 'i' }, '<M-S-Down>', '<Cmd>m+<CR>')
map('n', '<C-S-Up>', 'md"dY"dp`d')
map('i', '<C-S-Up>', '<C-c>md"dY"dp`da')
map('n', '<C-S-Down>', 'md"dY"dP`d')
map('i', '<C-S-Down>', '<C-c>md"dY"dP`da')
map('n', '<C-S-k>', 'md"dY"dp`d')
map('i', '<C-S-k>', '<C-c>md"dY"dp`da')
map('n', '<C-S-j>', 'md"dY"dP`d')
map('i', '<C-S-j>', '<C-c>md"dY"dP`da')
map('n', '<C-a>', 'ggVG')
map('i', '<C-a>', '<C-o>gg<C-o>VG')
map({ 'n', 'i' }, '<C-S-A>', '<C-c>mdggVGy`da')
map('i', '<C-u>', '<C-v>u')
map('i', '<C-S-U>', '<C-v>U')
map('i', '<S-Enter>', '<C-o>o')
map('i', '<C-Enter>', '<C-o>O')
map('i', '<M-Enter>', '<C-o>md<C-o>O<C-o>`d')
map('i', '<M-S-Enter>', '<C-o><C-o>mdo<C-o>`d')
-- Clipboard management
map('n', '<C-x>', 'dd')
map('x', '<C-x>', 'd')
map('i', '<C-x>', '<C-o>dd')
map('n', '<C-c>', 'Y', { silent = true })
map('x', '<C-c>', 'y', { silent = true })
map('i', '<C-c>', '<C-o>Y', { silent = true })
map('i', '<C-v>', '<C-c>pa')
map('i', '<C-S-V>', '<C-o>md<C-o>P<C-o>`d')
map('n', '<C-v>', 'p')
map('v', '<C-v>', '"_dP')
-- Deleting text
map('n', '<C-d>', '"_dd')
map('i', '<C-BS>', '<C-w>')
map('i', '<C-d>', '<C-o>"_dd')
map('i', '<C-Del>', '<C-o>"_de')
map('', '<Del>', '"_x')
-- inc/dec
map('n', '<M-a>', '<C-a>')
map('i', '<M-a>', '<C-o><C-a>')
map('n', '<M-A>', '<C-x>')
map('i', '<M-A>', '<C-o><C-x>')
-- indent
map('i', '<C-S-T>', '<C-d>')
map('i', '<C-S-.>', '<C-t>')
-- undo/redo
map('n', 'r', '<Cmd>redo<CR>')
map({ '', 'i' }, '<C-z>', '<Cmd>undo<CR>')
map({ '', 'i' }, '<C-y>', '<Cmd>redo<CR>')

-- Moving around
map('i', '<S-Left>', '<C-o>ms<Left><C-o>v')
map('i', '<S-Down>', '<C-o>ms<C-o>v<Down>')
map('i', '<S-Up>', '<C-o>ms<C-o>v<Up>')
map('i', '<S-Right>', '<C-o>ms<C-o>v')
map('i', '<M-`>', '<C-o>`') -- quick mark jump
map({ '', 'i', 't' }, '<C-Up>', '<PageUp>')
map({ '', 'i', 't' }, '<C-Down>', '<PageDown>')
map({ '', 'i', 't' }, '<C-h>', '<C-Left>')
map({ '', 'i', 't' }, '<C-k>', '<PageUp>')
map({ '', 'i', 't' }, '<C-j>', '<PageDown>')
map({ '', 'i', 't' }, '<C-l>', '<C-Right>')
map({ 'i', 't' }, '<M-h>', '<Left>')
map({ 'i', 't' }, '<M-j>', '<Down>')
map({ 'i', 't' }, '<M-k>', '<Up>')
map({ 'i', 't' }, '<M-l>', '<Right>')
map('n', '<M-h>', '<C-w>h')
map('i', '<M-H>', '<C-o><C-w>h')
map('t', '<M-H>', '<C-\\><C-o><C-w>h')
map('n', '<M-j>', '<C-w>j')
map('n', '<M-k>', '<C-w>k')
map('n', '<M-l>', '<C-w>l')
map('i', '<M-L>', '<C-o><C-w>l')
map('t', '<M-L>', '<C-\\><C-o><C-w>l')

-- Buffer Closing
map({ 'n', 'i' }, '<C-w>', '<Cmd>bdelete<CR>')
map({ 'n', 'i' }, '<C-S-W>', '<Cmd>bdelete!<CR>')
map('t', '<C-S-D>', '<C-d><Cmd>bdelete!<CR>a')

-- Window actions
-- leaving
map({ '', 'i' }, '<C-q>', '<Cmd>q<CR>')
map({ '', 'i' }, '<C-S-Q>', '<Cmd>q!<CR>')
map('t', '<C-Esc>', '<C-\\><C-n>')
map('t', '<S-Esc>', '<C-\\><C-o>')
-- splits
map('n', '<Leader>v', '<Cmd>split<CR>')
map('n', '<Leader>h', '<Cmd>vsplit<CR>')
-- reload
map({ 'n', 'i' }, '<F5>', '<Cmd>e<CR>')
map({ 'n', 'i' }, '<F17>', '<Cmd>e!<CR>')
map('n', '<Leader>l', function()
	local path = vim.api.nvim_buf_get_name(0):gsub('.-/lua/', '', 1)
	local res = loadstring(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))()
	package.loaded[path
		:gsub('.+lua/', '', 1)
		:gsub('/init%.lua$', '', 1)
		:gsub('%.lua$', '', 1)
		:gsub('/', '.')] =
		res
	if path:find '^nerdcontrast' then
		local nc = require 'nerdcontrast'
		if path:find '/palette/' then
			vim.o.background = path:find 'dark' and 'dark' or 'light'
			nc.setPalette(res)
		else
			for k, _ in pairs(res) do
				nc.themeDep[k] = nil
			end
			nc.hi(res)
		end
	elseif path:find '^reform' then
		res.setup(true)
	elseif path:find '^plugins' then
		if type(res.config) == 'function' then res.config() end
	end
end)

-- Extra
map('n', '<Leader>/', '<Cmd>noh<CR>') -- clears all highlights/searches
map('n', '<M-C>', '<Cmd>Inspect<CR>')
map('n', 'S', '<Cmd>term<CR>a')
map('n', 'cd', '<Cmd>cd %:h<CR>')
map('', '<C-t>', '<Cmd>tabnew %<CR>')
map({ '', '!' }, '<kInsert>', '<NOP>')
