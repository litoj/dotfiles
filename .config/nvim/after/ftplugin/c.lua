map({"n", "i"}, "<M-b>", "<Cmd>w|cd %:h|term compiler %:p<CR>", {buffer = true})
map({"n", "i"}, "<M-r>", "<Cmd>w|!compiler %:p<CR><CR>", {buffer = true})
map({"n", "i"}, "<M-B>",
		"<Cmd>w|!make debug||gcc -Wall -pedantic -g -fsanitize=address,leak,undefined -DDEBUG %:p -o %:p:r.out<CR>",
		{buffer = true})
map({"n", "i"}, "<M-M>", "<Cmd>w|!cd %:h && make<CR>", {buffer = true})
