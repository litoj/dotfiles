return { -- https://clangd.llvm.org/config
	format = false,
	capabilities = { offsetEncoding = 'utf-8' },
	root_dir = function(fname)
		return vim.fs.dirname(vim.fs.find({
			'src',
			'Makefile',
			'CMakeLists.txt',
			'.git',
		}, { upward = true, path = fname })[1])
	end,
}
