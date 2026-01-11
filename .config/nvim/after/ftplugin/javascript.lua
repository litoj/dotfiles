map(
	{ 'n', 'i' },
	'<A-S-R>',
	function() vim.cmd.term('node ' .. vim.api.nvim_buf_get_name(0)) end,
	{ buffer = true }
)
