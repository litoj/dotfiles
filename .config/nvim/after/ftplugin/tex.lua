if vim.bo.bufhidden ~= '' then return end

local map, modmap = require('fthelper').once {
	mylsp = function(ml) ml.setup 'texlab' end,
}

modmap {
	['manipulator.call_path'] = function(mcp, buf)
		local mapAll = require('plugins.manipulator').mapAll
		mapAll('chapter', { 'chapter', 'section', 'subsection', 'subsubsection' }, { buffer = buf })
		mapAll('figure block', { 'begin' }, { buffer = buf })
		local envMatcher = mcp.ts.current({ types = { 'begin', 'end' } }):parent()
		map(
			{ 'n', 'i' },
			'<F2>',
			envMatcher[
				function(self)
					local braceMatch = { inherit = false, types = { curly_group_text = true } }
					local o = self.range
					self:child({ types = { text = true } }, 0):paste({ text = '' }):jump { insert = true }

					require 'autocommands'('CursorMovedI', function()
						local new = envMatcher:exec()
						local nr = new.range
						if new.buf == self.buf and nr[1] == o[1] and nr[2] == o[2] and nr[3] == o[3] then
							-- get last child = 'end' and paste into the braces the text of 'begin'
							new:child(braceMatch, -1):paste { text = new:child(braceMatch, 0):get_text() }
						else
							return true
						end
					end)
				end
			].fn
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
