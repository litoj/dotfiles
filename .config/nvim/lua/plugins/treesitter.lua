local langs = {
	'bash',
	'bibtex',
	-- 'c', -- builtin as a nvim depencency
	'cpp',
	'css',
	'c_sharp',
	'gitcommit',
	'html',
	'java',
	'javascript',
	'json',
	'latex',
	-- 'lua', -- builtin
	-- 'luadoc',
	-- 'markdown', -- builtin
	'markdown_inline',
	-- 'printf'
	'python',
	-- 'regex',
	'rust',
	'tsx',
	'typescript',
	-- 'vim', -- builtin
	'yaml',
}
return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		branch = 'main',
		lazy = false,
		config = function()
			local ts = require 'nvim-treesitter'
			ts.install(langs)
			vim.api.nvim_create_autocmd('BufEnter', {
				callback = function() vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end,
			})
			vim.api.nvim_create_autocmd('FileType', {
				callback = function(args) pcall(vim.treesitter.start, args.buf) end,
			})
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		event = 'VeryLazy',
		dependencies = 'nvim-treesitter',
		opts = {
			on_attach = function(buf)
				if ({ markdown = 1 })[vim.bo[buf].ft] then return false end
				return true
			end,
		},
	},
}
