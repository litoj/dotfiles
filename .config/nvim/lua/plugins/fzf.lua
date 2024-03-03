local M = { 'ibhagwan/fzf-lua', keys = { ' s', ' a', ' o', ' f', ' g', ' d', 'gd', 'gr' } }
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
	map('n', ' s', function() fzf.files { cwd = vim.api.nvim_buf_get_name(0):gsub('[^/]+$', '') } end)
	map('n', ' a', fzf.files)
	map('n', ' o', fzf.oldfiles)
	map('n', ' f', function() fzf.oldfiles { cwd_only = true } end)
	map('n', ' g', fzf.live_grep)
	map('n', ' d', fzf.lsp_workspace_diagnostics)
	map('n', ' c', fzf.highlights)
end
return M
