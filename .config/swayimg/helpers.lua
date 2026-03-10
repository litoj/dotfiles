---@class helpers
local M = {}

function M.current() return swi[swi.get_mode()].current_image() end
function M.exec(cmd)
	-- TODO: how to make stderr appear? 2>&1 doesn't work
	cmd = cmd:gsub('([^\\])%%', '%1' .. M.current().path)
	local p = io.popen(cmd, 'r')
	local out = p:read '*a'
	p:close()
	swi.set_status(out)
end

local key_map = {
	BS = 'BackSpace',
	Del = 'Delete',
	Esc = 'Escape',
	CR = 'Enter',
	[','] = 'comma',
	['.'] = 'period',
	['`'] = 'grave',
	['~'] = 'asciitilde',
	[' '] = 'space',
	['+'] = 'plus',
	['-'] = 'minus',
	['='] = 'equal',
}
for _, v in ipairs { 'Middle', 'Left', 'Right' } do
	key_map[v:sub(1, 1) .. 'MB'] = 'Mouse' .. v
end
for _, v in ipairs { 'Left', 'Right', 'Up', 'Down' } do
	key_map['SM' .. v:sub(1, 1)] = 'Scroll' .. v
end
local function transform_key(bind)
	if bind:match '^<.+>$' then bind = bind:sub(2, -2) end
	bind = bind:gsub('[AM][+-]', 'Alt+', 1):gsub('S[+-]', 'Shift+', 1):gsub('C[+-]', 'Ctrl+', 1)

	if bind:match 'Shift%+Tab$' then
		bind = bind:gsub('Shift%+Tab$', 'Shift+ISO_Left_Tab')
	else
		local key = bind:match '[^+-]*.$'
		bind = bind:sub(1, -#key - 1) .. (key_map[key] or key)
	end
	return bind
end

---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
---@param mode 'gallery'|'viewer'|'slideshow'
function M.map(bind, cb, mode)
	if type(cb) == 'string' then
		local cmd = cb
		cb = function() M.exec(cmd) end
	end

	if type(bind) == 'table' then
		for _, b in ipairs(bind) do
			M.map(b, cb, mode)
		end
		return
	end

	bind = transform_key(bind)

	if bind:match 'Mouse' or bind:match 'Scroll' then
		swi[mode].on_mouse(bind, cb)
	else
		swi[mode].on_key(bind, cb)
	end
end

-- viewer mode relative movement in percentages of window size
function M.step(x, y)
	local w, h = unpack(swi.get_window_size())
	local px, py = unpack(v.get_position())
	v.set_abs_position(px - math.floor(w * x / 100), py - math.floor(h * y / 100))
end

M.vgo = {
	dir = v.open,
	left = function(p)
		return function() M.step(-p, 0) end
	end,
	right = function(p)
		return function() M.step(p, 0) end
	end,
	up = function(p)
		return function() M.step(0, -p) end
	end,
	down = function(p)
		return function() M.step(0, p) end
	end,
}
M.ggo = { dir = g.select }
local meta = {
	__index = function(tbl, dir)
		tbl[dir] = function() tbl.dir(dir) end
		return tbl[dir]
	end,
}
setmetatable(M.vgo, meta)
setmetatable(M.ggo, meta)

return M
