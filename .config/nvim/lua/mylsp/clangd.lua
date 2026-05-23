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
				or h.glob(root .. '*{debug,build}*/compile_commands.json')[1]
			if commands then cmd[#cmd + 1] = '--compile-commands-dir=' .. commands:match '.+/' end
		end

		return vim.lsp.rpc.start(cmd, dispatchers)
	end,
	on_attach = function(_, buf)
		map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|term compiler %:p<CR>', { buf = buf })
		map({ 'n', 'i' }, '<A-r>', '<Cmd>w|make||!compiler %:p<CR><CR>', { buf = buf })
		map({ 'n', 'i' }, '<C-s>', "<Cmd>w|!rm '%:r'.o '%:r'.out &>/dev/null || :<CR>", { buf = buf })

		map({ 'n', 'i' }, '<A-S-R>', function()
			local name = vim.api.nvim_buf_get_name(0)
			local out = name:gsub('%.c[cp]?p?$', '.out')
			if not exists(out) then vim.fn.glob(name:gsub('/[^/]*$', '/*.out')) end
			if not exists(out) then return vim.notify 'No executable found' end
			vim.cmd.term(out)
		end, { buf = buf })
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
