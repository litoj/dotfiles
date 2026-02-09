---@diagnostic disable: missing-fields
local M = {
	'hrsh7th/nvim-cmp',
	dependencies = {
		'L3MON4D3/LuaSnip',
		'saadparwaiz1/cmp_luasnip',
		'rafamadriz/friendly-snippets',
		'hrsh7th/cmp-nvim-lsp',
		'hrsh7th/cmp-cmdline',
		'hrsh7th/cmp-path',
		'hrsh7th/cmp-calc',
	},
}

local src = {
	calc = { name = 'calc', group_index = 1 },
	font = { name = 'nerdfont', group_index = 1, trigger_characters = {}, keyword_length = 3 },
	latex = { name = 'latex_symbols', group_index = 1, trigger_characters = {}, keyword_length = 3 },
	path = { name = 'path', group_index = 1 },

	lsp = { name = 'nvim_lsp', group_index = 2, priority = 2 },
	snip = { name = 'luasnip', group_index = 2, keyword_length = 3 },

	buf = { name = 'buffer', group_index = 3 },
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

		Copilot = '  ',
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

	local kinds = require('cmp.types.lsp').CompletionItemKind
	local cmpKindPref = {}
	for i, k in ipairs {
		kinds.Text, -- includes calc, latex_symbols and other sources
		kinds.Value,
		kinds.Color,
		kinds.File,
		kinds.Folder,

		kinds.Keyword,

		kinds.Variable,
		kinds.Property,
		kinds.Field,

		kinds.Snippet,

		kinds.Method,
		kinds.Function,
		kinds.Constructor,

		kinds.EnumMember,
		kinds.Constant,
		kinds.Module,

		kinds.TypeParameter,
		kinds.Enum,
		kinds.Class,
		kinds.Struct,
		kinds.Interface,
		kinds.Event,

		kinds.Operator,
		kinds.Reference, -- FIXME: what is this type?
	} do
		cmpKindPref[k] = i
	end
	local comparators = {
		cmp.config.compare.offset,
		-- src.copilot and require('cmp_copilot.comparators').score or cmp.config.compare.score,
		cmp.config.compare.recently_used,
		function(e1, e2)
			local a, b = cmpKindPref[e1:get_kind()], cmpKindPref[e2:get_kind()]
			if a == b then return end
			return a < b
		end,
		cmp.config.compare.length,
	}

	cmp.setup {
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
					elseif #entries == 2 and cmp.get_active_entry() then
						cmp.select_prev_item()
						cmp.confirm()
					else
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
				elseif luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				elseif vim.api.nvim_get_mode().mode ~= 'c' then -- indentation changer
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
					if line:sub(col, col):match '%w' then return end
					local indent = line:match '^%s'
					if not indent then
						indent = vim.bo.et and string.rep(' ', vim.bo.sw) or '\t'
					elseif indent == ' ' then
						indent = string.rep(' ', vim.bo.sw)
					end
					line = indent .. line
					vim.api.nvim_buf_set_lines(0, row - 1, row, true, { line })
					vim.api.nvim_win_set_cursor(0, { row, col + #indent })
				end
			end, { 'i', 'c', 's' }),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				elseif cmp.visible() then
					cmp.select_prev_item()
				else
					-- vim.cmd '<'
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
					local indent = line:match '^%s'
					if not indent then return end
					indent = indent == ' ' and vim.bo.sw or 1
					line = line:sub(indent + 1)
					vim.api.nvim_buf_set_lines(0, row - 1, row, true, { line })
					vim.api.nvim_win_set_cursor(0, { row, col > indent and col - indent or 0 })
				end
			end, { 'i', 'c', 's' }),
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
			autocomplete = false,
		},
		performance = { max_view_entries = 300, throttle = 1, fetching_timeout = 1 },
		window = {
			completion = { col_offset = -3, side_padding = 0 },
			documentation = { border = 'rounded', winhighlight = '' },
		},
		-- experimental = { ghost_text = { hl_group = 'DiagnosticVirtualTextHint' } },
		sorting = { comparators = comparators },
		sources = { src.calc, src.path, src.lsp, src.snip, src.copilot },
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
			src.lsp,
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

--[[ -- add AI plugins when plugged in and on the main pc
if vim.g.features_level >= 7 then
	src.copilot = { name = 'copilot', group_index = 3, trigger_characters = {} }
	M[#M + 1] = {
		'zbirenbaum/copilot.lua',
		dependencies = { { 'litoj/cmp-copilot', opts = { update_on_keypress = true } } },
		ft = { 'python', 'vue' },
		opts = {
			panel = { enabled = false },
			suggestion = {
				enabled = true,
				keymap = {
					accept = false,
					dismiss = false,
					next = false,
					prev = false,
				},
			},
			filetypes = {
				['*'] = false,
				-- c = true,
				-- cpp = true,
				cs = true,
				javascript = true,
				javascriptreact = true,
				-- lua = true,
				python = true,
				-- sh = true,
				typescript = true,
				typescriptreact = true,
				vue = true,
			},
		},
	}
end ]]
return M
