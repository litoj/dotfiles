if vim.bo.ft == 'cs' then
	vim.defer_fn(function() vim.cmd.LspStart 'omnisharp' end, 100)
else
	vim.api.nvim_create_autocmd(
		'FileType',
		{ pattern = 'cs', command = 'LspStart omnisharp', once = true }
	)
end
return {
	cmd = { 'omnisharp' },
	enable_import_completion = true,
}
