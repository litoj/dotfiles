return {
	--[[ {
		'RaafatTurki/hex.nvim',
		ft = { 'hex', 'xxd' },
		config = function()
			local h = require 'hex'
			h.setup()
			require 'autocommands'('FileType', 'set ft=xxd', 'hex')
			require 'autocommands'('FileType', function()
				h.dump()
				map({ 'n', 'i' }, '<C-h>', h.toggle, { buffer = true })
			end, 'xxd')
		end,
	}, ]]
	--[[ {
		'nvzone/typr',
		dependencies = 'nvzone/volt',
		opts = {},
		cmd = { 'Typr', 'TyprStats' },
	}, ]]
	{ 'samjwill/nvim-unception', lazy = false, priority = 99 },
	{ 'LunarVim/bigfile.nvim', lazy = false },
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
			-- { 'j-hui/fidget.nvim', opts = {} },
		},
		event = 'VeryLazy',
		config = function() require 'mylsp' end,
	},
	{
		'folke/lazydev.nvim',
		dependencies = {
			'nvim-lspconfig',
			'jbyuki/one-small-step-for-vimkind', -- for lua debugging from separate instance
		},
		ft = 'lua',
		config = function()
			require('lazydev').setup()
			require('mylsp').setup 'lua_ls' -- must be set up after lazydev
		end,
	},
	{
		'litoj/reform.nvim',
		event = 'VeryLazy',
		opts = {
			docmd = { debug = '/tmp/docmd.md' },
			link = { fallback = { copy = true, print = true, branch = 'current' } },
			tbl_extras = true,
		},
	},
	{
		'danymat/neogen',
		keys = '<A-y>',
		config = function()
			local ng = require 'neogen'
			ng.setup { snippet_engine = 'luasnip' }
			map({ 'n', 'i' }, '<A-y>', ng.generate)
		end,
	},
	{ 'tpope/vim-abolish', event = 'VeryLazy' },
	{ 'litoj/i3config.vim', ft = 'swayconfig' },
	--[[ {
		'habamax/vim-asciidoctor',
		ft = 'asciidoctor',
		config = function() vim.g.asciidoctor_fenced_languages = { 'sh', 'javascript', 'python' } end,
	}, ]]
	{
		'litoj/vim-mcfunction',
		ft = 'mcfunction',
		dependencies = 'reform.nvim',
		config = function()
			vim.g.mcversion = 'latest'
			vim.g.mcEnableBuiltinIDs = false
			vim.g.mcEnableBuiltinJSON = true
			vim.api.nvim_create_autocmd(
				'FileType',
				{ pattern = 'mcfunction', command = 'setlocal tw=0 cms=#%s smc=1023' }
			)

			local matchers = require('reform.link').config.matchers
			matchers[#matchers + 1] = {
				luapat = 'function ([%w_]+:[%w_/]+)',
				use = function(ref) vim.cmd.e(ref:gsub(':', '/functions/') .. '.mcfunction') end,
			}
		end,
	},
	-- { 'mpas/marp-nvim', cmd = 'MarpToggle', opts = { port = 8080 } },
}
