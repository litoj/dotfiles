map({ 'n', 'i' }, '<A-b>', '<Cmd>w|term dotnet build -r linux-x64<CR>', { buffer = true })
map({ 'n', 'i' }, '<A-r>', '<Cmd>w|!dotnet build -r linux-x64<CR><CR>', { buffer = true })
