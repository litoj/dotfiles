vim.bo.expandtab = true
vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
local function enter_or_list()
	local line =
		vim.api.nvim_buf_get_lines(0, vim.fn.line '.' - 1, -1, false)[1]:match '^%s*%d*[%d%-—.)]+.?'
	if not line then
		return '\r'
	else
		local start, finish = line:find '[%d%-—.)]*%d'
		local main
		if not start or not finish then
			start, finish = line:find '[%-—.%)]+.?'
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
	'<M-r>',
	'<C-s><Cmd>!$BROWSER --new-tab (compiler "%:p") & && swaymsg [app_id="$BROWSER"] focus<CR><CR>',
	{ buffer = true, remap = true }
)
map(
	{ 'n', 'i' },
	'<M-p>',
	'<C-s><Cmd>!pandoc --pdf-engine=pdfroff "%:p" -o "%:r.pdf" && zathura "%:r.pdf" &<CR><CR>',
	{ buffer = true, remap = true }
)
map('i', '<M-b>', '<Esc>llbi**<Esc>ea**', { buffer = true })
map('i', '<Enter>', enter_or_list, { buffer = true, expr = true })
map('i', '<M-d>', '<C-v>u2014', { buffer = true })
map('i', '<M-q>', '\\', { buffer = true })
vim.wo.conceallevel = 2