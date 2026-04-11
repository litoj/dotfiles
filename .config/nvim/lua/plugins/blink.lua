local M = {
	'saghen/blink.cmp',
	-- optional: provides snippets for the snippet source
	dependencies = {
		'L3MON4D3/LuaSnip',
		'rafamadriz/friendly-snippets',
		'fang2hou/blink-copilot',
		{ 'saghen/blink.compat', version = '2.*', opts = {} },
		'litoj/cmp-calc',
	},
	event = 'InsertEnter',
	keys = ':',

	-- version = '1.*',
	-- or build = 'cargo build --release',
}

function M.config()
	require('luasnip.loaders.from_vscode').lazy_load() -- to load friendly-snippets

	local kinds = require('blink.cmp.types').CompletionItemKind

	local kindPriority = {}
	for i, k in ipairs {
		kinds.Unit, -- calc
		kinds.Text, -- latex_symbols and other sources
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
		kinds.Reference, -- FIXME: what is this type?
	} do
		kindPriority[k] = i
	end

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	local opts = {
		signature = { enabled = false },
	}

	opts.appearance = {
		kind_icons = {
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

			Unit = ' µ ',
			Value = ' = ',
			Color = '  ',
			File = ' 󰈔 ',
			Folder = '  ',

			Copilot = '  ',
			Text = false,
		},
	}

	opts.fuzzy = {
		-- implementation = 'prefer_rust_with_warning', -- won't get used because of custom sorter
		implementation = 'lua',
		frecency = { enabled = true },
		use_proximity = true,
		sorts = {
			'score',
			function(a, b) return kindPriority[a.kind] < kindPriority[b.kind] end,
			'sort_text', -- lsp evaluation of the scope distance
		},
	}

	local source_icons = {
		calc = ' 󰃬 ',
		buffer = '  ',
		latex = '  ',
		nerdfont = '  ',
	}

	opts.completion = {
		menu = {
			auto_show = true,
			draw = {
				padding = { 0, 0 },
				columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
				components = {
					kind_icon = {
						text = function(ctx)
							return source_icons[ctx.source_id] or ctx.kind_icon or ctx.source_id or ' 󰉾 '
						end,
					},
				},
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 0,
			draw = require('reform.docmd').blink_doc,
			window = { border = 'rounded' },
		},
		ghost_text = { enabled = false },
		keyword = { range = 'prefix' },
		list = { selection = { preselect = false, auto_insert = false } },
		accept = { auto_brackets = { enabled = false } },
	}

	local ls = require 'luasnip'
	local cmp = require 'blink.cmp'

	opts.snippets = { preset = 'luasnip' }
	opts.keymap = {
		preset = 'none',

		['<CR>'] = { 'accept', 'fallback' },
		['<C-space>'] = {
			'show',
			function(cmp)
				local e = cmp.get_items()
				if #e == 1 then
					return cmp.accept { index = 1 }
				else
					return cmp.select_next()
				end
			end,
		},
		['<Esc>'] = { 'cancel', 'fallback' },
		['<Tab>'] = {
			function(cmp)
				if ls.locally_jumpable(1) then
					return vim.schedule(function() ls.jump(1) end)
				end
				if cmp.select_and_accept() or vim.fn.mode() == 'c' then return end
				vim.schedule(function() -- >> with cursor tracking TODO: use manipulator
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
				end)
			end,
		},
		['<S-Tab>'] = {
			function(cmp)
				if ls.locally_jumpable(-1) then
					return vim.schedule(function() ls.jump(-1) end)
				end
				if cmp.insert_prev() or vim.fn.mode() == 'c' then return end
				vim.schedule(function() -- << with cursor tracking TODO: use manipulator
					local row, col = unpack(vim.api.nvim_win_get_cursor(0))
					local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
					local indent = line:match '^%s'
					if not indent then return end
					indent = indent == ' ' and vim.bo.sw or 1
					line = line:sub(indent + 1)
					vim.api.nvim_buf_set_lines(0, row - 1, row, true, { line })
					vim.api.nvim_win_set_cursor(0, { row, col > indent and col - indent or 0 })
				end)
			end,
		},

		-- or leave <A-k>/<A-j> to go up and down outside cmp?
		['<Up>'] = { 'select_prev', 'fallback' },
		['<Down>'] = { 'select_next', 'fallback' },
		['<A-k>'] = { 'select_prev', 'fallback' },
		['<A-j>'] = { 'select_next', 'fallback' },

		['<C-A-k>'] = {
			'scroll_signature_up',
			'scroll_documentation_up',
			function() return vim.api.nvim_replace_termcodes('<C-x><C-y>', true, false, true) end,
		},
		['<C-A-j>'] = {
			'scroll_signature_down',
			'scroll_documentation_down',
			function() return vim.api.nvim_replace_termcodes('<C-x><C-e>', true, false, true) end,
		},
		['<C-1>'] = { function(cmp) return cmp.accept { index = 1 } end, 'fallback_to_mappings' },
		['<C-2>'] = { function(cmp) return cmp.accept { index = 2 } end, 'fallback_to_mappings' },
		['<C-3>'] = { function(cmp) return cmp.accept { index = 3 } end, 'fallback_to_mappings' },
		['<C-4>'] = { function(cmp) return cmp.accept { index = 4 } end, 'fallback_to_mappings' },
		['<C-5>'] = { function(cmp) return cmp.accept { index = 5 } end, 'fallback_to_mappings' },
	}
	opts.cmdline = {
		keymap = {
			preset = 'inherit',

			['<Esc>'] = { 'cancel', function(e) vim.api.nvim_feedkeys('\03', 'n', false) end },
			['<CR>'] = { 'fallback' },
		},
		completion = { menu = { auto_show = true } },
	}

	local dropIds = { --[[ [kinds.Keyword] = true, ]]
		[kinds.Text] = true,
	}
	opts.sources = {
		providers = {
			lsp = {
				transform_items = function(_, items)
					if items[1] and items[1].client_name == 'lua_ls' then
						return vim.tbl_filter(function(x)
							if dropIds[x.kind] or x.kind == kinds.Keyword then return false end

							if x.kind == 3 and x.insertText and #x.label > #x.insertText then -- drop params from fn name complete
								x.label = x.insertText
							elseif x.kind == 15 and x.label:match '%(' then -- regard snippets as functions
								x.kind = 3
							end
							return true
						end, items)
					end

					return vim.tbl_filter(function(x) return not dropIds[x.kind] end, items)
				end,
			},
			path = { opts = { get_cwd = vim.uv.cwd } },
			copilot = {
				name = 'copilot',
				module = 'blink-copilot',
				score_offset = 100,
				async = true,
			},
			lazydev = {
				name = 'lazydev',
				module = 'lazydev.integrations.blink',
				score_offset = 20,
			},
			nerdfont = {
				module = 'blink-nerdfont',
				name = 'Nerd Fonts',
				score_offset = 20,
				min_keyword_length = 2,
			},

			latex = {
				name = 'latex',
				module = 'blink-cmp-latex',
				min_keyword_length = 3,
				opts = { insert_command = function() return vim.bo.ft == 'tex' end },
			},
			calc = {
				name = 'calc',
				module = 'blink.compat.source',
				score_offset = 20,
				transform_items = function(_, items)
					for _, i in ipairs(items) do
						i.kind = kinds.Unit
					end
					return items
				end,
			},
		},

		default = function()
			return vim.treesitter.get_parser() --
					and { 'lsp', 'path', 'calc', 'snippets', 'copilot' }
				or { 'path', 'calc' }
		end,
		per_filetype = {
			lua = { inherit_defaults = true, 'lazydev' },
			markdown = { inherit_defaults = true, 'nerdfont', 'latex' },
			text = { inherit_defaults = true, 'nerdfont', 'latex' },
			tex = { inherit_defaults = true, 'latex' },
		},
	}

	require('blink.cmp').setup(opts)
end

return {
	M,
	{ 'MahanRahmati/blink-nerdfont.nvim' },
	{ 'erooke/blink-cmp-latex' },
}
