if vim.bo.bufhidden ~= '' then return end

local map, modmap = require 'fthelper' {
	mylsp = function(ml) ml.setup 'texlab' end,
}

modmap {
	['manipulator.call_path'] = function(mcp)
		local nj = mcp.tsregion['&1']:collect(2, 'child').at(-1).jump['*1']
		local tsn = nj.next_in_graph
		local tsp = nj.prev_in_graph
		local chaps = { types = { 'chapter', 'section', 'subsection', 'subsubsection' } }
		map('n', ']c', tsn(chaps).fn)
		map('n', '[c', tsp(chaps).fn)
		map('n', ']s', tsn({ types = { 'begin' } }).fn)
		map('n', '[s', tsp({ types = { 'begin' } }).fn)
		local pick = nj['&1']:pick({ picker = 'fzf-lua' })['*1']
		map('n', 'gts', pick:collect(mcp():next_in_graph(chaps), mcp():prev_in_graph(chaps)).fn)
		map('n', 'gtf', pick:get_all({ types = { 'begin' } }).fn)
		local envMatcher = mcp.tsregion({ types = { 'begin', 'end' } }):parent()
		map(
			{ 'n', 'i' },
			'<F2>',
			envMatcher:apply(function(self)
				local braceMatch = { inherit = false, types = { curly_group_text = true } }
				local o = self:range0()
				require 'autocommands'('CursorMovedI', function()
					local new = envMatcher:exec()
					local nr = new:range0()
					if new.buf == self.buf and nr[1] == o[1] and nr[2] == o[2] and nr[3] == o[3] then
						local b, e = new:child(0, braceMatch), new:child(-1, braceMatch)
						e:paste { text = b:get_text() }
					else
						return true
					end
				end)
				local b = self:child(0, { types = { text = true } })
				b:jump { insert = true }
				b:paste { text = '' }
			end).fn
		)
	end,
}

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

map('i', '<CR>', enter_or_item, { expr = true })
-- short space: \\, vs inseparable space: ~
-- can be mostly done automatically using \usepackage{luavlna} (or xevlna)
map('i', '<S-Space>', '~')
map('i', ',em', '\\emph{}<left>')
map('i', ',vs', '\\vspace{m}<left><left>')
map('i', ',hs', '\\hspace{m}<left><left>')
-- \\enquote or \\uv
map('i', '<A-q>', '\\uv{}<left>')
map('i', '...', '\\dots{}')
map('i', '<A-b>', '\\textbf{}<left>')
map('i', '<A-c>', '\\texttt{}<left>')
map('i', '<A-i>', '\\textit{}<left>')
map('i', '<A-u>', '\\underline{}<left>')

local compile = 'set x (compiler "%:p"); if not pgrep -f "zathura $x"; zathura "$x" &; end'
map({ 'n', 'i' }, '<A-S-B>', '<Cmd>term ' .. compile .. '<CR>')
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!' .. compile .. '<CR><CR>')
