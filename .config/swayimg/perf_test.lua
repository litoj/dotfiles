local l = swayimg.imagelist
local g = swayimg.gallery
local e = swi and swi.eventloop
if not e then
	local oninit = function() end
	local onres = function() end
	---@diagnostic disable-next-line: missing-fields
	e = {
		subscribe = function(hook)
			if hook.event == 'Signal' then
				g.on_signal(hook.pattern or hook.match, hook.callback)
			elseif hook.event == 'SwiEnter' then
				oninit = hook.callback
			else
				onres = hook.callback
			end
		end,
	}
	swayimg.on_window_resize(function()
		if oninit then
			oninit()
			---@diagnostic disable-next-line: cast-local-type
			oninit = nil
		else
			onres()
		end
	end)
end
local swi = swi or { gallery = { border_size = 5, padding_size = 5 } }

local M = {}

-- automatically updated values of gallery dimensions
local line, page

swayimg.imagelist.enable_adjacent(false)
swayimg.imagelist.set_order 'none'
swayimg.imagelist.enable_recursive(true)
swayimg.enable_overlay(false)
g.set_aspect 'keep'
g.set_thumb_size(200)
g.limit_cache(0)
swayimg.set_mode 'gallery'
swayimg.text.set_timeout(0)
swayimg.text.show()

function M.init()
	-- default delays to use (cycles on every use)
	M.delays = { 0.1, 0.5, 3, 0.2, 0.01, 0.7, 0.2, 0.1, 0.1, 0.2, 1, 0.3, 0.2, 0.1, 0.5, 0.2, 0.9 }

	-- how often to do a random movement after executing the action
	M.dist_freq = 13
	M.distractions = { 'right', 'left', 'down', 'up', 'pgup', 'pgdown' }

	local del, add, mov = M.del, M.add, M.mov
---@class OperationConfig
---@field [1] fun() API function to call
---@field [2] number start_pct 0-100,
---@field [3] number finish_pct 0-100, inclusive
---@field [4] number step iteration step, 1 = all, 4 = every 4th, -1 = backwards

	-- stylua: ignore start
	---@type OperationConfig[]
	M.ops = {
		{ del,   0, 100,  1 }, {mov,  0, 100,  999}, {mov, 100,  0, -999},
		{ add,   0, 100,  1 }, {mov,  0,   2,    1}, {mov,  10,100, page},
		{ del,  99,   1, -1 }, {add,100,   0,   -2}, {mov, 100,  0,-page},
		                       {mov,  0,  80,5*line},{mov,  80,100,-line},
	                      	 {mov,  0, 100, page}, {mov, 100, 98,   -1},
		{ add, 100,   0, -1 }, {mov,  10,  0,-line},
		{ del,   0, 100,  7 }, {mov,  0,  20,2*line},{mov,  20,  0,-page},
		{ add,   0, 100,  2 }, {mov,  0, 100,  999}, {mov,  50, 20,5*-page},
		{ del,   0,  70,  3 }, {mov,  0,   8,    5},
		{ add,   1, 100,  2 }, {mov,  0,  80,3*page}, {mov, 100, 90,-line},
		{ del,  25,  75,  1 }, {mov,  0,  30,   -5}, {mov, 100,  0, -999},
		{ add,   0, 100,  1 }, {mov,  0,  40, page}, {mov,  40, 60,3*-line},
		{ del,   1, 100,  7 }, {mov,  0, 100,5*line},{mov, 100,  0,3*-page},
		{ del,   2, 99,  13 }, {mov,  0,  80, line}, {mov,  39,  0,-page},
		{ del,   3, 70,  11 }, {mov,  0,   5,    1}, {mov,   5,  0,   -1},
		                       {mov,  0,  30,2*page},{mov,  30, 15,-line},
		                       {mov, 15,  80, page}, {mov,  80,  0, -999},
		{ del,   0, 100,  3 }, {mov,  0, 100, line}, {mov, 100,  0,-page},
	}
	-- stylua: ignore end

	--- code bench implementation

	M.start = os.clock()
	M.time = os.time()
	M.paths = {}
	for _, i in ipairs(l.get()) do
		M.paths[i.index] = i.path
	end
	M.op = M.next_op()
	e.subscribe { event = 'Signal', match = 'USR1', callback = M.next_iter }
	M.schedule_signal(0.5)
end

local function log(msg)
	-- if type(msg) == 'string' then print(msg) end
	swayimg.text.set_status(tostring(msg))
end

local get_pos = function() return g.get_image().index end

local rep = 0
local delay_i = 1
local sig_i = 0
function M.schedule_signal(requested)
	if (not requested or requested < 0.01) and rep < 200 then
		rep = rep + 1
		M.next_iter()
	else
		rep = 0
		os.execute(
			string.format('sleep %f && pkill -USR1 -x swayimg &', requested or M.delays[delay_i])
		)
		if not requested then delay_i = delay_i % #M.delays + 1 end

		if sig_i % M.dist_freq == 0 then
			local dir = M.distractions[math.floor(sig_i / M.dist_freq) % #M.distractions + 1]
			g.switch_image(dir)
			log { distraction = dir }
		end
	end
	sig_i = sig_i + 1
end

---@param func fun(path:string):(number|true?)
---@param from_pct number
---@param to_pct number
---@param step number
---@return fun():(number|true?) iterator
local function iterator(func, from_pct, to_pct, step)
	if step > 0 and from_pct > to_pct or (step < 0 and to_pct > from_pct) then
		from_pct, to_pct = to_pct, from_pct
	end
	local total = #M.paths
	local s = math.max(math.floor(total * from_pct / 100), 1)
	local e = math.max(math.floor(total * to_pct / 100), 1)

	return coroutine.wrap(function()
		for i = s, e, step do
			coroutine.yield(func(M.paths[i]))
		end
	end)
end

function M.add(...)
	if true then
		local paths = {}
		for p in iterator(function(p) return p end, ...) do
			paths[#paths + 1] = p
		end
		return function() l.add(paths) end
	end
	return iterator(function(p) return l.add(p) or 0 end, ...)
end
function M.del(...)
	if true then
		local paths = {}
		for p in iterator(function(p) return p end, ...) do
			paths[#paths + 1] = p
		end
		if #paths == l.size() then paths[#paths] = nil end
		return function() l.remove(paths) end
	end
	return iterator(function(p)
		-- print("Size: "..l.size())
		if l.size() == 1 then return end
		l.remove(p)
		return #p % 100 ~= 0 and 0 or true
	end, ...)
end

local move_cfg
local function recalc_moves()
	local win = swayimg.get_window_size()
	local thumb = g.get_thumb_size() + swi.gallery.border_size * 2 + swi.gallery.padding_size * 2
	line = math.floor(win.width / thumb)
	page = math.floor(win.height / thumb) * line

	move_cfg = {
		{ 999, 'first', 'last' },
		{ page, 'pgup', 'pgdown' },
		{ line, 'up', 'down' },
		{ 1, 'left', 'right' },
	}
end
e.subscribe { event = 'WinResized', callback = recalc_moves }
local function get_cfg(acc, step)
	local abs = math.abs(step)
	local cfg
	for _, v in ipairs(move_cfg) do
		if v[1] <= abs then
			cfg = v
			break
		end
	end

	local dir = step > 0 and cfg[3] or cfg[2]
	local reps = math.floor(abs / cfg[1])
	acc[#acc + 1] = { reps = reps, dir = dir }
	local todo = abs % cfg[1]
	if todo >= 1 then get_cfg(acc, todo * (step > 0 and 1 or -1)) end
	return acc
end
function M.mov(f, t, s)
	if true then
		return function() end
	end
	local cfg = get_cfg({}, s)
	return iterator(function()
		for _, level_cfg in ipairs(cfg) do
			-- log(level_cfg)
			for _ = level_cfg.reps, 1, -1 do
				g.switch_image(level_cfg.dir)
			end
		end
		return get_pos() ~= (s > 0 and l.size() or 1) and 0.01 or nil
	end, f, t, s)
end

local op_names = {}
for k, v in pairs(M) do
	op_names[v] = k
end

local op_pos = 0
function M.next_op()
	op_pos = op_pos + 1
	local cfg = M.ops[op_pos]
	local op = cfg[1](select(2, unpack(cfg)))
	log(string.format('%s[%d]: imgcnt: %d ', op_names[cfg[1]], op_pos, l.size()))
	return op
end

function M.next_iter()
	local delay = M.op()
	if delay == nil then
		if op_pos < #M.ops then
			M.op = M.next_op()
		else
			print(
				('Took: cpu=%d actual=%d'):format(
					math.floor(os.clock() - M.start + 0.5),
					(os.time() - M.time)
				)
			)
			swayimg.exit(0)
			return true
		end
	end
	M.schedule_signal(delay ~= true and delay or nil)
end

e.subscribe {
	event = 'SwiEnter',
	callback = function()
		recalc_moves()
		M.init()
	end,
}
