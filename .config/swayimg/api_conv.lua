local _s = swayimg -- local reference; avoids repeated global lookups

local function run_hooks(hooks, ...)
	if not hooks then return end
	local i = #hooks
	while i > 0 do
		if hooks[i](...) then table.remove(hooks, i) end
		i = i - 1
	end
end

---@param name? string|false
---@param overrides? table
local function proxy(name, overrides)
	overrides = overrides or {}
	local api = name and _s[name] or (name == false and {} or _s)
	name = name and 'swi.' .. name or 'swi'

	---@type api_conv
	local base = { _overrides = overrides, _on_set = {} }
	for k, o in pairs(overrides) do
		local is_override = type(o) == 'table'
		if is_override then
			for i, _ in pairs(o) do
				if i ~= 'get' and i ~= 'set' then
					is_override = false
					break
				end
			end
		end

		if not is_override then
			base[k] = o
			overrides[k] = nil
		end
	end

	-- register a listener to change of variable `idx`
	function base.on_set(idx, cb)
		local t = base._on_set[idx]
		if not t then
			t = {}
			base._on_set[idx] = {}
		end
		t[#t + 1] = cb
	end

	return setmetatable(base, {
		__index = function(self, idx)
			local v = overrides[idx]
			if v and v.get then return v.get(self) end

			v = api[idx] -- get fn
			if v ~= nil then return v end -- directly forward access to the old api

			v = api['get_' .. idx] -- get variable
			if v then return v() end -- idiomatic getter

			v = rawget(self, '_' .. idx)
			if v ~= nil then return v end -- read local copy of the last set value

			v = idx:match '^on_(.+)_change$'
			if v then
				return function(x) return self.on_set(v, x) end
			end
			error('tried to get: ' .. name .. '.' .. idx)
		end,

		__newindex = function(self, idx, val)
			local ov = overrides[idx]
			if type(ov) == 'table' and ov.set then
				ov.set(val)
			else
				local fn = api[(type(val) == 'boolean' and 'enable_' or 'set_') .. idx]
				if not fn then error('tried to assign: ' .. name .. '.' .. idx) end

				fn(val)
			end

			rawset(self, '_' .. idx, val) -- set in case a getter isn't available
			if self._on_set[idx] then run_hooks(self._on_set[idx], val, idx) end
		end,
	})
end

local function gen_unhookable(fn_name, api)
	local hooks = {}
	local initiated
	return function(fn)
		if not initiated then
			api[fn_name](function(...) run_hooks(hooks, ...) end)
			initiated = true
		end

		hooks[#hooks + 1] = fn
	end
end

---
--- Overider construction
---

---@param api swayimg_appmode
local function mode_overrides(api, extend)
	local maps = {}
	local ret = {
		on_image_change = gen_unhookable('on_image_change', api),
		on_signal = gen_unhookable('on_signal', api),
		map = function(b, action)
			if maps[b] then
				local mode = ({
					[_s.viewer] = 'viewer',
					[_s.gallery] = 'gallery',
					[_s.slideshow] = 'slideshow',
				})[api]
				error(string.format('%s.map("%s") already set', mode, b))
			end
			maps[b] = true

			if b:match 'Mouse' or b:match 'Scroll' then
				api.on_mouse(b, action)
			else
				api.on_key(b, action)
			end
		end,
		bind_reset = function()
			maps = {}
			api.bind_reset()
		end,
		text_tl = { set = function(x) api.set_text('topleft', x) end },
		text_tr = { set = function(x) api.set_text('topright', x) end },
		text_bl = { set = function(x) api.set_text('bottomleft', x) end },
		text_br = { set = function(x) api.set_text('bottomright', x) end },
	}
	for k, v in pairs(extend or {}) do
		ret[k] = v
	end
	return ret
end

---@param api swayimg.viewer|swayimg.slideshow
local function viewer_overrides(api)
	return mode_overrides(api, {
		scale_centered = api.set_abs_scale,
		scale = {
			set = function(x)
				if type(x) == 'string' then
					api.set_fix_scale(x)
				else
					api.set_abs_scale(x)
				end
			end,
			get = function(self) return rawget(self, '_scale') or rawget(self, '_default_scale') end,
		},
		get_abs_scale = api.get_scale,
		position = {
			set = function(x)
				if type(x) == 'string' then
					api.set_fix_position(x)
				else
					api.set_abs_position(x.x, x.y)
				end
			end,
		},
		image_background = {
			set = function(x)
				if type(x) == 'table' then
					api.set_image_chessboard(x.size, x[1], x[2])
				else
					api.set_image_background(x)
				end
			end,
		},
		preload_limit = { set = api.limit_preload },
		history_limit = { set = api.limit_history },
	})
end

---@param l swayimg.imagelist
local function imagelist_overrides(l)
	local mlist = {}

	---@type swi.imagelist.marked
	local marked = { _hooks = {} }
	local function remove(x)
		for i, v in ipairs(mlist) do
			if v == x then
				table.remove(mlist, i)
				return true
			end
		end
	end

	local last_list_size = 0
	function marked.size()
		if l.size() ~= last_list_size then
			mlist = {}
			for _, v in ipairs(l.get()) do
				if v.mark then mlist[#mlist + 1] = v.path end
			end
			last_list_size = l.size()
		end
		return #mlist
	end

	function marked.get() return mlist end
	function marked.set_current(state, silent)
		local api = _s[_s.get_mode()] ---@type swayimg.gallery
		local img = api.get_image()
		if state == 'toggle' then
			state = not img.mark
		elseif img.mark == state then
			return
		end

		if state then
			mlist[#mlist + 1] = img.path
		else
			remove(img.path)
		end

		api.mark_image(state)
		if not silent then run_hooks(marked._hooks, #mlist) end
	end
	function marked.on_change(cb) marked._hooks[#marked._hooks + 1] = cb end

	return {
		get_current = function() return _s[_s.get_mode()].get_image() end,
		marked = marked,
		remove = function(x)
			l.remove(x)
			last_list_size = l.size()
			if remove(x) then run_hooks(marked._hooks, #mlist) end
		end,
	}
end

---@type swi
_G.swi = proxy(nil, {
	on_window_resize = gen_unhookable('on_window_resize', _s),
	imagelist = proxy('imagelist', imagelist_overrides(_s.imagelist)),
	text = proxy('text', {
		enabled = {
			set = function(val)
				if val == true then
					_s.text.show()
					_s.text.set_timeout(0)
				elseif val == false then
					_s.text.hide()
				else
					_s.text.set_timeout(val)
				end
			end,
		},
		is_visible = _s.text.visible,
		line_spacing = {
			-- transform scale factor into a pixel value
			set = function(val)
				_s.text.set_spacing(math.floor((val - 1) * (rawget(swi.text, '_size') or 0)))
			end,
		},
		size = {
			set = function(val)
				_s.text.set_size(val)

				-- update line spacing
				rawset(swi.text, '_size', val)
				swi.text.line_spacing = swi.text.line_spacing
			end,
		},
	}),
	viewer = proxy('viewer', viewer_overrides(_s.viewer)),
	slideshow = proxy('slideshow', viewer_overrides(_s.slideshow)),
	gallery = proxy(
		'gallery',
		mode_overrides(_s.gallery, { cache_limit = { set = _s.gallery.limit_cache } })
	),
})
