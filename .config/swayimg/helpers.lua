---@class helpers
local M = {}

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

function M.exec(cmd)
	-- TODO: how to make stderr appear? 2>&1 doesn't work
	cmd = cmd:gsub('([^%%])%%([^%%])', '%1' .. swi[swi.mode].get_current_image().path .. '%2')
	local p = io.popen(cmd, 'r')
	if not p then error('invalid command: ' .. cmd) end
	local out = p:read '*a'
	p:close()
	swi.text.set_status(out)
end

---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
function M.map(bind, cb, api)
	if type(cb) == 'string' then
		local cmd = cb
		cb = function() M.exec(cmd) end
	end

	for _, b in ipairs(type(bind) == 'table' and bind or { bind }) do
		b = transform_key(b)
		if b:match 'Mouse' or b:match 'Scroll' then
			api.on_mouse(b, cb)
		else
			api.on_key(b, cb)
		end
	end
end

-- viewer mode relative movement in percentages of window size
function M.step(x, y)
	local w, h = unpack(swi.get_window_size())
	local px, py = unpack(v.get_position())
	v.set_abs_position(px - math.floor(w * x / 100), py - math.floor(h * y / 100))
end

M.vgo = {
	dir = v.switch_image,
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
M.ggo = { dir = g.switch_image }
local meta = {
	__index = function(tbl, dir)
		tbl[dir] = function() tbl.dir(dir) end
		return tbl[dir]
	end,
}
setmetatable(M.vgo, meta)
setmetatable(M.ggo, meta)

local last_size = 0
local marked_count = 0
local mark_hooks = {}
function M.get_marked()
	local marked = {}
	for _, v in ipairs(l.get()) do
		if v.marked then marked[#marked + 1] = v.path end
	end
	return marked
end
function M.on_marked_count_change(fn) mark_hooks[#mark_hooks + 1] = fn end
function M.get_marked_count()
	if last_size ~= l.size() then marked_count = #M.get_marked() end
	return marked_count
end
function M.toggle_mark()
	local mark = not swi[swi.mode].get_current_image().marked
	swi[swi.mode].mark_current_image(mark)
	marked_count = marked_count + (mark and 1 or -1)

	local i = #mark_hooks
	while i > 0 do
		if mark_hooks[i]() then table.remove(mark_hooks, i) end
		i = i - 1
	end
end

return M
