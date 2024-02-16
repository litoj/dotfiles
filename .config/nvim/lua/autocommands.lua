local group = vim.api.nvim_create_augroup('CfgAU', { clear = true })
local vau = vim.api.nvim_create_autocmd

---@param ev string|string[]
---@param cb string|function
---@param extra? string|string[]|number|boolean pattern|buffer|once
local function au(ev, cb, extra)
	local opts = { group = group }
	opts[type(extra) == 'number' and 'buffer' or (type(extra) == 'boolean' and 'once' or 'pattern')] =
		extra
	opts[type(cb) == 'string' and 'command' or 'callback'] = cb
	vau(ev, opts)
end

local function setCWD(s)
	if not exists(s.file) then return end
	local dir = vim.b[s.buf].cwd -- storing determined cwd
	if dir then
		if vim.loop.cwd() ~= dir then vim.api.nvim_set_current_dir(dir) end
		return
	end

	local path = s.file:gsub('[^/]+$', '')
	dir = path:match '.*/src/' or path:match '.*/lua/' or path:match '.*/data/'
	if not dir then
		local git = path
		while #git > 1 and not exists(git .. '.git/') do
			git = git:gsub('[^/]+/$', '')
		end
		dir = git ~= '/' and git or path -- repo root or filedir ← no repo
	end
	vim.b[s.buf].cwd = dir
	if vim.loop.cwd() ~= dir then vim.api.nvim_set_current_dir(dir) end
end
au('BufEnter', setCWD, '*') -- to execute on every focus change

au(
	'TextYankPost',
	function() require('vim.highlight').on_yank { higroup = 'Search', timeout = 50 } end
)
au('FileType', 'nnoremap <buffer> q <Cmd>close<CR>', { 'qf', 'help', 'man' })
au('Filetype', 'setlocal expandtab', { 'yaml' })
au('FileType', function()
	for _, key in ipairs { 'p', 'r', 'e', 's', 'f', 'd', 'x', 'b', 'l', 'r', 't', 'm' } do
		vim.keymap.set('n', key, 'ciw' .. key .. '<Esc>', { silent = true, buffer = true })
	end
end, 'gitrebase')
au('TermOpen', function(state)
	vim.opt_local.nu = false
	vim.opt_local.rnu = false
	au('BufLeave', function()
		if vim.api.nvim_get_mode().mode == 't' then vim.schedule(vim.cmd.startinsert) end
	end, state.buf)
end)

local function hiNotes()
	vim.fn.matchadd('Todo', '\\<FIX\\w\\+\\>')
	vim.fn.matchadd('Todo', 'TODO')
	vim.fn.matchadd('Todo', '\\<NOTE')
	vim.fn.matchadd('Todo', 'XXX')
	vim.fn.matchadd('Todo', '\\<DEBUG')
	vim.fn.matchadd('WarningMsg', '\\<WARN\\w\\+\\>')
	vim.fn.matchadd('ErrorMsg', '\\<ERR\\w\\+\\>')
end
hiNotes()
au('WinNew', hiNotes)

au('BufRead', function(state)
	vim.opt_local.lcs = 'tab:│ ,leadmultispace:│' .. string.rep(' ', vim.bo.sw - 1) -- indent marks
	local f = state.file
	if f:find('.git/', 1, true) or f:find '^/tmp' or f:find('.cache/', 1, true) then
		vim.bo[state.buf].undofile = false -- Temp-file cleanliness
	end
end)

-- a fix for neovim shada '%' openning an empty buffer
if vim.fn.bufname() == '' then
	if vim.fn.bufnr '$' > 1 then vim.schedule(function() vim.cmd.bwipeout(1) end) end
else
	local stat = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
	if stat and stat.type == 'file' then setCWD { file = vim.api.nvim_buf_get_name(0), buf = 0 } end
end

return au
