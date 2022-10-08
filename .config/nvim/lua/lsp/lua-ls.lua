-- https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
lsp_setup("sumneko_lua", {
	settings = {
		Lua = {
			diagnostics = {globals = {"vim"}},
			-- workspace = {library = {["~/.local/share/nvim/site/pack/packer/start/"] = true}},
		},
	},
})
