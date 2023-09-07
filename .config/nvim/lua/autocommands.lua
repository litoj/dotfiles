local group = vim.api.nvim_create_augroup('CfgAU', { clear = true })

local lastRoot = '/'
vim.api.nvim_create_autocmd('BufEnter', {
	group = group,
	pattern = '*.*',
	callback = function(state)
		local path = state.file:gsub('/[^/]+$', '/')
		local git = path
		while #git > 1 and not vim.loop.fs_stat(git .. '.git/') do
			git = git:gsub('/[^/]+/$', '/')
		end
		if path:find('^' .. vim.fn.getcwd()) and git == lastRoot and #git > 1 then return end
		local clients = vim.lsp.get_clients { bufnr = state.buf }
		if #clients > 0 then
			for _, lsp in ipairs(clients) do
				local dir = lsp.config.root_dir
				if lsp.name == 'null-ls' then
					lastRoot = dir
				elseif dir and path:sub(1, #dir) == dir then
					if not lastRoot then lastRoot = git end
					vim.api.nvim_set_current_dir(dir)
					return
				end
			end
		end
		if not lastRoot then lastRoot = git end
		vim.api.nvim_set_current_dir(
			path:match '.*/lua/'
				or path:match '.*/src/'
				or path:match '.*%.nvim/'
				or path:match '.*/.config/[^/]+/'
				or (#lastRoot > 1 and lastRoot or path)
		)
	end,
})

local function indentMarks()
	vim.wo.lcs = 'tab:│ ,leadmultispace:│' .. string.rep(' ', vim.bo.sw - 1)
end
indentMarks()
vim.api.nvim_create_autocmd('BufEnter', { group = group, callback = indentMarks })

vim.api.nvim_create_autocmd('TextYankPost', {
	group = group,
	callback = function() require('vim.highlight').on_yank { higroup = 'Search', timeout = 50 } end,
})
vim.api.nvim_create_autocmd('FileType', {
	group = group,
	pattern = { 'qf', 'help', 'man' },
	command = 'nnoremap <buffer> q <Cmd>close<CR>',
})
vim.api.nvim_create_autocmd('FileType', {
	group = group,
	pattern = 'gitcommit',
	command = "lua map({'','i'},'<C-w>','<Esc>:BufferClose<CR>a',{buffer=true})",
})
vim.api.nvim_create_autocmd(
	'FileType',
	{ group = group, pattern = 'NvimTree', command = 'setlocal wrap' }
)
vim.api.nvim_create_autocmd('TermOpen', { group = group, command = 'setlocal nonu' })

local function hiNotes()
	vim.fn.matchadd('Todo', 'FIX')
	vim.fn.matchadd('Todo', 'TODO')
	vim.fn.matchadd('Todo', 'NOTE')
	vim.fn.matchadd('Todo', 'XXX')
	vim.fn.matchadd('Todo', 'DEBUG')
	vim.fn.matchadd('WarningMsg', 'WARN')
	vim.fn.matchadd('ErrorMsg', 'ERROR')
end
vim.api.nvim_create_autocmd('WinEnter', { group = group, callback = hiNotes })
hiNotes()

vim.api.nvim_create_autocmd('BufRead', {
	group = group,
	callback = function(state)
		local f = state.file
		if f:find('.git/', 1, true) or f:find '^/tmp' or f:find('.cache/', 1, true) then
			vim.bo[state.buf].undofile = false
		end
	end,
})

--[[ local of = {}
for _, v in ipairs(vim.v.oldfiles) do
	if not v:find('.git/', 7, true) and not v:find('NvimTree_', 2, true) then
		of[#of+1] = v
	end
end
vim.v.oldfiles = of ]]
