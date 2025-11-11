local M = {
	'pmizio/typescript-tools.nvim',
	ft = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact', 'vue' },
	dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lspconfig', 'mxsdev/nvim-dap-vscode-js' },
}
function M.config()
	local ml = require 'mylsp'
	ml.setup 'eslint'
	require('typescript-tools').setup(ml.setup(nil, 'tsserver'))
end
return M
