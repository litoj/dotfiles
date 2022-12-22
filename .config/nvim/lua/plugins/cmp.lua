local M = {
	'hrsh7th/nvim-cmp',
	event = { 'InsertEnter', 'CmdlineEnter' },
	dependencies = {
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
		'rafamadriz/friendly-snippets',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-cmdline',
		'hrsh7th/cmp-path',
		'JosefLitos/cmp-calc',
		'hrsh7th/cmp-buffer',
		-- "kdheepak/cmp-latex-symbols",
		'hrsh7th/cmp-nvim-lsp-signature-help',
		'chrisgrieser/cmp-nerdfont',
	},
}
function M.config()
	require('luasnip/loaders/from_vscode').lazy_load()
	local kind_icons = {
		Method = '  ',
		Function = ' 󰊕 ',
		Constructor = '  ',

		Module = ' 󰅩 ',
		Interface = '  ',
		Class = '  ',
		Struct = '  ',
		Enum = '  ',

		Field = '  ',
		Property = '  ',
		Variable = '  ',
		TypeParameter = '  ',
		Constant = ' 󰏿 ',
		EnumMember = '  ',

		Keyword = '  ',
		Operator = '  ',
		Reference = ' 󰌹 ',
		Event = '  ',
		Snippet = '  ',

		Text = ' 󰉾 ',
		Unit = ' µ ',
		Value = ' = ',
		Color = '  ',
		File = ' 󰈔 ',
		Folder = '  ',
	}

	vim.o.completeopt = 'menu,menuone,noselect'
	local cmp = require 'cmp'
	local luasnip = require 'luasnip'
	cmp.setup {
		snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
		mapping = {
			['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
			['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
			['<Esc>'] = cmp.mapping { i = cmp.mapping.abort() },
			['<S-Esc>'] = cmp.mapping { c = cmp.mapping.abort() },
			['<CR>'] = cmp.mapping {
				i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
			},
			['<C-Space>'] = cmp.mapping(function(_)
				local entries = cmp.get_entries()
				if #entries > 0 and (#entries == 1 or entries[1].exact) then
					cmp.confirm { select = true }
				elseif cmp.visible() then
					if cmp.get_active_entry() == nil then cmp.select_next_item() end
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end),
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.confirm { select = true }
				elseif luasnip.expand_or_locally_jumpable(1) then
					luasnip.expand_or_jump(1)
				else
					fallback()
				end
			end, { 'i', 'c', 's' }),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				elseif cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { 'i', 'c', 's' }),
			['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
			['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
		},
		formatting = {
			fields = { 'kind', 'abbr' },
			format = function(entry, item)
				item.kind = ({
					calc = ' 󰃬 ',
					buffer = '  ',
					latex_symbols = '  ',
					nerdfont = '  ',
				})[entry.source.name] or kind_icons[item.kind]
				item.abbr = item.abbr:sub(item.abbr:sub(1, 1) == ' ' and 2 or 1, 30)
				return item
			end,
		},
		completion = { keyword_length = 2 },
		window = {
			completion = { col_offset = -3, side_padding = 0 },
			documentation = { border = 'rounded', winhighlight = '' },
		},
		experimental = { ghost_text = { hl_group = 'DiagnosticVirtualTextHint' } },
		sources = cmp.config.sources {
			{ name = 'nvim_lsp_signature_help' },
			{ name = 'nvim_lsp', max_item_count = 50 },
			{ name = 'luasnip', max_item_count = 5 },
			{ name = 'path', max_item_count = 15 },
			{ name = 'calc' },
		},
	}

	cmp.setup.filetype({ 'markdown', 'text' }, {
		sources = cmp.config.sources {
			{ name = 'path' },
			{ name = 'calc' },
			{ name = 'luasnip', max_item_count = 5 },
			{ name = 'nerdfont', max_item_count = 50 },
			-- {name = "latex_symbols", max_item_count = 50},
			{ name = 'buffer', max_item_count = 10 },
		},
	})
	cmp.setup.filetype({ 'lua' }, {
		sources = cmp.config.sources {
			{ name = 'nvim_lsp_signature_help' },
			{ name = 'nvim_lsp', max_item_count = 50 },
			{ name = 'luasnip', max_item_count = 5 },
			{ name = 'path', max_item_count = 15 },
			{ name = 'calc' },
			{ name = 'nerdfont', max_item_count = 20 },
		},
	})

	cmp.setup.cmdline(
		':',
		{ sources = { { name = 'cmdline' }, { name = 'path' }, { name = 'buffer' } } }
	)
	cmp.setup.cmdline('/', { sources = { { name = 'buffer' } } })
end
return M
