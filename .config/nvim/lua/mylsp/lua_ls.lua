return { -- https://luals.github.io/wiki/settings/
	settings = {
		Lua = {
			format = { enable = false },
			runtime = { version = 'LuaJIT' },
			diagnostics = { globals = { 'vim' } },
			-- hint = { enable = true, paramType = true },
			workspace = {
				checkThirdParty = false,
				library = { os.getenv 'HOME' .. '/.config/nvim/init.lua' },
			},
			completion = { autoRequire = false, showParams = false, callSnippet = 'Replace' },
			type = { castNumberToInteger = true },
		},
	},
}
