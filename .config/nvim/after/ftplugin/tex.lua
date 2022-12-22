if vim.bo.bufhidden ~= "" then return end
vim.bo.textwidth = 90
vim.bo.commentstring = "%%s"
-- \usepackage[autostyle]{csquotes}
local function enter_or_item()
	local line =
			vim.api.nvim_buf_get_lines(0, vim.fn.line(".") - 1, -1, false)[1]:match("^%s*\\item.?")
	if not line then
		return "\r"
	else
		return "\r\b\\item "
	end
end

map("i", "<CR>", enter_or_item, {buffer = true, expr = true})
map("i", "<S-Space>", "\\,\\,", {buffer = true})
map("i", ",,", "\\,\\,", {buffer = true})
map("i", ",em", "\\emph{}<left>", {buffer = true})
map("i", ",vs", "\\vspace{m}<left><left>", {buffer = true})
map("i", ",hs", "\\hspace{m}<left><left>", {buffer = true})
map("i", "<M-q>", "\\enquote{}<left>", {buffer = true})
map("i", "<M-b>", "\\textbf{}<left>", {buffer = true})
map("i", "<M-c>", "\\texttt{}<left>", {buffer = true})
map("i", "<M-i>", "\\textit{}<left>", {buffer = true})
map("i", "<M-u>", "\\underline{}<left>", {buffer = true})

map({"n", "i"}, "<M-B>",
		'<Cmd>!set x (compiler "%:p"); if not pgrep -f "zathura $x"; zathura "$x" &; end<CR>',
		{buffer = true})
map({"n", "i"}, "<M-r>",
		'<Cmd>w|!set x (compiler "%:p"); if not pgrep -f "zathura $x"; zathura "$x" &; end<CR><CR>',
		{buffer = true})
