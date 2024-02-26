map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|make||!compiler %:p<CR><CR>', { buffer = true })
map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o<CR><CR>", { buffer = true })
map(
	{ 'n', 'i' },
	'<A-B>',
	"<C-s><Cmd>!make debug||gcc -Wall -pedantic -g -fsanitize=address,leak,undefined -DDEBUG '%:p' -o '%:r'.out<CR>",
	{ buffer = true, remap = true }
)
map({ 'n', 'i' }, '<A-T>', "<C-s><Cmd>!cd '%:h' && make test<CR>", { buffer = true, remap = true })
map({ 'n', 'i' }, '<A-M>', "<Cmd>w|!cd '%:h' && make all<CR>", { buffer = true })
