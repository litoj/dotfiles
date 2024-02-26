map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!compiler %:p<CR><CR>', { buffer = true })
map(
	{ 'n', 'i' },
	'<A-B>',
	'<Cmd>w|!make debug||g++ -std=c++17 -Wall -pedantic -g -fsanitize=address,leak -DDEBUG %:p -o %:p:r.out<CR>',
	{ buffer = true }
)
map({ 'n', 'i' }, '<A-M>', '<Cmd>w|!cd %:h && make<CR>', { buffer = true })
