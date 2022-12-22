return {
	format = true,
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
