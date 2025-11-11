return {
	settings = {
		rulesCustomizations = {
			{ rule = '*', severity = 'info' },
			{ rule = '*/no-unused-vars-experimental', severity = 'off' },
		},
	},
	single_file_support = false,
	setCwd = false,
	handlers = {
		['textDocument/diagnostic'] = function(error, result, ctx, config)
			if error and error.code == -32603 then
				vim.lsp.buf_detach_client(ctx.bufnr, ctx.client_id)
				vim.notify('eslint: no config', vim.log.levels.WARN)
				return
			end
			vim.lsp.handlers['textDocument/diagnostic'](error, result, ctx, config)
		end,
	},
}
