-- for sumneko_lua to work, you need to have a .git dir in parent
-- directory of your current file, otherwise it will keep recursively
-- searching for the .git directory -> keep the empty .git dir here
require "plugins"
require "autocommands"
require "settings"
require "keymappings"
local time = tonumber(os.date("%H"))
vim.g.WhiteTheme = time > 6 and time < 20
vim.cmd "colorscheme nerdcontrast"
