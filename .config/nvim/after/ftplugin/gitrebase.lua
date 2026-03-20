for _, key in ipairs { 'p', 'r', 'e', 's', 'f', 'd', 'x', 'b', 'l', 'r', 't', 'm' } do
	vim.keymap.set('n', key, 'ciw' .. key .. '<Esc>j', { silent = true, buffer = true })
end
