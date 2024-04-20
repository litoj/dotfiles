local M = { 'ibhagwan/fzf-lua', event = 'VeryLazy' }
function M.config()
	local fzf = require 'fzf-lua'
	fzf.setup {
		fzf_colors = {
			hl = { 'fg', 'LightBlue' },
			gutter = { 'bg', 'Bg1' },
			prompt = { 'fg', 'FloatTitle', 'bold' },
			info = { 'fg', 'Number' },
			pointer = { 'fg', 'Red' },
			marker = { 'fg', 'Operator', 'bold' },
			separator = { 'bg', 'Normal' },
			['hl+'] = { 'fg', 'Search' },
			['fg+'] = { 'fg', 'Fg1' },
			['bg+'] = { 'bg', 'Bg2' },
		},
		files = {
			prompt = 'Files> ',
			git_icons = false,
			fd_opts = [[--color=never --type f --follow -d 10 -E Android \
		-E node_modules -E deps -E build -S '-100k']],
		},
		lsp = { jump_to_single_result = true, ignore_current_line = true },
	}

	vim.lsp.handlers['textDocument/declaration'] = fzf.lsp_declarations
	vim.lsp.handlers['textDocument/definition'] = fzf.lsp_definitions
	vim.lsp.handlers['textDocument/references'] = fzf.lsp_references
	vim.lsp.handlers['textDocument/implementation'] = fzf.lsp_implementation

	map('n', 'gd', vim.lsp.buf.definition)
	map('n', 'gr', vim.lsp.buf.references)
	map('n', ' fb', function() fzf.files { cwd = vim.api.nvim_buf_get_name(0):gsub('[^/]+$', '') } end)
	map('n', ' fl', fzf.files)
	map('n', ' fo', fzf.oldfiles)
	map('n', ' fO', function() fzf.oldfiles { cwd_only = true } end)
	map('n', ' fg', fzf.live_grep)
	map('n', ' b', fzf.buffers)
	map('n', ' dl', fzf.lsp_workspace_diagnostics) -- list diagnostics
	map('n', ' mc', fzf.highlights) -- my - colors
end
return M
