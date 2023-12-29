local src = {
	calc = { name = 'calc', group_index = 1 },
	font = { name = 'nerdfont', group_index = 1, trigger_characters = {}, keyword_length = 3 },
	latex = { name = 'latex_symbols', group_index = 1, trigger_characters = {}, keyword_length = 3 },

	path = { name = 'path', group_index = 2, max_item_count = 10 },

	lsp = { name = 'nvim_lsp', group_index = 2, priority = 2, max_item_count = 10 },
	snip = { name = 'luasnip', group_index = 2, keyword_length = 3, max_item_count = 10 },

	buf = { name = 'buffer', group_index = 3, max_item_count = 20 },
}
local function on_plugged()
	local f = io.open('/sys/class/power_supply/BAT0/status', 'r')
	local plugged = f:read '*l' ~= 'Discharging'
	f:close()
	if not plugged then return end
	src.tabnine = { name = 'cmp_tabnine', group_index = 2 }
	src.copilot = { name = 'copilot', group_index = 2, trigger_characters = {} }
	return {
		'tzachar/cmp-tabnine',
		build = './install.sh',
		config = function() require('cmp_tabnine.config'):setup { max_num_results = 2 } end,
	}, { 'zbirenbaum/copilot-cmp', opts = {} }, {
		'zbirenbaum/copilot.lua',
		opts = {
			panel = { enabled = false },
			suggestion = { enabled = false },
			filetypes = { config = false, swayconfig = false, text = false },
		},
	}
end

local M = {
	'hrsh7th/nvim-cmp',
	dependencies = {
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
		'rafamadriz/friendly-snippets',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-cmdline',
		'hrsh7th/cmp-path',
		'JosefLitos/cmp-calc',
		on_plugged(),
	},
}
function M.config()
	require('luasnip.loaders.from_vscode').lazy_load()
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

		Copilot = ' 󰋎 ',
		TabNine = ' 𝟗 ',
	}

	vim.o.completeopt = 'menu,menuone,noselect'
	local cmp = require 'cmp'
	local luasnip = require 'luasnip'

	local function select(num)
		local function exec()
			-- cmp.select_next_item { count = num }
			for _ = 1, num do
				cmp.select_next_item()
			end
			cmp.confirm()
		end
		return { i = exec, c = exec }
	end

	cmp.setup {
		snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
		mapping = {
			['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
			['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
			['<Esc>'] = cmp.mapping(function()
				if not cmp.abort() then vim.api.nvim_feedkeys('\03', 'n', false) end
			end, { 'i', 'c' }),
			['<CR>'] = cmp.mapping {
				i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
			},
			['<C-Space>'] = cmp.mapping(function(_)
				if cmp.visible() then
					local entries = cmp.get_entries()
					if #entries > 0 and #entries == 1 then
						cmp.confirm { select = true }
					elseif #entries == 2 and cmp.get_active_entry then
						cmp.select_prev_item()
						cmp.confirm()
					else
						if cmp.get_active_entry() == nil then cmp.select_next_item() end
						cmp.select_next_item()
					end
				else
					cmp.complete()
				end
			end, { 'i', 'c' }),
			['<Tab>'] = cmp.mapping(function(fallback)
				if cmp.visible() then
					if
						vim.api.nvim_get_mode().mode == 'c'
						or vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2]):match '%S'
					then
						cmp.confirm { select = true }
					else
						fallback()
					end
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
			['<C-2>'] = select(2),
			['<C-ě>'] = select(2),
			['<C-3>'] = select(3),
			['<C-š>'] = select(3),
			['<C-4>'] = select(4),
			['<C-č>'] = select(4),
			['<C-5>'] = select(5),
			['<C-ř>'] = select(5),
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
		completion = {
			keyword_length = 2, --[[ autocomplete = false ]]
		},
		performance = { max_view_entries = 50, throttle = 1, fetching_timeout = 1 },
		window = {
			completion = { col_offset = -3, side_padding = 0 },
			documentation = { border = 'rounded', winhighlight = '' },
		},
		experimental = { ghost_text = { hl_group = 'DiagnosticVirtualTextHint' } },
		sorting = {
			comparators = {
				cmp.config.compare.offset,
				cmp.config.compare.score,
				-- cmp.config.compare.recently_used,
				cmp.config.compare.length,
			},
		},
		sources = { src.calc, src.path, src.lsp, src.snip, src.copilot, src.tabnine },
	}

	cmp.setup.filetype({ 'markdown', 'text' }, {
		completion = { autocomplete = { 'TextChanged' } },
		sources = { src.calc, src.path, src.snip, src.font, src.latex },
	})
	cmp.setup.filetype(
		{ 'lua' },
		{ sources = { src.calc, src.path, src.lsp, src.snip, src.font, src.copilot, src.tabnine } }
	)

	cmp.setup.cmdline(
		':',
		{ sources = { { name = 'cmdline', group_index = 0 }, src.path, src.latex, src.buf } }
	)
	cmp.setup.cmdline('/', { sources = { src.latex, src.buf } })
end
return {
	M,
	--[[ {
		'hrsh7th/cmp-buffer',
		ft = { 'markdown', 'text' },
		event = 'CmdlineEnter',
		dependencies = 'nvim-cmp',
	}, ]]
	{ 'kdheepak/cmp-latex-symbols', ft = { 'markdown', 'text' }, dependencies = 'nvim-cmp' },
	{ 'chrisgrieser/cmp-nerdfont', ft = { 'markdown', 'text', 'lua' }, dependencies = 'nvim-cmp' },
}
