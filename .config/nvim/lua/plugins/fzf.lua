local M = { 'ibhagwan/fzf-lua', event = 'VeryLazy' }
function M.config()
	local fzf = require 'fzf-lua'
	local colors = {
		header = { 'fg', 'Fg3' },
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
	}
	fzf.setup {
		'skim',
		fzf_colors = vim.tbl_extend('force', colors, { current_match_bg = '#0000' }), -- for skim
		files = {
			prompt = 'Files> ',
			git_icons = false,
			fd_opts = [[--color=never --type f --follow -d 10 \
				-E Android -E node_modules -E deps -E build -S '-100k']],
		},
		grep = {
			rg_opts = [[--column --line-number --no-heading --color=always --smart-case \
				--max-columns=255 --colors=line:fg:magenta --colors=column:fg:magenta \
				--colors=path:fg:green --colors=match:fg:red -e]],
		},
		lsp = { jump_to_single_result = true, ignore_current_line = true },
		oldfiles = { fzf_colors = colors, fzf_bin = 'fzf', stat_file = exists },
	}

	vim.lsp.handlers['textDocument/declaration'] = fzf.lsp_declarations
	vim.lsp.handlers['textDocument/definition'] = fzf.lsp_definitions
	vim.lsp.handlers['textDocument/references'] = fzf.lsp_references
	vim.lsp.handlers['textDocument/implementation'] = fzf.lsp_implementation

	map('n', ' pf', fzf.files)
	map('n', ' pg', fzf.live_grep_native)
	map('n', ' bf', function() fzf.files { cwd = vim.fn.expand '%:h' } end)
	map('n', ' bl', fzf.buffers)
	map('n', ' of', fzf.oldfiles)
	map('n', ' ql', fzf.quickfix)
	map({ '', 'i' }, '<C-/>', fzf.blines)
	map({ '', 'i' }, '<C-f>', fzf.blines)
	map('n', ' dl', fzf.diagnostics_workspace) -- list diagnostics
	map('n', ' mc', fzf.highlights) -- my colors
end
return M
