return {
	{
		'neovim/nvim-lspconfig',
		dependencies = 'hrsh7th/cmp-nvim-lsp',
		event = 'VeryLazy',
		config = function() require 'mylsp' end,
	},
	{
		'JosefLitos/reform.nvim',
		event = 'VeryLazy',
		build = 'make',
		opts = { open_link = { { '', '<C-LeftMouse>' }, { 'n', 'gL' } } },
	},
	{
		'danymat/neogen',
		event = 'InsertEnter',
		config = function()
			local ng = require 'neogen'
			ng.setup { snippet_engine = 'luasnip' }
			map({ 'n', 'i' }, '<M-y>', ng.generate)
		end,
	},
	{ 'JosefLitos/i3config.vim', ft = 'swayconfig' },
	{ 'samjwill/nvim-unception', lazy = false },
	{ 'LunarVim/bigfile.nvim', lazy = false },
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
			require('lspconfig').lua_ls.launch()
		end,
	},
	{
		'NvChad/nvim-colorizer.lua',
		ft = { 'markdown', 'lua', 'css', 'swayconfig', 'config', 'dosini', 'toml' },
		opts = {
			filetypes = { 'markdown', 'lua', 'css', 'swayconfig', 'config', 'dosini', 'toml' },
			user_default_options = { RGB = false, names = false },
		},
	},
	{
		'j-hui/fidget.nvim',
		event = 'LspAttach',
		tag = 'legacy',
		opts = {
			text = { spinner = 'dots' },
			timer = { spinner_rate = 225, fidget_decay = 500, task_decay = 500 },
			window = { blend = 0 },
		},
	},
	{ 'chentoast/marks.nvim', event = 'BufEnter', opts = {} },
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
