local profiles = {
	['/nvim'] = {
		diagnostics = { globals = { 'vim' } },
	},
	['%.config/nvim'] = {
		workspace = {
			library = { os.getenv 'HOME' .. '/.config/nvim/init.lua' },
		},
	},
	-- swayimg Lua scripts (embeds PUC-Lua 5.4)
	swayimg = {
		runtime = { version = 'Lua 5.4' },
		workspace = {
			library = { '/usr/share/swayimg/swayimg.lua', os.getenv'HOME'..'/.config/swayimg/api.lua' },
		},
	},
}

return {
	---@param client vim.lsp.Client
	on_attach = function(client, _)
		for pattern, profile in pairs(profiles) do
			if client.root_dir:find(pattern) then
				if client.settings then
					client.settings.Lua = vim.tbl_deep_extend('force', client.settings.Lua, profile)
				else
					client.config.settings =
						vim.tbl_deep_extend('force', client.config.settings, { Lua = profile })
				end
			end
		end
	end,

	-- doesn't work - always uses utf-16
	capabilities = { positionEncodings = { 'utf-8' }, offsetEncoding = 'utf-8' },
	settings = {
		Lua = { -- https://luals.github.io/wiki/settings/
			codeLens = { enable = false },
			completion = { autoRequire = false, showParams = true, callSnippet = 'Replace' },
			hint = { enable = true, paramName = 'Disable', setType = true },
			type = { castNumberToInteger = true, weakNilCheck = true, weakUnionCheck = true },
			runtime = { version = 'LuaJIT' },
			workspace = { checkThirdParty = false, library = {} },
			format = {
				enable = false, -- TODO: try to switch
				--[[ defaultConfig = {
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
				}, ]]
			},
		},
	},

	root_markers = { 'lua', 'after', 'init.lua' },
}
