if vim.bo.bufhidden ~= '' then return end

local map = require('fthelper').once {
	-- mylsp = function(ml) ml.setup 'lua_ls' end, -- handled by lazydev.nvim

	dap = function(dap)
		dap.configurations.lua = {
			{
				type = 'nlua',
				request = 'attach',
				name = 'Attach to running Neovim instance',
			},
		}

		dap.adapters.nlua = function(callback, config)
			callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
		end
	end,
}

map('n', '<F18>', function() require('osv').launch { port = 8086, delay_frozen = 100 } end)
vim.fn.matchadd('Label', [[--\zs #\+ ]])
