local map = require 'fthelper' {
	'python',

	mylsp = function(ml) ml.setup 'pyright' end,

	dap = function(_) require('dap-python').setup 'python3' end,
}

withMod('dap-python', function(dp) map('n', '<leader>dm', dp.test_method) end)
