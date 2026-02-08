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
		oldfiles = { stat_file = exists, include_current_session = true },
		previewers = {
			builtin = { syntax_limit_b = 204800 },
		},
	}

	vim.lsp.buf.document_symbol = fzf.lsp_document_symbols
	vim.lsp.buf.references = fzf.lsp_references
	vim.lsp.buf.implementation = fzf.lsp_implementations
	vim.lsp.buf.declaration = fzf.lsp_declarations
	vim.lsp.buf.definition = fzf.lsp_definitions

	map('n', ' of', fzf.oldfiles)
	map('n', ' co', function() fzf.oldfiles { cwd_only = true } end)
	map('n', ' cf', function() fzf.files { cwd = vim.fn.expand '%:h' } end) -- current list
	map('n', ' pf', fzf.files)
	map('n', ' pg', fzf.live_grep_native)
	-- map('n', ' ps', fzf.lsp_live_workspace_symbols)
	map('n', ' pd', fzf.diagnostics_workspace) -- list diagnostics
	map('n', ' bl', fzf.buffers)
	map({ '', 'i' }, '<C-f>', fzf.blines)
	map('n', ' mC', fzf.highlights) -- my colors
	map('n', ' ql', fzf.quickfix)
	map('n', ' ll', fzf.loclist)
end
return M
