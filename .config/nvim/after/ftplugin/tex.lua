if vim.bo.bufhidden ~= '' then return end

local map, modmap = require('fthelper').once {
	mylsp = function(ml) ml.setup 'texlab' end,
}

modmap {
	['manipulator'] = function(m, buf) ---@param m manipulator
		local mapAll = require('plugins.manipulator').mapAll
		mapAll('chapter', { 'chapter', 'section', 'subsection', 'subsubsection' }, { buffer = buf })
		mapAll('figure block', { 'begin' }, { buffer = buf })
		map({ 'n', 'i' }, '<F2>', function()
			local self = m.ts.current({ types = { 'begin', 'end' } }):parent()
			if not self or not self.range then return end
			local opts = { inherit = false, types = { curly_group_text = true } }
			local o = self.range
			local b = self:child(0, opts):paste { text = '{}' }

			b:highlight 'Visual'

			b.range[2] = b.range[2] + 1 -- after the curly brace
			b:jump { start_insert = true }
			o[4] = 4 -- make the environment block be selectable by range - ignore end env name

			local group = vim.api.nvim_create_augroup('env-sync', {})
			vim.api.nvim_create_autocmd({ 'CursorMovedI', 'CursorMoved' }, {
				group = group,
				callback = function(s)
					b = m.ts.current { types = { curly_group_text = true } } or ''
					self = m.ts.get(o) or ''
					local e = self:child(-1, opts) or ''
					if not b.range or s.event == 'CursorMoved' then
						self:child(0, opts):highlight(false)
						e:highlight(false)
						vim.api.nvim_del_augroup_by_id(group)
						return
					end

					e:paste({ text = b:get_text() }):highlight 'Visual'
				end,
			})
		end)
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
