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
map(
	{ 'n', 'i' },
	'<A-r>',
	'<C-s><Cmd>!$BROWSER --new-tab (compiler "%:p") & && swaymsg [app_id="$BROWSER"] focus<CR><CR>',
	{ buffer = true, remap = true }
)
map(
	{ 'n', 'i' },
	'<A-p>',
	'<C-s><Cmd>!pandoc --pdf-engine=pdfroff "%:p" -o "%:r.pdf" && zathura "%:r.pdf" &<CR><CR>',
	{ buffer = true, remap = true }
)
local opt = { buffer = true }
map('i', '<A-q>', '\\', opt)
map('i', '...', '…', opt)

local reformGen = require('reform.toggle').genSubApplicator
local function genFor1W(str)
	return reformGen {
		vimre = [[[(*_`]\@!\(]]
			.. str:gsub('%*', '\\*')
			.. [[\)\?\([^/;:=, +]]
			.. str:sub(1, 1)
			.. [[]\+\)\1[)*_`]\@<!\([);:=,]\)\?]],
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
		vimre = '\\('
			.. str:gsub('%*', '\\*')
			.. [[\)\?\([*_` ]\@!\( \?(\@![^;:=, ]]
			.. str:sub(1, 1)
			.. [[]\+\( \W\|[)*_`]\)\@<!\)\+\)\1\([;:=,]\)\?]],
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
vim.wo.conceallevel = 2
