if not vim.bo.modifiable then return end
vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
local function enter_or_list()
	local line =
		vim.api.nvim_buf_get_lines(0, vim.fn.line '.' - 1, -1, false)[1]:match '^%s*%d*[%d%-—.)]+.?'
	if not line then
		return '\r'
	else
		local start, finish = line:find '[%d%-.)]*%d'
		local main
		if not start or not finish then
			start, finish = line:find '[%-.%)]+.?'
			if not start then return '\r' end
			return '\r' .. line:sub(start, finish)
		else
			main = line:sub(start, finish)
			local suffix = line:sub(finish + 1)
			return table.concat {
				'\r',
				main,
				vim.api.nvim_replace_termcodes('<Esc><C-a>a', true, true, true),
				suffix,
			}
		end
	end
end

map('i', '<Enter>', enter_or_list, { buffer = true, expr = true })
map('i', '<S-Enter>', '<End><Enter>', { buffer = true, remap = true })
map('n', '<A-R>', '<Cmd>MarpToggle<CR><CR>')
map(
	{ 'n', 'i' },
	'<A-r>',
	'<C-s><Cmd>!$BROWSER --new-tab (compiler "%:p") & && swaymsg [app_id="$BROWSER"] focus<CR><CR>',
	{ buffer = true, remap = true }
)
map(
	{ 'n', 'i' },
	'<A-B>',
	'<C-s><Cmd>!pandoc --pdf-engine=pdfroff "%:p" -o "%:r.pdf" && zathura "%:r.pdf" &<CR><CR>',
	{ buffer = true, remap = true }
)
local opt = { buffer = true }
map('i', '<A-q>', '\\', opt)
map('i', '...', '…', opt)

local reformGen = require('reform.toggle').gen_sub_applicator
local function genFor1W(str)
	return reformGen {
		vimre = [[[*_`]\@<!\(]]
			.. str:gsub('%*', '\\*')
			.. [[\)\?\([^/;:=, +]]
			.. str:sub(1, 1)
			.. [[]\+\)\1[*_`]\@!\([;:=,]\)\?]],
		use = function(_, match)
			return (#match[2] > 0 and match[3] or str .. match[3] .. str) .. match[4]
		end,
	}
end
map('i', '<A-b>', genFor1W '**', opt)
map('i', '<A-i>', genFor1W '_', opt)
map('i', '<A-`>', genFor1W '`', opt)

local function genForNW(str)
	return reformGen {
		vimre = '\\(' .. str:gsub('%*', '\\*') .. [[\)\?\([*_` \-]\@!\( \?(\@![^;:=, ]] .. str:sub(
			1,
			1
		) .. [[]\+\( \W\|[)*_`]\)\@<!\)\+\)\1\([;:=,]\)\?]],
		use = function(_, match)
			return (#match[2] > 0 and match[3] or str .. match[3] .. str) .. match[6]
		end,
	}
end
map('i', '<C-b>', genForNW '**', opt)
map('i', '<C-I>', genForNW '_', opt)
local tabmap
map('i', '<Tab>', function()
	if not tabmap then
		for _, v in ipairs(vim.api.nvim_get_keymap 'i') do
			if v.lhs == '<Tab>' then
				tabmap = v.callback
				break
			end
		end
	end
	if tabmap then tabmap() end
end, opt)
map('i', '<C-;>', genForNW '`', opt)
map('i', '<C-@>', genForNW '`', opt)

local function genForVisual(str) -- doesn't work for visual line nor multiline
	return function()
		local pos = vim.api.nvim_win_get_cursor(0)
		local from, to = vim.fn.col 'v', pos[2] + 1
		if from > to then
			local tmp = from
			from = to
			to = tmp
		end
		local line = vim.api.nvim_get_current_line()
		vim.api.nvim_set_current_line(
			line:sub(1, from - 1) .. str .. line:sub(from, to) .. str .. line:sub(to + 1)
		)
	end
end
map('v', '<A-b>', genForVisual '**', opt)
map('v', '<A-i>', genForVisual '_', opt)
map('v', '<A-`>', genForVisual '`', opt)

local function genForMove(backward) -- TODO: generalize→reform as matcher → node → operators (del/mv)
	local ev = {
		filter = {
			tolerance = { startPost = backward and 0 or 6, endPre = backward and 6 or 0 },
			sorting = function(ev, order, matcher, match)
				return (match.from <= ev.column and match.to >= ev.column - 1) and -1000
					or (backward and ev.column - match.from or match.to - ev.column)
			end,
		},
	}
	local matcher = {
		vimre = [[\(\*\*\|[_`]\)\?\([*_` \-]\@!\( \?(\@![^;:=, _*`]\+\( \W\|[)*_`]\)\@<!\)\+\)\1\([;:=,]\)\?]],
		use = function(_, match, ev)
			if match.from >= 1 then match.from = match.from - 1 end
			if (backward and match.from or match.to) == ev.column - 1 then return false end
			vim.api.nvim_win_set_cursor(0, {
				ev.line,
				backward and match.from or match.to,
				--[[ toStart and (match.to < ev.column - 2 and match.to or match.from)
					or (match.from > ev.column and match.from or match.to), ]]
			})
		end,
	}
	return function()
		if require('reform.util').apply_matcher(matcher, ev) then return end
		local line = vim.fn.line '.'
		if backward then
			if line == 1 then return end
			vim.api.nvim_win_set_cursor(0, { line - 1, 1000 })
		else
			if line + 1 >= vim.api.nvim_buf_line_count(0) then
				vim.api.nvim_win_set_cursor(0, { line, #vim.api.nvim_get_current_line() })
			else
				vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
				local textStart = vim.api.nvim_get_current_line():find '[^ %-0-9.]'
				vim.api.nvim_win_set_cursor(0, { line + 1, textStart and textStart - 1 or 1000 })
			end
		end
	end
end
map({ '', 'i' }, '<C-h>', genForMove(true), opt)
map({ '', 'i' }, '<C-l>', genForMove(false), opt)

vim.wo.conceallevel = 2
