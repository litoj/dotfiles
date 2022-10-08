local gl = require "galaxyline"
local gls = gl.section

local condition = require "galaxyline.condition"
gl.short_line_list = {"NvimTree", "dbui", "packer", "startify", "help", "rnvimr"}

local mode_color = {
	n = "Contrast",
	i = "Highlight",
	v = "Yellow",
	[""] = "Yellow",
	V = "Yellow",
	c = "LightRed",
	no = "LightContrast",
	s = "Orange",
	S = "Orange",
	[""] = "Orange",
	ic = "Yellow",
	R = "Red",
	Rv = "Red",
	cv = "Blue",
	ce = "LightBlue",
	r = "Cyan",
	rm = "LightCyan",
	["r?"] = "LightCyan",
	["!"] = "Blue",
	t = "Red",
}
gls.left[1] = {
	ViMode = {
		provider = function()
			-- auto change color according the vim mode
			vim.api.nvim_set_hl(0, "GalaxyViMode",
					{fg = colors[mode_color[vim.fn.mode()]][1], bg = colors.Bg[1]})
			return "▊"
		end,
	},
}
vim.fn.getbufvar(0, "ts")

gls.left[2] = {
	BufferIcon = {provider = "BufferIcon", highlight = {colors.LightGrey[1], colors.Bg[1]}},
}

gls.left[3] = {
	Permission = {
		provider = function() if vim.bo.readonly then return "" end end,
		separator = " ",
		separator_highlight = {"NONE", colors.Bg[1]},
		highlight = {colors.Orange[1], colors.Bg[1]},
	},
}

--[[
gls.left[4] = {
	GitBranch = {
		provider = 'GitBranch',
		condition = condition.check_git_workspace,
		icon = ' ',
		separator = ' ',
		separator_highlight = {'NONE', colors.Bg[1]},
		highlight = {colors.LightGrey[1], colors.Bg[1]},
	},
}
gls.left[5] = {
	DiffAdd = {
		provider = 'DiffAdd',
		condition = condition.hide_in_width,
		icon = ' ',
		highlight = {colors.Green[1], colors.Bg[1]},
	},
}
gls.left[6] = {
	DiffModified = {
		provider = 'DiffModified',
		condition = condition.hide_in_width,
		icon = '柳',
		highlight = {colors.Blue[1], colors.Bg[1]},
	},
}
gls.left[7] = {
	DiffRemove = {
		provider = 'DiffRemove',
		condition = condition.hide_in_width,
		icon = ' ',
		highlight = {colors.Red[1], colors.Bg[1]},
	},
}
]]

gls.right = {
	{
		WordCount = {
			provider = function()
				local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), " ")
				local _, words = content:gsub("%S+", "")
				return words .. "W"
			end,
			condition = function() return vim.bo.filetype == "text" end,
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Magenta[1], colors.Bg[1]},
		},
	},
	{
		DiagnosticError = {
			provider = "DiagnosticError",
			icon = " ",
			highlight = {colors.LightRed[1], colors.Bg[1]},
		},
	},
	{
		DiagnosticWarn = {
			provider = "DiagnosticWarn",
			icon = " ",
			highlight = {colors.LightOrange[1], colors.Bg[1]},
		},
	},
	{
		DiagnosticHint = {
			provider = "DiagnosticHint",
			icon = " ",
			highlight = {colors.LightYellow[1], colors.Bg[1]},
		},
	},
	{
		DiagnosticInfo = {
			provider = "DiagnosticInfo",
			icon = " ",
			highlight = {colors.LightOlive[1], colors.Bg[1]},
		},
	},
	{
		ShowLspClient = {
			provider = "GetLspClient",
			condition = condition.hide_in_width,
			icon = " ",
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Magenta[1], colors.Bg[1]},
		},
	},
	{
		BufferType = {
			provider = function() return vim.bo.filetype end,
			-- condition = condition.hide_in_width,
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Orange[1], colors.Bg[1]},
		},
	},
	{
		Tabstop = {
			provider = function() return vim.api.nvim_buf_get_option(0, "shiftwidth") end,
			icon = "_",
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Yellow[1], colors.Bg[1]},
		},
	},
	{
		LineInfo = {
			provider = function()
				return vim.fn.line(".") .. ":" .. vim.fn.virtcol(".") .. "/" .. vim.fn.line("$")
			end,
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Green[1], colors.Bg[1]},
		},
	},
	{
		Percent = {
			provider = function()
				local current_line = vim.fn.line(".")
				local total_line = vim.fn.line("$")
				if current_line == 1 then
					return "Top"
				elseif current_line == total_line then
					return "Bot"
				else
					return math.modf((current_line / total_line) * 100) .. "%"
				end
			end,
			separator = " ",
			separator_highlight = {"NONE", colors.Bg[1]},
			highlight = {colors.Cyan[1], colors.Bg[1]},
		},
	},
}

gls.short_line_left[1] = gls.left[1]
gls.short_line_left[2] = {BufferType = {provider = "FileTypeName", separator = " "}}
gls.short_line_left[3] = {
	SFileName = {provider = "SFileName", condition = condition.buffer_not_empty},
}
gls.short_line_left[1] = gls.left[1]
gls.short_line_left[2] = {
	BufferType = {
		provider = "FileTypeName",
		separator = " ",
		separator_highlight = {"NONE", colors.Bg[1]},
		highlight = {colors.Orange[1], colors.Bg[1]},
	},
}
gls.short_line_left[3] = {
	SFileName = {
		provider = "SFileName",
		condition = condition.buffer_not_empty,
		highlight = {colors.LightGrey[1], colors.Bg[1]},
	},
}
gls.short_line_right[1] = {
	BufferIcon = {provider = "BufferIcon", highlight = {colors.LightGrey[1], colors.Bg[1]}},
}
