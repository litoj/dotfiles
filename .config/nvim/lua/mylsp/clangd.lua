return { -- https://clangd.llvm.org/config
	format = false,
	capabilities = { positionEncodings = { 'utf-8' } },
	init_options = {
		-- fallbackFlags = { '--std=c++20' },
	},
	cmd = function(dispatchers)
		local cmd = {
			'clangd',
			'--background-index',
			'--clang-tidy',
		}

		local h = require 'fthelper'
		local root = h.findDirOf 'src/'
		if root and not exists(root .. 'compile_commands.json') then
			local commands = exists '/tmp/build/compile_commands.json' and '/tmp/build/'
				or h.glob(root .. '*build*/compile_commands.json')[1]
			if commands then cmd[#cmd + 1] = '--compile-commands-dir=' .. commands:match '.+/' end
		end

		return vim.lsp.rpc.start(cmd, dispatchers)
	end,
	root_markers = {
		'src',
		'Makefile',
		'.clang-tidy',
		'.clang-format',
		'CMakeLists.txt',
		'meson.build',
		'build.ninja',
		'.git',
	},
}
