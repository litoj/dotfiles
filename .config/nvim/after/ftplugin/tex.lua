if vim.bo.bufhidden ~= '' then return end

local function find_main_tex(buf)
	local dir = vim.api.nvim_buf_get_name(buf or 0):match '(.+)/'

	while dir and #dir > 1 do
		for file in vim.fs.dir(dir) do
			if file:match '%.tex$' then
				file = dir .. '/' .. file
				local f = io.open(file, 'r') or error('no file: ' .. file)
				for line in f:lines '*l' do
					if #line > 0 and line:sub(1, 1) ~= '%' then -- skip all comments
						if vim.startswith(line, '\\documentclass') then
							f:close()
							return file
						else
							break
						end
					end
				end
				f:close()
			end
		end

		dir = dir:match '(.+)/'
	end

	error 'no \\documentclass file found'
end

local map, modmap = require('fthelper').once {
	---@module "mylsp.init"
	---@param ml mylsp
	mylsp = function(ml)
		local cfg = require 'mylsp.texlab'
		cfg.root_dir = function(bufnr, on_dir) on_dir(find_main_tex(bufnr):match '.+/') end
		ml.setup('texlab', cfg)
	end,
}

modmap {
	---@module 'manipulator'
	---@param m manipulator
	['manipulator'] = function(m, buf)
		local mapAll = require('plugins.manipulator').mapAll
		mapAll('chapter', { 'chapter', 'section', 'subsection', 'subsubsection' }, { buffer = buf })
		mapAll('figure block', { 'begin' }, { buffer = buf })
		local function renameEnv()
			local env = m.ts.current({ types = { 'begin', 'end' } }):parent()
			if not env or not env.range then return end
			local bopts = { inherit = false, types = { 'curly_group_text' }, src = '.' }
			local eopts = { inherit = false, types = { 'curly_group_text' }, direction = 'backward' }
			local o = env.range
			local b = env:descendant(bopts):paste { text = '{}' }

			b:highlight 'Visual'

			b.range[2] = b.range[2] + 1 -- after the curly brace
			b:jump { start_insert = true }
			o[4] = 4 -- make the environment block be selectable by range - ignore end env name

			local group = vim.api.nvim_create_augroup('env-sync', { clear = true })
			vim.api.nvim_create_autocmd({ 'CursorMovedI', 'CursorMoved' }, {
				buffer = buf,
				group = group,
				callback = function(s)
					b = m.ts.current(bopts)
					env = m.ts.get(o) or error 'env size changed'
					local e = env:descendant(eopts) or error 'env with no end'
					if s.event == 'CursorMoved' or not b or not b.range then
						env:descendant(bopts):highlight(false)
						e:highlight(false)
						vim.api.nvim_del_augroup_by_id(group)
						return
					end

					e:paste({ text = b:get_text() }):highlight 'Visual'
				end,
			})
		end
		map({ 'n', 'i' }, '<F2>', renameEnv)
		map('i', '<Tab>', renameEnv)
	end,
}

vim.bo.textwidth = 80
vim.bo.commentstring = '%%s'
-- \usepackage[autostyle]{csquotes}
local function enter_or_item()
	local line = vim.api.nvim_buf_get_lines(0, vim.fn.line '.' - 1, -1, false)[1]:match '^%s*\\item.?'
	return line and '\r\\item ' or '\r'
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
-- TODO: rewrite reform.matcher to allow just simple one-time match of the chars around cursor and
-- return the result for further processing
-- map('i', '-', '--')
map('i', '#', '\\#')
map('i', '<A-b>', '\\textbf{}<left>')
map('i', '<A-c>', '\\texttt{}<left>')
map('i', '<A-i>', '\\textit{}<left>')
map('i', '<A-u>', '\\underline{}<left>')

map('i', '<C-1>', '\\chapter{}<left>')
map('i', '<C-2>', '\\section{}<left>')
map('i', '<C-3>', '\\subsection{}<left>')
map('i', '<C-4>', '\\subsubsection{}<left>')
map('i', '<C-5>', '\\paragraph{}<left>')

map('i', '# ', '\\chapter{}<left>')
map('i', '## ', '\\section{}<left>')
map('i', '### ', '\\subsection{}<left>')
map('i', '#### ', '\\subsubsection{}<left>')
map('i', '##### ', '\\paragraph{}<left>')

local function get_main_tex()
	-- Try to get the texlab LSP client and check its cache
	local lsp = vim.lsp.get_clients({ bufnr = 0, name = 'texlab' })[1]
	local ret = lsp and lsp.main_tex or vim.b.main_tex
	if ret then return ret end

	ret = find_main_tex()

	-- Cache in LSP client if available
	---@diagnostic disable-next-line: inject-field
	if lsp then lsp.main_tex = ret end
	vim.b.main_tex = ret
	return ret
end

local function compile(windowed)
	local main = get_main_tex()

	local cmdBase = ('latexmk -pdflua "%s"'):format(main)
	local cmdFilter = '| grep -vF "(/usr/"'
	if windowed then
		return ('<Cmd>term %s -f %s<CR>'):format(cmdBase, cmdFilter)
	else
		return ('<Cmd>w|!%s%s && set x "%s" && if not pgrep -f "zathura $x"; zathura "$x" &; end<CR><Esc>'):format(
			cmdBase,
			cmdFilter,
			main:gsub('%.tex$', '.pdf')
		)
	end
end
map('n', '<A-b>', function() return compile(true) end, { expr = true })
map({ 'n', 'i' }, '<A-r>', compile, { expr = true })
