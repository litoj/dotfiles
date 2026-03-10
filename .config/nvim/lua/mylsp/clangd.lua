return { -- https://clangd.llvm.org/config
	format = false,
	capabilities = { positionEncodings = { 'utf-8' } },
	init_options = {
		fallbackFlags = { '--std=c++20' },
	},
	cmd = {
		'clangd',
		'--background-index',
		'--clang-tidy',
	},
	root_markers = {
		'src',
		'Makefile',
		'CMakeLists.txt',
		'meson.build',
		'build.ninja',
		'.git',
	},
}
