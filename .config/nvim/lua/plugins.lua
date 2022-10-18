DATA_PATH = vim.fn.stdpath 'data'
local install_path = DATA_PATH .. "/site/pack/packer/start/"
local install_packer

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	install_packer = vim.fn.system {
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path .. "packer.nvim",
	}
	vim.cmd "packadd packer.nvim"
end

require'packer'.startup(function(use)
	-- Packer can manage itself as an optional plugin
	use {
		"wbthomason/packer.nvim",
		config = function()
			nmap("n", "<Leader>u", "<Cmd>PackerUpdate<CR>")
			nmap("n", "<Leader>p", "<Cmd>PackerSync<CR>")
		end,
	}

	use "JosefLitos/nerdcontrast.nvim"

	use {"neovim/nvim-lspconfig", config = function() require "lsp" end}
	use {
		"williamboman/nvim-lsp-installer",
		config = function() require "lsp.emmet-ls" end,
		after = "nvim-lspconfig",
	}
	use {"tami5/lspsaga.nvim", config = function() require'lspsaga'.init_lsp_saga() end}

	-- Telescope
	use "nvim-lua/popup.nvim"
	use "nvim-lua/plenary.nvim"
	use {"nvim-telescope/telescope.nvim", config = function() require "telescope-s" end}

	-- Debugging
	-- add("mfussenegger", "nvim-dap")

	-- Autocomplete
	use {
		"hrsh7th/nvim-cmp",
		config = function() require "cmp-s" end,
		requires = {
			-- "dsznajder/vscode-es7-javascript-react-snippets",
			"rafamadriz/friendly-snippets",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-calc",
			"hrsh7th/cmp-emoji",
			"hrsh7th/cmp-buffer",
			"kdheepak/cmp-latex-symbols",
		},
	}
	use {"windwp/nvim-autopairs", after = "nvim-cmp", config = function() require "autopairs-s" end}
	use {
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function() require "treesitter-s" end,
		requires = {"windwp/nvim-ts-autotag"},
	}

	use {
		"rubixninja314/vim-mcfunction",
		ft = "mcfunction",
		config = function()
			vim.g.mcversion = "latest"
			vim.g.mcEnableBuiltinIDs = false
			vim.g.mcEnableBuiltinJSON = false
		end,
	}

	-- use {
	-- 	"lervag/vimtex",
	-- 	config = function()
	-- 		vim.g.vimtex_indent_enabled = 0
	-- 		vim.g.vimtex_indent_bib_enabled = 0
	-- 		vim.g.vimtex_fold_enabled = 1
	-- 		vim.g.vimtex_fold_types = {markers = {enabled = 0}, sections = {parse_levels = 1}}
	-- 	end,
	-- }

	-- Formatting
	use {"jose-elias-alvarez/null-ls.nvim", config = function() require "lsp.null-ls" end}
	use {
		"pierreglaser/folding-nvim",
		config = function()
			nmap("n", "-", "za")
			nmap("i", "<C-S-_>", "<Esc>zcja")
			nmap("n", "=", "zi")
			nmap("n", "_", "zM")
			nmap("n", "+", "zR")
		end,
	}
	use {"numToStr/Comment.nvim", config = function() require "comment-s" end}

	-- Explorer
	use {"kevinhwang91/rnvimr", config = function() require "rnvimr-s" end}
	use {"kyazdani42/nvim-tree.lua", config = function() require "nvimtree-s" end}

	-- Color
	use {
		"rrethy/vim-hexokinase",
		run = "make hexokinase",
		config = function() require "hexokinase-s" end,
	}
	use "JosefLitos/vim-i3config"

	-- use {'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end}

	-- Nvim ui
	use "kyazdani42/nvim-web-devicons"
	use {"mhinz/vim-startify", config = function() require "startify-s" end}
	use {"NTBBloodbath/galaxyline.nvim", config = function() require "galaxyline-s" end}
	use {
		"romgrk/barbar.nvim",
		config = function()
			vim.cmd "packadd barbar.nvim"
			require "barbar-s"
		end,
	}
	use {
		"lukas-reineke/indent-blankline.nvim",
		config = function() require'indent_blankline'.setup {char_highlight_list = {"Grey"}} end,
	}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if install_packer then require'packer'.sync() end
end)
