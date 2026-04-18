return { -- https://github.com/latex-lsp/texlab/wiki/Configuration
	settings = {
		texlab = {
			formatterLineLength = vim.bo.tw,
			latexindent = {
				['local'] = os.getenv 'HOME' .. '/.config/latexindent.yaml',
				modifyLineBreaks = true,
			},
		},
	},
}
