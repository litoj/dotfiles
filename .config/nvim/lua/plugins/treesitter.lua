local M = {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	dependencies = {
		{
			'nvim-treesitter/nvim-treesitter-context',
			opts = {
				on_attach = function(buf)
					if ({ markdown = 1 })[vim.bo[buf].ft] then return false end
					return true
				end,
			},
		},
	},
	lazy = false,
}
function M.config()
	---@diagnostic disable-next-line: missing-fields
	require('nvim-treesitter.configs').setup {
		ensure_installed = {
			'bash',
			'bibtex',
			'c',
			'cpp',
			'css',
			'c_sharp',
			'gitcommit',
			'html',
			'java',
			'javascript',
			'json',
			'latex',
			'lua',
			-- 'luadoc',
			'markdown',
			'markdown_inline',
			-- 'printf'
			'python',
			-- 'regex',
			'rust',
			'tsx',
			'typescript',
			'vim',
			'yaml',
		},
		ignore_install = { 'haskell' },
		highlight = { enable = true, additional_vim_regex_highlighting = false },
		autopairs = { enable = true },
		indent = { enable = true, disable = { 'yaml' } },
	}
end
return M
