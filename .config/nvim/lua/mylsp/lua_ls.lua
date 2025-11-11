return {
	settings = {
		Lua = { -- https://luals.github.io/wiki/settings/
			completion = { autoRequire = false, showParams = true, callSnippet = 'Disable' },
			format = {
				enable = false, -- TODO: try to switch
				defaultConfig = {
					-- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/lua.template.editorconfig
					quote_style = 'single',
					indent_style = vim.bo.expandtab and 'space' or 'tab',
					indent_size = vim.bo.shiftwidth,
					tab_width = vim.bo.tabstop,
					continuation_indent = vim.bo.shiftwidth,
					max_line_length = vim.bo.textwidth,
					table_separator_style = 'comma',
					trailing_table_separator = 'smart',
					call_arg_parentheses = 'remove',
					align_continuous_rect_table_field = 'false',
				},
			},
			hint = { enable = true, paramName = 'Disable', setType = true },
			runtime = { version = 'LuaJIT' },
			type = { castNumberToInteger = true, weakNilCheck = true, weakUnionCheck = true },
			workspace = {
				checkThirdParty = false,
				library = { os.getenv 'HOME' .. '/.config/nvim/init.lua' },
			},
		},
	},
}
