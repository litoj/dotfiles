map(
	{ 'n', 'i' },
	'<A-R>',
	function() vim.cmd.term('node ' .. vim.api.nvim_buf_get_name(0)) end,
	{ buffer = true }
)
