local group = vim.api.nvim_create_augroup('CfgAU', { clear = true })
local vau = vim.api.nvim_create_autocmd

---@param ev string|string[]
---@param cb string|fun(state:{buf:number,event:string,file:string,group:number,id:number,match:string}):boolean?
---@param extra? string|string[]|number|boolean pattern|buffer|once
local function au(ev, cb, extra)
	local opts = { group = group }
	opts[type(extra) == 'number' and 'buffer' or (type(extra) == 'boolean' and 'once' or 'pattern')] =
		extra
	---@diagnostic disable-next-line: assign-type-mismatch
	opts[type(cb) == 'string' and 'command' or 'callback'] = cb
	vau(ev, opts)
end

local fakeUpdate = false
local function validUpdate(s)
	return exists(s.file) and vim.bo[s.buf].modifiable or vim.startswith(s.file, 'term://')
end
local fth = require 'fthelper'
local cwdEnabled = true
local cwdMap = {
	fallback = { 'README.md', 'package.json', '.git/' },
	ft_default = { '.*/src/' },
	lua = { 'lua/', 'after/' },
	cs = { '%.csproj$', '%.sln$' },
}
local function setCWD(s)
	if not (cwdEnabled and validUpdate(s)) then return end
	if fakeUpdate then
		fakeUpdate = false
		if vim.b[s.buf].cwd then return end
	end
	local dir = vim.b[s.buf].cwd or s.file:match 'term://(.+)//[0-9]+:'
	if dir then
		dir = dir:gsub('^~', os.getenv 'HOME')
		vim.api.nvim_set_current_dir(dir)
		return
	end

	local path = s.file:gsub('[^/]+$', '')

	for _, map in ipairs { cwdMap[s.file:match '[^.]*$'] or cwdMap.ft_default, cwdMap.fallback } do
		for _, key in ipairs(map) do
			dir = fth.findDir(path, key)
			if dir then break end
		end
		if dir then break end
	end
	dir = dir or path

	vim.b[s.buf].cwd = dir
	vim.api.nvim_set_current_dir(dir)
end
au('BufEnter', setCWD, '*') -- to execute on every focus change
au('BufLeave', function(s) fakeUpdate = not validUpdate(s) end)
map('n', ' md', function() cwdEnabled = not cwdEnabled end, { desc = 'toggle cwd changing' })

local function setIndentMarks(state)
	vim.wo[0][0].lcs = 'tab:│ ,leadmultispace:│' .. string.rep(' ', vim.bo.sw - 1) -- indent marks
	local f = state.file
	if f:find('.git/', 1, true) or f:find '^/tmp' or f:find('.cache/', 1, true) then
		vim.bo[state.buf].undofile = false -- Temp-file cleanliness
	end
end
au('BufRead', setIndentMarks)

au('TextYankPost', function() vim.hl.on_yank { higroup = 'Search', timeout = 50 } end)
au('FileType', 'nnoremap <buffer> q <Cmd>close<CR>', { 'qf', 'help', 'man' })
au('FileType', function()
	for _, key in ipairs { 'p', 'r', 'e', 's', 'f', 'd', 'x', 'b', 'l', 'r', 't', 'm' } do
		vim.keymap.set('n', key, 'ciw' .. key .. '<Esc>j', { silent = true, buffer = true })
	end
end, 'gitrebase')
au('TermOpen', function()
	vim.wo[0][0].nu = false
	vim.wo[0][0].rnu = false
end)

local function hiNotes()
	vim.fn.matchadd('Todo', [[\( \)\?\<\(TODO\|FIX\|NOTE\|XXX\|DEBUG\)\w*\>:\?\1]])
	vim.fn.matchadd('WarningMsg', [[\( \)\?\<WARN\w*\>:\?\1]])
	vim.fn.matchadd('ErrorMsg', [[\( \)\?\<ERR\w*\>:\?\1]])
end
hiNotes()
au('WinNew', hiNotes)

-- a fix for neovim shada '%' openning an empty buffer
if vim.fn.bufname() == '' then
	if vim.fn.bufnr '$' > 1 then
		vim.schedule(function()
			-- if it shows No buffers were wiped out, then switch to the real file from another buf first
			vim.cmd.bwipeout(1)
			setCWD { file = vim.api.nvim_buf_get_name(0), buf = 0 }
		end)
	end
else
	local state = { file = vim.api.nvim_buf_get_name(0), buf = 0 }
	setCWD(state)
	setIndentMarks(state)
end

return au
