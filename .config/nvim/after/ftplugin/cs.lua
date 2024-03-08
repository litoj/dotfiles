map({ 'n', 'i' }, '<A-b>', '<Cmd>w|term dotnet build -r linux-x64<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!dotnet build -r linux-x64<CR><CR>', { buffer = true })

local function getExecPath(dll)
	local dir = vim.api.nvim_buf_get_name(0)
	local label
	while not label do
		dir = dir:gsub('/[^/]+$', '')
		label = vim.fn.glob(dir .. '/*.csproj')
	end

	dir = vim.fn.glob(dir .. '/bin/Debug/net*/')
	if not dir then return end
	if exists(dir .. 'linux-x64/') then dir = dir .. 'linux-x64/' end
	label = dir .. label:match '([^/]+)%.csproj$'
	return dll and label .. '.dll' or label
end

map({ 'n', 'i' }, '<M-R>', function()
	local path = getExecPath()
	if path then vim.cmd.term(path) end
end, { buffer = true })

if vim.g.cs_loaded then return end
vim.g.cs_loaded = true
withMod('dap', function(dap)
	dap.adapters.coreclr = {
		type = 'executable',
		command = 'netcoredbg',
		args = { '--interpreter=vscode' },
	}
	dap.configurations.cs = {
		{
			name = 'Launch',
			type = 'coreclr',
			request = 'launch',
			env = 'ASPNETCORE_ENVIRONMENT=Development',
			args = {
				'/p:EnvironmentName=Development', -- this is a msbuild jk
				'--urls=http://localhost:5002',
				'--environment=Development',
			},
			program = function() return getExecPath(true) end,
		},
	}
end)

withMod('mylsp', function(ml)
	ml.setup('omnisharp', { cmd = { 'omnisharp' }, enable_import_completion = true })
	vim.cmd.LspStart 'omnisharp'
end)
