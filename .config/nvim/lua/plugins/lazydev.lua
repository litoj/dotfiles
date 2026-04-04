return {
	'folke/lazydev.nvim',
	dependencies = {
		'nvim-lspconfig',
		{ 'jbyuki/one-small-step-for-vimkind', version = 'main' }, -- for lua debugging from separate instance
	},
	ft = 'lua',
	config = function()
		require('lazydev').setup {
			enabled = function(root_dir) return root_dir:match 'vim' end,
			library = {
				{ path = '${3rd}/luv/library', words = { 'vim%.uv' } },
			},
		}
		require('mylsp').setup 'lua_ls' -- must be set up after lazydev
	end,
}
