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
			-- docmd = { debug = '/tmp/docmd.md' },
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
		'pmizio/typescript-tools.nvim',
		ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lspconfig', 'mxsdev/nvim-dap-vscode-js' },
		config = function() require('typescript-tools').setup(require('mylsp').setup(nil, 'tsserver')) end,
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

			local matchers = require('reform.link').config.matchers
			matchers[#matchers + 1] = {
				luapat = 'function ([%w_]+:[%w_/]+)',
				use = function(ref) vim.cmd.e(ref:gsub(':', '/functions/') .. '.mcfunction') end,
			}
		end,
	},
	-- { 'mpas/marp-nvim', cmd = 'MarpToggle', opts = { port = 8080 } },
}
