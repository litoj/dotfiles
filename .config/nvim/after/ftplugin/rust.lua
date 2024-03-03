map({ 'n', 'i' }, '<A-r>', '<Cmd>w|cd %:h|!cargo b -r<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-b>', '<Cmd>w|cd %:h|!cargo b<CR>', { buffer = true })

withMod('dap', function(dap)
	dap.configurations.rust = {
		{
			name = 'Launch',
			type = 'codelldb',
			request = 'launch',
			cwd = '${workspaceFolder}',
			program = function()
				os.execute 'cargo b'
				return vim.api.nvim_buf_get_name(0):gsub('(/%w+)/src/.*$', '%1/target/debug%1')
			end,
		},
	}
end)

withMod('mylsp', function(ml) ml.setup('rust_analyzer', {}) end)
