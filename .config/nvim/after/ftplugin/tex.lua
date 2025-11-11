if vim.bo.bufhidden ~= '' then return end
vim.bo.textwidth = 80
vim.bo.commentstring = '%%s'
-- \usepackage[autostyle]{csquotes}
local function enter_or_item()
	local line = vim.api.nvim_buf_get_lines(0, vim.fn.line '.' - 1, -1, false)[1]:match '^%s*\\item.?'
	if not line then
		return '\r'
	else
		return '\r\b\\item '
	end
end

map('i', '<CR>', enter_or_item, { buffer = true, expr = true })
-- short space: \\, vs inseparable space: ~
-- can be mostly done automatically using \usepackage{luavlna} (or xevlna)
map('i', '<S-Space>', '~', { buffer = true })
map('i', ',em', '\\emph{}<left>', { buffer = true })
map('i', ',vs', '\\vspace{m}<left><left>', { buffer = true })
map('i', ',hs', '\\hspace{m}<left><left>', { buffer = true })
-- \\enquote or \\uv
map('i', '<A-q>', '\\uv{}<left>', { buffer = true })
map('i', '...', '\\dots{}', { buffer = true })
map('i', '<A-b>', '\\textbf{}<left>', { buffer = true })
map('i', '<A-c>', '\\texttt{}<left>', { buffer = true })
map('i', '<A-i>', '\\textit{}<left>', { buffer = true })
map('i', '<A-u>', '\\underline{}<left>', { buffer = true })

local compile = 'set x (compiler "%:p"); if not pgrep -f "zathura $x"; zathura "$x" &; end'
map({ 'n', 'i' }, '<A-S-B>', '<Cmd>term ' .. compile .. '<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!' .. compile .. '<CR><CR>', { buffer = true })

local bid = vim.api.nvim_get_current_buf()
withMod('syntax-tree-surfer', function(sts)
	map(
		'n',
		'gts',
		sts.list { 'chapter', 'section', 'subsection', 'subsubsection' },
		{ buffer = bid }
	)
	map('n', 'gtf', sts.list { 'begin', 'end' }, { buffer = bid })
end)

if not vim.g.loaded then vim.g.loaded = {} end
if vim.g.loaded['tex'] then return end
vim.g.loaded['tex'] = true

withMod('mylsp', function(ml) ml.setup 'texlab' end)
