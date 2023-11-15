map({ 'n', 'i' }, '<M-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buffer = true })
map({ 'n', 'i' }, '<M-r>', '<Cmd>w|make||!compiler %:p<CR><CR>', { buffer = true })
map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o<CR><CR>", { buffer = true })
map(
	{ 'n', 'i' },
	'<M-B>',
	"<C-s><Cmd>!make debug||gcc -Wall -pedantic -g -fsanitize=address,leak,undefined -DDEBUG '%:p' -o '%:r'.out<CR>",
	{ buffer = true, remap = true }
)
map({ 'n', 'i' }, '<M-T>', "<C-s><Cmd>!cd '%:h' && make test<CR>", { buffer = true, remap = true })
map({ 'n', 'i' }, '<M-M>', "<Cmd>w|!cd '%:h' && make all<CR>", { buffer = true })
