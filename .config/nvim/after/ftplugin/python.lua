withMod('dap', function(dap)
	local dp = require 'dap-python'
	dp.setup 'python3'
	map('n', '<leader>dm', dp.test_method)
end, { buffer = true })
