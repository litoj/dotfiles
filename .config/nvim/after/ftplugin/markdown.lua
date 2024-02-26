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
map('i', '<A-b>', '<C-o>ciw**<C-r>"**<Esc>', { buffer = true })
map('i', '<A-i>', '<C-o>ciw_<C-r>"_<Esc>', { buffer = true })
map('i', '<Enter>', enter_or_list, { buffer = true, expr = true })
map('i', '<A-d>', '<C-v>u2014', { buffer = true })
map('i', '<A-q>', '\\', { buffer = true })
map('i', '...', '…', { buffer = true })
vim.wo.conceallevel = 2
