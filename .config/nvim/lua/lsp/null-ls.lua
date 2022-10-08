local nls = require "null-ls"

-- local h = require("null-ls.helpers")

nls.setup({
	-- single_file_support = true,
	-- init_options = {documentFormatting = true, codeAction = true},
	sources = {
		-- nls.builtins.formatting.latexindent.with {
		-- 	extra_args = {"-l", "~/.config/latexindent.yaml", "-g", "/dev/null"},
		-- },
		nls.builtins.formatting.lua_format.with {
			extra_args = {
				"--column-limit=" .. vim.o.textwidth,
				(vim.o.expandtab or "--use-tab"),
				"--tab-width=" .. vim.o.tabstop,
				"--indent-width=" .. (vim.o.expandtab and vim.o.shiftwidth or 1),
				"--continuation-indent-width=2",
				"--chop-down-table",
				"--no-align-table-field",
				"--no-align-parameter",
				"--no-align-args",
				"--extra-sep-at-table-end",
			},
		},
		nls.builtins.formatting.prettier.with {
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				-- "vue",
				"css",
				"scss",
				"less",
				-- "html",
				"json",
				"yaml",
				"markdown",
				"graphql",
			},
			extra_args = {
				"--print-width=" .. vim.o.textwidth,
				(vim.o.expandtab or "--use-tabs"),
				"--no-semi",
			},
		},
		nls.builtins.formatting.shfmt.with {
			extra_args = {"-ci", "-s", "-sr", "-i", (vim.o.expandtab and vim.o.tabstop or 0)},
		},
		nls.builtins.formatting.clang_format.with {
			extra_args = {"--style", "{UseTab: Always, TabWidth: 2}"},
		},
		-- nls.builtins.diagnostics.shellcheck,
		-- nls.builtins.code_actions.shellcheck,
		-- nls.builtins.diagnostics.eslint,
		nls.builtins.code_actions.eslint,
		nls.builtins.formatting.yapf,
	},
})
