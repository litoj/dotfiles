return { -- https://clangd.llvm.org/config
	format = false,
	capabilities = { offsetEncoding = 'utf-8' },
	root_markers = {
		'src',
		'Makefile',
		'CMakeLists.txt',
	},
}
