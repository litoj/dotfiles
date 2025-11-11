local M = { 'ibhagwan/fzf-lua', event = 'VeryLazy' }
function M.config()
	local fzf = require 'fzf-lua'
	fzf.setup {
		-- 'skim',
		fzf_colors = {
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
			-- current_match_bg = '#0000', -- for skim
		},
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
		lsp = { jump1 = true, ignore_current_line = true },
		oldfiles = { stat_file = exists },
	}

	vim.lsp.buf.document_symbol = fzf.lsp_document_symbols
	vim.lsp.buf.references = fzf.lsp_references
	vim.lsp.buf.implementation = fzf.lsp_implementations

	map('n', 'gD', fzf.lsp_declarations)
	map('n', 'gd', fzf.lsp_definitions)

	map('n', ' pf', fzf.files)
	map('n', ' pg', fzf.live_grep_native)
	map('n', ' po', function() fzf.oldfiles { cwd_only = true } end)
	-- map('n', ' ps', fzf.lsp_live_workspace_symbols)
	map('n', ' pd', fzf.diagnostics_workspace) -- list diagnostics
	map('n', ' cl', function() fzf.files { cwd = vim.fn.expand '%:h' } end) -- current list
	map('n', ' bl', fzf.buffers) -- buffers list
	map('n', ' of', fzf.oldfiles)
	map('n', ' ql', fzf.quickfix) -- quickfix list
	map({ '', 'i' }, '<C-/>', fzf.blines)
	map({ '', 'i' }, '<C-f>', fzf.blines)
	map('n', ' mc', fzf.highlights) -- my colors
end
return M
