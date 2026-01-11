if vim.bo.bufhidden ~= '' then return end

local map, modmap = require 'fthelper'.once {
	mylsp = function(ml) ml.setup 'pyright' end,

	dap = function(_) require('dap-python').setup 'python3' end,
}

modmap {
	['dap-python'] = function(dp) map('n', '<leader>dm', dp.test_method) end,
}
