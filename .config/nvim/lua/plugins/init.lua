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
		'litoj/reform.nvim',
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
		'folke/lazydev.nvim',
		dependencies = 'nvim-lspconfig',
		ft = 'lua',
		config = function()
			require('lazydev').setup {}
			require('mylsp').setup 'lua_ls'
		end,
	},
	{ 'tpope/vim-abolish', event = 'VeryLazy' },
	{
		'pmizio/typescript-tools.nvim',
		ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
		dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lspconfig', 'mxsdev/nvim-dap-vscode-js' },
		config = function() require('typescript-tools').setup(require('mylsp').setup(nil, 'tsserver')) end,
	},
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
	{
		'catgoose/nvim-colorizer.lua',
		cmd = 'ColorizerToggle',
		config = function()
			require('colorizer').setup {
				user_default_options = {
					names = false,
					names_custom = function()
						local palette = require('nerdcontrast').palette
						for k, v in pairs(palette) do
							if palette[k] == 'NONE' then palette[k] = nil end
						end
						return palette
					end,
					mode = 'foreground',
				},
			}
		end,
	},
}
