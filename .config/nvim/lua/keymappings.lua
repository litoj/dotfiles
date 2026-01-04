-- Text management
map({ '', 'i' }, '<C-s>', '<Cmd>w<CR>')
map({ 'n', 'i' }, '<A-S-Up>', '<Cmd>m-2<CR>')
map({ 'n', 'i' }, '<A-K>', '<Cmd>m-2<CR>')
map({ 'n', 'i' }, '<A-S-Down>', '<Cmd>m+<CR>')
map({ 'n', 'i' }, '<A-J>', '<Cmd>m+<CR>')
map('n', '<C-S-Up>', 'md"dY"dp`d')
map('n', '<C-S-k>', 'md"dY"dp`d')
map('i', '<C-S-Up>', '<C-c>md"dY"dp`da')
map('i', '<C-S-k>', '<C-c>md"dY"dp`da')
map('n', '<C-S-Down>', 'md"dY"dP`d')
map('n', '<C-S-j>', 'md"dY"dP`d')
map('i', '<C-S-Down>', '<C-c>md"dY"dP`da')
map('i', '<C-S-j>', '<C-c>md"dY"dP`da')
map('n', '<C-a>', 'ggVG')
map('i', '<C-a>', '<C-o>gg<C-o>VG')
map({ 'n', 'i' }, '<C-S-A>', '<C-c>mdggVGy`da')
map('x', 'r', '"dc')
map('i', '<C-u>', '<C-v>u')
map('i', '<C-S-U>', '<C-v>U')
map('i', '<S-Enter>', '<C-o>o')
map('i', '<C-Enter>', '<C-o>O')
map('i', '<A-Enter>', '<C-o>md<C-o>O<C-o>`d')
map('i', '<A-S-Enter>', '<C-o><C-o>mdo<C-o>`d')
map('c', '<C-/>', function() vim.api.nvim_feedkeys(vim.fn.getreg '/', 'n', false) end)
map('c', '<C-v>', function() vim.api.nvim_feedkeys(vim.fn.getreg '+', 'n', false) end)
-- Clipboard management
-- NOTE: C-v mappings in ./plugins/manipulator.lua
map('n', '<C-x>', 'dd')
map('x', '<C-x>', 'd')
map('i', '<C-x>', '<C-o>dd')
map('n', '<C-c>', 'Y', { silent = true })
map('x', '<C-c>', 'y', { silent = true })
map('i', '<C-c>', '<C-o>Y', { silent = true })
map('', 'c', '"dc') -- breaks avante ca (change accept)
-- Deleting text
map('i', '<C-d>', '<C-o>"ddd')
map('n', '<C-d>', '"ddd')
map('i', '<A-d>', '<C-o>"dd') -- overrides lsp diagnostic
map('i', '<A-d>b', '<Esc>"ddbi<Del>')
map('i', '<A-d>B', '<Esc>"ddBi<Del>')
map('v', '<Delete>', '"dd')
map('n', '<Delete>', '"_dl')
-- gui-like remap
map('c', '<C-BS>', '<C-w>')
map('i', '<C-BS>', '<C-w>')
map('i', '<C-S-BS>', '<Esc>"ddBi<Del>')
map('i', '<C-Del>', '<C-o>"dde')
map('i', '<C-S-Del>', '<C-o>"ddE')
local function delExtended(keybind)
	return function()
		vim.bo.isk = vim.bo.isk .. ',.,*'
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keybind, true, false, true), 'n', false)
		vim.schedule(function() vim.bo.isk = vim.bo.isk:gsub(',%.,%*$', '') end)
	end
end
map('i', '<A-BS>', delExtended '<C-w>')
map('i', '<A-Del>', delExtended '<C-o>"ddw')
-- undo/redo gui-like remap
map({ '', 'i' }, '<C-z>', '<Cmd>undo<CR>')
map({ '', 'i' }, '<C-y>', '<Cmd>redo<CR>')

-- Moving around
map('i', '<A-g>', '<C-o>g', { remap = true })
map('i', '<A-[>', '<C-o>[', { remap = true })
map('i', '<A-]>', '<C-o>]', { remap = true })
map('i', '<A-`>', '<C-o>`') -- quick mark jump
map('i', '<A-f>', '<C-o>f')
-- zz=center screen, M=center cursor
-- <C-u>/<C-d>=half page up/down, H/L=move to screen top/bot
map('', '<C-k>', '<C-u>zz')
map('', '<C-j>', '<C-d>zz')
map('', '<C-A-k>', '<C-y>')
map('', '<C-A-j>', '<C-e>')
map('', 'g;', 'g;zz')
map({ 'i', 't' }, '<C-k>', '<C-o><C-u><C-o>zz')
map({ 'i', 't' }, '<C-j>', '<C-o><C-d><C-o>zz')
map({ 't' }, '<C-h>', '<C-Left>') -- replaced with manipulator.nvim
map({ 't' }, '<C-l>', '<C-Right>')
map({ '!', 't' }, '<C-S-H>', '<C-o>B')
map({ '!', 't' }, '<C-S-L>', '<C-o>W')
map({ '!', 't' }, '<A-h>', '<Left>')
map({ '!', 't' }, '<A-j>', '<Down>')
map({ '!', 't' }, '<A-k>', '<Up>')
map({ '!', 't' }, '<A-l>', '<Right>')
-- gui-like remap
map('', '<C-Up>', '<PageUp>M')
map('', '<C-Down>', '<PageDown>M')
map({ 'i', 't' }, '<C-Up>', '<PageUp><C-o>M')
map({ 'i', 't' }, '<C-Down>', '<PageDown><C-o>M')

-- Window actions
map({ 'n', 'i' }, '<C-Tab>', '<Cmd>tabnext<CR>')
-- focus
map('n', '<A-h>', '<C-w>h')
map('n', '<A-j>', '<C-w>j')
map('n', '<A-k>', '<C-w>k')
map('n', '<A-l>', '<C-w>l')
-- leaving
map({ '', 'i' }, '<C-q>', '<Cmd>q<CR>')
map({ '', 'i' }, '<C-S-Q>', '<Cmd>q!<CR>')
map('t', '<C-Esc>', '<C-\\><C-n>')
map('t', '<S-Esc>', '<C-\\><C-o>')
-- splits
map('n', ' v', '<Cmd>split<CR>')
map('n', ' h', '<Cmd>vsplit<CR>')
-- reload
map({ 'n', 'i' }, '<F5>', '<Cmd>e<CR>')
map({ 'n', 'i' }, '<F17>', '<Cmd>e!<CR>')
-- search with centering
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
-- quickfix list
map('n', ' qc', '<Cmd>cclose<CR>')
map('n', ' qo', '<Cmd>copen<CR>')

-- Extra
map('n', '|', '&')
map('n', ' /', '<Cmd>noh<CR>') -- clears all highlights/searches
map('n', '<A-C>', '<Cmd>Inspect<CR>')
map('n', 'S', '<Cmd>term<CR>a')
map('n', 'cd', '<Cmd>cd %:h<CR>')
map('', '<C-t>', '<Cmd>tabnew %<CR>')
map('n', ' mm', function() vim.wo.conceallevel = (vim.wo.conceallevel + 2) % 4 end)
map('n', ' mg', function()
	local handle = io.popen 'git rev-parse --abbrev-ref HEAD 2> /dev/null'
	local remote_handle = io.popen 'git config --get remote.origin.url 2> /dev/null'
	if not remote_handle or not handle then return end
	local branch = handle:read('*a'):gsub('%s+', '')
	handle:close()
	local remote_url = remote_handle:read('*a'):gsub('%s+', '')
	remote_handle:close()
	if branch == '' or remote_url == '' then
		print 'invalid git state - no branch or remote'
		return
	end

	-- convert git url to https url
	local https_url = remote_url:gsub(':', '/'):gsub('^git@', 'https://'):gsub('%.git$', '')
	local full_url = https_url .. '/tree/' .. branch
	print(full_url)
	vim.ui.open(full_url)
end)

map('n', ' ml', function() -- load and execute lua code in current buffer
	local name = vim.api.nvim_buf_get_name(0)
	local path = name:gsub('.-/lua/(.+)%.lua', '%1', 1):gsub('/init$', '', 1):gsub('/', '.')
	require 'bench' -- load benchmarking function for testing

	local res = loadstring(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'))()
	local old = package.loaded[path]
	if exists(name) then
		-- inner deep override (ensures deeper references get updated, too)
		-- override from inside to update also all variables referencing the module
		local function extend(v1, v2)
			if type(v1) ~= 'table' or type(v2) ~= 'table' then return v2 end

			for k, _ in pairs(v1) do
				if v2[k] == nil then v1[k] = nil end
			end
			for k, v in pairs(v2) do
				-- prevent stack overflow
				if v ~= v2 then v1[k] = extend(v1[k], v) end
			end
			return v1
		end
		package.loaded[path] = extend(old, res)
	end

	-- plugin-specific reloading
	if vim.startswith(path, 'nerdcontrast') then -- nerdcontrast.nvim
		local nc = require 'nerdcontrast'
		if path:match '%.palette%.' then
			nc.setConfig { [vim.o.bg] = { palette = { base = res } } }
			vim.o.background = path:match 'light' or 'dark'
		elseif path:match '%.theme%.' then
			nc.setup { [vim.o.bg] = { theme = { base = res } } }
		else
			for k, _ in pairs(res) do
				nc.deps[k] = nil
			end
			nc.hi(res)
		end
	elseif vim.startswith(path, 'reform') then -- reform.nvim
		if not path:find 'util' then
			local reform = require 'reform'
			reform.setup(path == 'reform' and old.config or reform.config)
		else
			res.debug = old.debug
		end
	elseif vim.startswith(path, 'plugins') then -- lazy.nvim
		if type(res[1]) == 'string' then res = { res } end
		for _, cfg in ipairs(res) do
			if type(cfg.config) == 'function' then cfg.config(nil, cfg.opts) end
		end
	elseif vim.startswith(path, 'vim.') then
		local dst = vim
		path = path:sub(5)
		while path:find '%.' do
			dst = dst[path:match '^[^.]+']
			path = path:gsub('^[^.]+%.', '', 1)
		end
		dst[path] = res
	end
end)

map('x', '<Tab>', function() -- simple indentation changer ('>' cancels visual mode)
	local from, to = vim.fn.line 'v', vim.api.nvim_win_get_cursor(0)[1]
	if from > to then
		local x = to
		to = from
		from = x
	end
	local lines = vim.api.nvim_buf_get_lines(0, from - 1, to, true)
	for i, line in ipairs(lines) do
		local indent = line:match '^%s'
		if not indent and #line > 0 then
			indent = vim.bo.et and string.rep(' ', vim.bo.sw) or '\t'
		elseif indent == ' ' then -- add the appropriate amount of spaces to shift by 1 level
			indent = string.rep(' ', vim.bo.sw)
		end
		if indent then lines[i] = indent .. line end
	end
	vim.api.nvim_buf_set_lines(0, from - 1, to, true, lines)
end)
map('x', '<S-Tab>', function()
	local from, to = vim.fn.line 'v', vim.api.nvim_win_get_cursor(0)[1]
	if from > to then
		local x = to
		to = from
		from = x
	end
	local lines = vim.api.nvim_buf_get_lines(0, from - 1, to, true)
	for i, line in ipairs(lines) do
		local indent = line:match '^%s'
		if indent then lines[i] = line:sub((indent == ' ' and vim.bo.sw or 1) + 1) end
	end
	vim.api.nvim_buf_set_lines(0, from - 1, to, true, lines)
end)
