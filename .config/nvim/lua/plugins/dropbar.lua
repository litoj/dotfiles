return { -- code breadcrumbs
	'Bekaboo/dropbar.nvim',
	event = 'VeryLazy',
	opts = {
		general = { update_events = { buf = {}, global = { 'VimResized' } } },
		icons = {
			kinds = {
				use_devicons = true,
				symbols = {
					Package = '󰅩 ',
					Module = '󰅩 ',
					Namespace = '󰅩 ',
					Scope = '󰅩 ',

					Object = '󰅩 ',
					Array = '󰅪 ',
					List = '󰅪 ',

					Interface = ' ',
					Class = ' ',
					Struct = ' ',
					Enum = ' ',
					Type = ' ',
					TypeParameter = ' ',

					Field = ' ',
					Property = ' ',
					Variable = ' ',

					Call = '󰃷 ',
					Constructor = ' ',
					Function = '󰊕 ',
					Method = ' ',

					CaseStatement = '󰨚 ',
					IfStatement = '󰨚 ',
					SwitchStatement = '󰨚 ',

					Folder = ' ',
				},
			},
			ui = {
				bar = { separator = ' ', extends = '…' },
				menu = { separator = ' ', indicator = ' ' },
			},
		},
		bar = {
			sources = function(buf, _)
				local sources = require 'dropbar.sources'
				return {
					sources.path,
					require('dropbar.utils').source.fallback(
						vim.bo[buf].ft == 'markdown' and { sources.markdown }
							or { sources.treesitter, sources.lsp }
					),
				}
			end,
		},
		sources = {
			treesitter = {
				valid_types = {
					'package',
					'module',
					'namespace',
					'scope',

					'object',
					'array',
					'list',

					'interface',
					'class',
					'struct',
					'enum',

					'field',
					'property',
					'variable',

					'call',
					'constructor',
					'function',
					'method',

					'if_statement',
					'switch_statement',

					'for_statement',
					'do_statement',
					'repeat',
					'while_statement',

					'text',
				},
			},
		},
	},
}
