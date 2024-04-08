return { -- https://github.com/latex-lsp/texlab/wiki/Configuration
	settings = {
		texlab = {
			formatterLineLength = 100,
			latexindent = {
				['local'] = os.getenv 'HOME' .. '/.config/latexindent.yaml',
				modifyLineBreaks = true,
			},
		},
	},
}
