return {
	{ 'samjwill/nvim-unception', lazy = false },
	{ 'LunarVim/bigfile.nvim', lazy = false },
	{
		'neovim/nvim-lspconfig',
		dependencies = 'hrsh7th/cmp-nvim-lsp',
		event = 'VeryLazy',
		config = function() require 'mylsp' end,
	},
	{
		'JosefLitos/reform.nvim',
		event = 'LspAttach',
		build = 'make',
		opts = {
			open_link = { { { '', 'i' }, '<C-LeftMouse>' }, { 'n', 'gL' } },
			docmd = { debug = '/tmp/docmd.lua' },
		},
	},
	{
		'danymat/neogen',
		keys = '<M-y>',
		config = function()
			local ng = require 'neogen'
			ng.setup { snippet_engine = 'luasnip' }
			map({ 'n', 'i' }, '<M-y>', ng.generate)
		end,
	},
	{ 'JosefLitos/i3config.vim', ft = 'swayconfig' },
	{
		'habamax/vim-asciidoctor',
		ft = 'asciidoctor',
		config = function() vim.g.asciidoctor_fenced_languages = { 'sh', 'javascript', 'python' } end,
	},
	{
		'folke/neodev.nvim',
		dependencies = 'nvim-lspconfig',
		ft = 'lua',
		config = function()
			require('neodev').setup { setup_jsonls = false }
			require 'mylsp' 'lua_ls'
		end,
	},
	{
		'NvChad/nvim-colorizer.lua',
		cmd = 'ColorizerToggle',
		opts = { user_default_options = { RRGGBBAA = true } },
	},
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
	-- { 'chentoast/marks.nvim', event = 'BufEnter', opts = {} },
	-- { 'Darazaki/indent-o-matic', dependencies = 'nvim-treesitter', event = 'BufEnter', opts = {} },
	--[[ {
		"rubixninja314/vim-mcfunction",
		ft = "mcfunction",
		config = function()
			vim.g.mcversion = "latest"
			vim.o.synmaxcol = 255
			vim.g.mcEnableBuiltinIDs = false
			vim.g.mcEnableBuiltinJSON = true
			vim.api.nvim_create_autocmd("FileType", {pattern = "mcfunction", command = "setlocal tw=0"})
		end,
	}, ]]
}
