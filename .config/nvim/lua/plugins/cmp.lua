---@diagnostic disable: missing-fields
local M = {
	'litoj/nvim-cmp',
	dependencies = {
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
		'rafamadriz/friendly-snippets',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-cmdline',
		'hrsh7th/cmp-path',
		'litoj/cmp-calc',
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

		Copilot = '  ',
	}

	vim.o.completeopt = 'menu,menuone,noselect'
	local cmp = require 'cmp'
	local ls = require 'luasnip'

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

	local kinds = require('cmp.types.lsp').CompletionItemKind
	local kindPriority = {}
	for i, k in ipairs {
		kinds.Text, -- includes calc, latex_symbols and other sources
		kinds.Value,
		kinds.Color,
		kinds.File,
		kinds.Folder,

		kinds.EnumMember,
		kinds.Variable,
		kinds.Property,
		kinds.Field,

		kinds.Snippet,

		kinds.Method,
		kinds.Function,
		kinds.Constructor,

		kinds.Constant,
		kinds.Module,

		kinds.TypeParameter,
		kinds.Enum,
		kinds.Class,
		kinds.Struct,
		kinds.Interface,
		kinds.Event,

		kinds.Keyword,
		kinds.Operator,
		kinds.Reference,
	} do
		kindPriority[k] = i
	end

	local src = {} ---@type table<string,cmp.SourceConfig>
	src.calc = { name = 'calc', group_index = 1 }
	src.font = { name = 'nerdfont', group_index = 1, trigger_characters = {}, keyword_length = 3 }
	src.latex =
		{ name = 'latex_symbols', group_index = 1, trigger_characters = {}, keyword_length = 3 }
	src.path = { name = 'path', group_index = 1 }
	src.lsp = {
		name = 'nvim_lsp',
		group_index = 2,
		priority = 2,
		entry_filter = function(e) return e:get_kind() ~= kinds.Text end,
	}
	src.snip = { name = 'luasnip', group_index = 2, keyword_length = 3 }
	src.buf = { name = 'buffer', group_index = 3 }

	-- TODO: how to convert this blink.cmp filter into cmp-nvim?

	--[[ transform_items = function(ctx, items)
		local filtered = {}
		local match = ctx.get_keyword():gsub('(.)', '.-%1'):sub(3):lower()
		local base_len = #ctx.get_keyword()
		for _, item in ipairs(items) do
			local match = item.label:lower():match(match)
			if match and #match < base_len + 8 then filtered[#filtered + 1] = item end
		end
		return filtered
	end ]]

	local source_icons = {
		calc = ' 󰃬 ',
		buffer = '  ',
		latex = '  ',
		nerdfont = '  ',
	}

	cmp.setup {
		formatting = {
			fields = { 'kind', 'abbr' },
			format = function(entry, item)
				item.kind = source_icons[entry.source.name] or kind_icons[item.kind]
				item.abbr = item.abbr:sub(item.abbr:sub(1, 1) == ' ' and 2 or 1, 30)
				return item
			end,
		},
		snippet = { expand = function(args) ls.lsp_expand(args.body) end },
		mapping = {
			['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
			['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
			['<Esc>'] = function()
				if not cmp.abort() then
					vim.api.nvim_feedkeys(vim.fn.mode == 'c' and '\03' or '\027', 'n', false)
				end
			end,
			['<CR>'] = cmp.mapping {
				i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
			},
			['<C-Space>'] = function()
				if not cmp.visible() then return cmp.complete() end
				if #cmp.get_entries() == 1 then return cmp.confirm { select = true } end
				cmp.select_next_item()
			end,
			['<Tab>'] = cmp.mapping(function(fallback)
				if
					cmp.visible()
					and (
						vim.api.nvim_get_mode().mode == 'c'
						or vim.api.nvim_get_current_line():sub(1, vim.api.nvim_win_get_cursor(0)[2]):match '%S'
					)
				then
					return cmp.confirm { select = true }
				end
				if ls.locally_jumpable(1) then return ls.jump(1) end
				if vim.fn.mode() == 'c' then return end

				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
				if line:sub(col, col):match '%w' then return fallback() end

				-- vim.schedule(function() -- >> with cursor tracking TODO: use manipulator
				local indent = line:match '^%s'
				if not indent then
					indent = vim.bo.et and string.rep(' ', vim.bo.sw) or '\t'
				elseif indent == ' ' then
					indent = string.rep(' ', vim.bo.sw)
				end
				line = indent .. line
				vim.api.nvim_buf_set_lines(0, row - 1, row, true, { line })
				vim.api.nvim_win_set_cursor(0, { row, col + #indent })
				-- end)
			end, { 'i', 'c', 's' }),
			['<S-Tab>'] = function()
				if ls.locally_jumpable(-1) then return ls.jump(-1) end
				if cmp.visible() or vim.fn.mode == 'c' then return cmp.select_prev_item() end
				-- vim.cmd '<'
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
				local indent = line:match '^%s'
				if not indent then return end

				indent = indent == ' ' and vim.bo.sw or 1
				line = line:sub(indent + 1)
				vim.api.nvim_buf_set_lines(0, row - 1, row, true, { line })
				vim.api.nvim_win_set_cursor(0, { row, col > indent and col - indent or 0 })
			end,
			['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
			['<A-k>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
			['<Down>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
			['<A-j>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
			['<C-2>'] = select(2),
			['<C-3>'] = select(3),
			['<C-4>'] = select(4),
			['<C-5>'] = select(5),
		},
		completion = {
			keyword_length = 2,
			autocomplete = { 'TextChanged' },
		},
		performance = { max_view_entries = 300, throttle = 1, fetching_timeout = 1 },
		window = {
			completion = { col_offset = -3, side_padding = 0 },
			documentation = { border = 'rounded', winhighlight = '' },
		},
		-- experimental = { ghost_text = { hl_group = 'DiagnosticVirtualTextHint' } },
		sorting = {
			comparators = {
				cmp.config.compare.offset,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				function(e1, e2)
					e1, e2 = kindPriority[e1:get_kind()], kindPriority[e2:get_kind()]
					if e1 == e2 then return end
					return e1 < e2
				end,
				cmp.config.compare.sort_text,
				cmp.config.compare.length,
			},
		},
		sources = { src.calc, src.path, src.lsp, src.snip },
	}

	cmp.setup.filetype({ 'markdown', 'text' }, {
		sources = {
			src.calc,
			vim.tbl_extend('force', src.path, { trigger_characters = {}, keyword_length = 100 }),
			src.snip,
			src.font,
			src.latex,
		},
	})
	cmp.setup.filetype({ 'lua' }, {
		sources = {
			src.calc,
			src.path,
			vim.tbl_extend('force', src.lsp, {
				---@type fun(e:cmp.Entry, ctx:cmp.Context):boolean
				entry_filter = function(e)
					local k = e:get_kind()
					return k ~= kinds.Text and k ~= kinds.Keyword
				end,
			}),
			src.font,
			{ name = 'lazydev', group_index = 0 },
		},
	})

	cmp.setup.cmdline(':', {
		sources = { { name = 'cmdline', group_index = 0 }, src.path, src.latex, src.buf },
		completion = { autocomplete = { 'TextChanged' } },
	})
	cmp.setup.cmdline('/', { sources = { src.latex, src.buf } })
end

-- convert into a list of plugins used for completion and code generation
M = {
	M,
	{ 'kdheepak/cmp-latex-symbols', ft = { 'markdown', 'text' }, dependencies = 'nvim-cmp' },
	{ 'chrisgrieser/cmp-nerdfont', ft = { 'markdown', 'text', 'lua' }, dependencies = 'nvim-cmp' },
}

return M
