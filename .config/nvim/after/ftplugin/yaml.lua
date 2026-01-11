vim.bo.expandtab = true
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
