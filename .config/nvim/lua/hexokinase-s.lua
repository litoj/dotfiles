vim.g.Hexokinase_refreshEvents = {"InsertLeave"}
vim.g.Hexokinase_optInPatterns = {"full_hex", "triple_hex", "rgb", "rgba"}
vim.g.Hexokinase_highlighters = {"backgroundfull"}
vim.cmd("autocmd BufEnter * HexokinaseTurnOn")
