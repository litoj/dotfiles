---@module 'lspconfig'
---@type {[string]:_.lspconfig.settings.lua_ls.Lua}
local profiles = {
	['/nvim'] = {
		diagnostics = { globals = { 'vim' } },
	},
	['%.config/nvim'] = {
		workspace = {
			library = {
				os.getenv 'HOME' .. '/.config/nvim/init.lua',
			},
		},
	},
	swayimg = {
		runtime = { path = { '?.lua' }, pathStrict = true },
		workspace = {
			library = {
				'/usr/share/swayimg/swayimg.lua',
				'/usr/local/share/swayimg/swayimg.lua',
			},
		},
	},
}

---@type vim.lsp.Config
return {
	---@type lspconfig.settings.lua_ls
	settings = {
		Lua = { -- https://luals.github.io/wiki/settings/
			codeLens = { enable = false },
			completion = { autoRequire = false, showParams = true, callSnippet = 'Disable', keywordSnippet='Disable' },
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
	root_markers = { '.editorconfig', '.stylua.toml', 'lua', 'after', 'init.lua', '.git' },

	---@param client vim.lsp.Client
	on_attach = function(client, buf)
		-- vim.api.nvim_create_autocmd('InsertLeave', {
		-- 	buffer = buf,
		-- 	callback = function() vim.diagnostic.show(nil, buf) end,
		-- })
		local extend = require('manipulator.utils').tbl_inner_extend
		local file = vim.api.nvim_buf_get_name(buf)
		for pattern, profile in pairs(profiles) do
			if file:find(pattern) then
				local t = extend('keep', client.config.settings, { Lua = profile }, true)

				local u = {} -- deduplicate entries
				for _, v in ipairs(t.Lua.workspace.library) do
					u[v] = 1
				end
				local l = {}
				for k, _ in pairs(u) do
					l[#l + 1] = k
				end
				t.Lua.workspace.library = l

				client:notify('workspace/didChangeConfiguration', { settings = t })
			end
		end
	end,
}
