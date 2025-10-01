return {
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		if fname:match '%.env$' then return end
		on_dir(fname:match '.+/')
	end,
	settings = {
		bashIde = {
			shfmt = { path = '' }, -- use null-ls instead
			-- shellcheckPath = '',
		},
	},
}
