---@diagnostic disable: redundant-parameter
require'luasnip/loaders/from_vscode'.lazy_load()
local kind_icons = {
	Text = "  ",
	Method = "  ",
	Function = "  ",
	Constructor = "  ",
	Field = "  ",
	Variable = "  ",
	Class = " ﰮ ",
	Interface = "  ",
	Module = "  ",
	Property = " 襁",
	Unit = "  ",
	Value = "  ",
	Enum = " 練",
	Keyword = "  ",
	Snippet = "  ",
	Color = "  ",
	File = "  ",
	Folder = "  ",
	Reference = "  ",
	EnumMember = "  ",
	Constant = " ﲀ ",
	Struct = " ﳤ ",
	Event = "  ",
	Operator = "  ",
	TypeParameter = "  ",
}

vim.o.completeopt = "menu,menuone,noselect"
local cmp = require "cmp"
local luasnip = require "luasnip"
cmp.setup {
	snippet = {expand = function(args) luasnip.lsp_expand(args.body) end},
	mapping = {
		['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {"i", "c"}),
		['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {"i", "c"}),
		['<Esc>'] = cmp.mapping({i = cmp.mapping.abort(), c = cmp.mapping.close()}),
		['<CR>'] = cmp.mapping({i = cmp.mapping.confirm({select = false})}),
		['<C-Space>'] = cmp.mapping(function(_)
			local entries = cmp.get_entries()
			if #entries > 0 and (#entries == 1 or entries[1].exact) then
				cmp.confirm({select = true})
			elseif cmp.visible() then
				cmp.select_next_item()
			else
				cmp.complete()
			end
		end),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.confirm({select = true})
			elseif luasnip.jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, {"i", "c", "s"}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			elseif cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, {"i", "c", "s"}),
		["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i", "c"}),
		["<Down>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i", "c"}),
	},
	formatting = {
		format = function(entry, item)
			local name = entry.source.name
			item.kind = name == "nvim_lua" and "  " or name == "calc" and "  " or name == "buffer" and
					            "  " or name == "latex_symbols" and "  " or name == "emoji" and "" or
					            kind_icons[item.kind]
			item.menu = ""
			return item
		end,
	},
	completion = {keyword_length = 2},
	window = {documentation = {border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}}},
	experimental = {ghost_text = true},
	sources = cmp.config.sources {
		{name = "nvim_lsp"},
		{name = "luasnip"},
		{name = "path"},
		{name = "calc"},
		{name = "emoji"},
		-- {name = "latex_symbols"},
		-- {name = "buffer"}
	},
}

cmp.setup.filetype('lua', {
	sources = cmp.config.sources {
		{name = "nvim_lua"},
		{name = "nvim_lsp"},
		{name = "luasnip"},
		{name = "calc"},
		{name = "path"},
		{name = "emoji"},
	},
})

cmp.setup.filetype('markdown', {
	sources = cmp.config.sources {
		{name = "path"},
		{name = "calc"},
		{name = "latex_symbols"},
		{name = "emoji"},
		{name = "buffer"},
	},
})

cmp.setup.cmdline(":", {sources = {{name = "cmdline"}, {name = "path"}, {name = "buffer"}}})
cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})

_G.capabilities = require'cmp_nvim_lsp'.default_capabilities(vim.lsp.protocol
		                                                             .make_client_capabilities())
vim.cmd("hi link CompeDocumentation Pmenu")
