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
	local overrider_fields = { get = 'function', set = 'function' }
	for k, o in pairs(overrides) do
		local is_override = type(o) == 'table' and getmetatable(o) == nil
		if is_override then
			for i, v in pairs(o) do
				if type(v) ~= overrider_fields[i] then
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
			base._on_set[idx] = t
		end
		t[#t + 1] = cb
	end

	return setmetatable(base, {
		__index = function(self, idx)
			local v = overrides[idx] or overrides['*']
			if v and v.get then return v.get(self, idx) end

			v = api[idx] -- get fn
			if v ~= nil then return v end -- directly forward access to the old api

			v = api['get_' .. idx] -- get variable
			if v then return v() end -- idiomatic getter

			v = rawget(self, '_' .. idx)
			if v ~= nil then return v end -- read local copy of the last set value

			error('tried to get: ' .. name .. '.' .. idx)
		end,

		__newindex = function(self, idx, val)
			local fn = overrides[idx] or overrides['*']
			if type(fn) == 'table' and fn.set then
				fn.set(val, self, idx)
			else
				fn = api[(type(val) == 'boolean' and 'enable_' or 'set_') .. idx]
				if not fn then error('tried to assign: ' .. name .. '.' .. idx) end

				fn(val)
			end

			rawset(self, '_' .. idx, val) -- set in case a getter isn't available
			run_hooks(self._on_set[idx], val, idx)
			run_hooks(self._on_set['*'], val, idx)
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
		text = proxy(false, { ['*'] = { set = function(x, _, idx) api.set_text(idx, x) end } }),
	}
	for k, v in pairs(extend or {}) do
		ret[k] = v
	end
	return ret
end

---@param name 'viewer'|'slideshow'
local function viewer_proxy(name)
	local api = _s[name]
	local self

	local image_zoom = nil
	api.on_image_change(function()
		rawset(self, '_scale', nil)
		if not image_zoom then return end

		---@diagnostic disable-next-line: undefined-field
		local mode = self._default_scale
		local i = api.get_image()
		local w = _s.get_window_size()

		-- Z=S*I/W -> S=Z*W/I
		if mode == 'keep_by_width' then
			api.set_abs_scale(image_zoom * w.width / i.width)
		elseif mode == 'keep_by_height' then
			api.set_abs_scale(image_zoom * w.height / i.height)
		end
	end)
	local function check_ratio(self)
		if not image_zoom then return end

		local mode = self._default_scale
		local i = api.get_image()
		local w = _s.get_window_size()
		local s = api.get_scale()

		-- image * scale = pixels displayed = window * zoom -> Z=S*I/W
		if mode == 'keep_by_width' then
			image_zoom = s * i.width / w.width
		elseif mode == 'keep_by_height' then
			image_zoom = s * i.height / w.height
		end
	end

	local overrides = {
		default_scale = {
			set = function(x, self)
				if x:sub(1, 5) == 'keep_' then
					if x ~= 'keep_by_width' and x ~= 'keep_by_height' then
						error('Invalid default scale: ' .. x)
					end
					image_zoom = 1
					rawset(self, '_default_scale', x)
					check_ratio(self)
					x = 'keep'
				else
					image_zoom = nil
				end
				api.set_default_scale(x)
			end,
		},
		scale_centered = api.set_abs_scale,
		scale = {
			set = function(x, self)
				if type(x) == 'string' then
					api.set_fix_scale(x)
				else
					api.set_abs_scale(x)
				end
				check_ratio(self) -- update relative zoom also if the current image used fixed scale to set it
			end,
			get = function(self)
				local val = rawget(self, '_scale') or rawget(self, '_default_scale')
				if type(val) == 'string' and val:sub(1, 4) == 'keep' then return api.get_scale() end
				return val
			end,
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

		step = {
			default_size = 50,
			by = function(x, y)
				local p = self.position
				self.position = { x = p.x - x, y = p.y - y }
			end,
			left = function(p) self.step.by(-(p or self.step.default_size), 0) end,
			right = function(p) self.step.by((p or self.step.default_size), 0) end,
			up = function(p) self.step.by(0, -(p or self.step.default_size)) end,
			down = function(p) self.step.by(0, (p or self.step.default_size)) end,
		},

		go = setmetatable({}, {
			__index = function(tbl, idx)
				tbl[idx] = function() api.switch_image(idx) end
				return tbl[idx]
			end,
		}),
	}

	self = proxy(name, mode_overrides(api, overrides))

	return self
end

local function gallery_proxy()
	local api = _s.gallery
	local overrides = {
		cache_limit = { set = api.limit_cache },
		go = setmetatable({}, {
			__index = function(tbl, idx)
				tbl[idx] = function() api.switch_image(idx) end
				return tbl[idx]
			end,
		}),
	}
	return proxy('gallery', mode_overrides(api, overrides))
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
	viewer = viewer_proxy 'viewer',
	slideshow = viewer_proxy 'slideshow',
	gallery = gallery_proxy(),
})
