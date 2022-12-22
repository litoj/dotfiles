local M = {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
	dependencies = {
		-- 'nvim-treesitter/nvim-treesitter-textobjects',
		'JoosepAlviste/nvim-ts-context-commentstring',
	},
	event = 'VeryLazy',
}
function M.config()
	require('nvim-treesitter.configs').setup {
		ensure_installed = {
			'bash',
			'bibtex',
			'c',
			'cpp',
			'css',
			'gitcommit',
			'html',
			'java',
			'javascript',
			'json',
			'latex',
			'lua',
			'markdown',
			'markdown_inline',
			'python',
			'regex',
			'rust',
			'tsx',
			'typescript',
			'vim',
			'yaml',
		},
		ignore_install = { 'haskell' },
		highlight = { enable = true, additional_vim_regex_highlighting = false },
		-- autotag = {enable = true},
		autopairs = { enable = true },
		indent = { enable = true, disable = { 'yaml' } },
		--[[ textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					af = '@function.outer',
					['if'] = '@function.inner',
					ac = '@class.outer',
					ic = '@class.inner',
					ai = '@conditional.outer',
					ii = '@conditional.inner',
					al = '@loop.outer',
					il = '@loop.innter',
				},
			},
			move = { enable = true, set_jumps = true },
		}, ]]
	}
	--[[ local function jmpTo(direction, position)
		local c = vim.fn.getchar()
		local section = c < 96 and '.inner' or '.outer'
		if c < 96 then c = c + 32 end
		local kind = ({
			f = '@function',
			c = '@class',
			i = '@conditional',
			l = '@loop',
			a = '@assignment',
			n = '@*',
		})[string.char(c)]
		if not kind then return end
		require('nvim-treesitter.textobjects.move')['goto_' .. direction .. position](
			kind .. section,
			'textobjects'
		)
	end
	map('n', 'gn', function() jmpTo('next', '_start') end)
	map('n', 'gN', function() jmpTo('next', '_end') end)
	map('n', 'gp', function() jmpTo('previous', '_start') end)
	map('n', 'gP', function() jmpTo('previous', '_end') end) ]]
end
return M
