-- for sumneko_lua to work, you need to have a .git dir in parent
-- directory of your current file, otherwise it will keep recursively
-- searching for the .git directory -> keep the empty .git dir here
require "plugins"
require "autocommands"
require "settings"
require "keymappings"
local time = tonumber(os.date("%H"))
local month = tonumber(os.date("%m"))
if month > 6 then month = 12 - month end
month = math.floor(month / 2)
vim.g.WhiteTheme = time > 8 - month and time < 17 + month
vim.cmd "colorscheme nerdcontrast"
