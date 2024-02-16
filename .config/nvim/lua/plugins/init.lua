return {
	{ 'samjwill/nvim-unception', lazy = false, priority = 99 },
	{ 'LunarVim/bigfile.nvim', lazy = false },
	{
		'neovim/nvim-lspconfig',
		dependencies = 'hrsh7th/cmp-nvim-lsp',
		event = 'VeryLazy',
		config = function() require 'mylsp' end,
	},
	{
		'JosefLitos/reform.nvim',
		event = 'VeryLazy',
		opts = {
			docmd = { debug = '/tmp/docmd.md' },
			open_link = { unknown = 'copy/print-current' },
			man = true,
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
	{
		'folke/neodev.nvim',
		dependencies = 'nvim-lspconfig',
		ft = 'lua',
		config = function()
			require('neodev').setup { setup_jsonls = false }
			require('mylsp').setup 'lua_ls'
		end,
	},
	{
		'JosefLitos/colorizer.nvim',
		cmd = 'ColorizerToggle',
		config = function()
			require('colorizer').setup {
				user_default_options = {
					names = function() return require('nerdcontrast').palette end,
					mode = 'foreground',
				},
			}
		end,
	},
	-- { 'utilyre/sentiment.nvim', event = 'VeryLazy', opts = {} },
	--[[ {
		'j-hui/fidget.nvim',
		event = 'LspAttach',
		tag = 'legacy',
		opts = {
			text = { spinner = 'dots' },
			timer = { spinner_rate = 225, fidget_decay = 500, task_decay = 500 },
			window = { blend = 0 },
		},
	}, ]]
	-- { 'Darazaki/indent-o-matic', dependencies = 'nvim-treesitter', event = 'BufEnter', opts = {} },
	{ 'JosefLitos/i3config.vim', ft = 'swayconfig' },
	{
		'habamax/vim-asciidoctor',
		ft = 'asciidoctor',
		config = function() vim.g.asciidoctor_fenced_languages = { 'sh', 'javascript', 'python' } end,
	},
	{
		'JosefLitos/vim-mcfunction',
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

			require('reform.open_link').config.handlers[6] = {
				'function ([%w_]+:[%w_/]+)',
				function(ref) vim.cmd.e(ref:gsub(':', '/functions/') .. '.mcfunction') end,
			}
		end,
	},
}
