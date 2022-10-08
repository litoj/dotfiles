lsp_setup("texlab", {
	settings = {
		documentFormatting = true,
		texlab = {
			formatterLineLength = 100,
			latexindent = {
				['local'] = os.getenv("HOME") .. "/.config/latexindent.yaml",
				modifyLineBreaks = true,
			},
		},
	},
})
