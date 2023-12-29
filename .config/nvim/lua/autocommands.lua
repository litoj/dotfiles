local group = vim.api.nvim_create_augroup('CfgAU', { clear = true })
local vau = vim.api.nvim_create_autocmd

---@param ev string|string[]
---@param cb string|function
---@param pat? string|string[]
local function au(ev, cb, pat, buf)
	local opts = { group = group, pattern = pat, buffer = buf }
	opts[type(cb) == 'string' and 'command' or 'callback'] = cb
	vau(ev, opts)
end

local lastGit
local invalidLsp = { ['null-ls'] = 1, copilot = 1 }
local function setCWD(state)
	if not vim.loop.fs_stat(state.file) then return end
	local path = state.file:gsub('[^/]+$', '')
	local git = path
	while #git > 1 and not vim.loop.fs_stat(git .. '.git/') do
		git = git:gsub('[^/]+/$', '')
	end
	git = git ~= '/' and git or path
	local clients = vim.lsp.get_active_clients { bufnr = state.buf }
	if #clients > 0 then
		for _, lsp in ipairs(clients) do
			local dir = lsp.config.root_dir
			if not invalidLsp[lsp.name] and dir and path:sub(1, #dir) == dir then
				lastGit = git
				vim.api.nvim_set_current_dir(dir)
				return
			end
		end
	end
	if path:find(vim.fn.getcwd(), 0, true) and git == lastGit then return end
	lastGit = git
	vim.api.nvim_set_current_dir(
		path:match '.*/lua/'
			or path:match '.*/src/'
			or path:match '.*%.nvim/'
			or path:match '.*/.config/[^/]+/'
			or git
	)
end
au('BufEnter', setCWD, '*.*')

local function indentMarks()
	vim.wo.lcs = 'tab:│ ,leadmultispace:│' .. string.rep(' ', vim.bo.sw - 1)
end
indentMarks()
au('BufRead', indentMarks)

au(
	'TextYankPost',
	function() require('vim.highlight').on_yank { higroup = 'Search', timeout = 50 } end
)
au('FileType', 'nnoremap <buffer> q <Cmd>close<CR>', { 'qf', 'help', 'man' })
au('FileType', function()
	for _, key in ipairs { 'p', 'r', 'e', 's', 'f', 'd', 'x', 'b', 'l', 'r', 't', 'm' } do
		vim.keymap.set('n', key, 'ciw' .. key .. '<Esc>', { silent = true, buffer = true })
	end
end, 'gitrebase')
au('TermOpen', function(state)
	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	au('BufLeave', function()
		if vim.api.nvim_get_mode().mode == 't' then vim.schedule(vim.cmd.startinsert) end
	end, nil, state.buf)
end)

local function hiNotes()
	vim.fn.matchadd('Todo', '\\<FIX')
	vim.fn.matchadd('Todo', 'TODO')
	vim.fn.matchadd('Todo', '\\<NOTE')
	vim.fn.matchadd('Todo', 'XXX')
	vim.fn.matchadd('Todo', '\\<DEBUG')
	vim.fn.matchadd('WarningMsg', '\\<WARN')
	vim.fn.matchadd('ErrorMsg', '\\<ERROR')
end
hiNotes()
au('WinNew', hiNotes)

-- Temp-file cleanliness
au('BufRead', function(state)
	local f = state.file
	if f:find('.git/', 1, true) or f:find '^/tmp' or f:find('.cache/', 1, true) then
		vim.bo[state.buf].undofile = false
	end
end)

--[[ au('VimLeavePre', function()
	local filter = { vim.o.shada }
	for _, v in ipairs(vim.v.oldfiles) do
		if v:find('.git/', 7, true) or v:match 'NvimTree_%d+$' or not vim.loop.fs_stat(v) then
			filter[#filter + 1] = v
		end
	end
	vim.o.shada = table.concat(filter, ',r')
end) ]]

-- a fix for neovim shada '%' openning an empty buffer
local stat = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0))
if vim.fn.bufname() == '' then
	-- 'wipeout' doesn't update jumps list
	if vim.fn.bufnr '$' > 1 then vim.schedule(function() vim.cmd.bwipeout(1) end) end
else
	if stat and stat.type == 'file' then setCWD { file = vim.api.nvim_buf_get_name(0), buf = 0 } end
end
stat = nil

return au
