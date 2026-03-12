--------------------------------------------------------------------------------
-- api_conv.lua
-- Conversion layer: wraps the legacy `swayimg` global into the redesigned API
-- described in api.lua, exposed as the global `swi`.
--
-- Naming convention translations (old -> new):
--   swayimg.foo.get_bar()           -> swi.foo.bar         (property read)
--   swayimg.foo.set_bar(v)          -> swi.foo.bar = v     (property write)
--   swayimg.foo.enable_bar(v)       -> swi.foo.bar = v     (boolean property write)
--   swayimg.foo.on_change_image(fn) -> swi.foo.on_image_change(fn)
--   swayimg.foo.on_key/on_mouse     -> swi.foo.map(bind,fn_or_shcmd)
--   swayimg.foo.current_image()     -> swi.imagelist.get_current() (+ separate for v/s mode)
--------------------------------------------------------------------------------

local _s = swayimg -- local reference; avoids repeated global lookups

-------------------------------------------------------------------------------
-- proxy(api, overrides) -> table
--
-- Creates a transparent read/write proxy table over `api`, translating
-- idiomatic field access into the corresponding legacy function calls.
--
-- READ  t.foo
--   1. overrides.foo (function)    -> returned as a callable alias
--   2. overrides.foo.get()         -> custom getter result
--   3. api.foo      (function)     -> returned as-is
--   4. api.get_foo()               -> auto-getter result
--   5. self._foo                   -> cached value of the last set (for where getters dont exist)
--
-- WRITE t.foo = val
--   1. overrides.foo.set(val)      -> custom setter
--   2. api.enable_foo(val)         -> when val is boolean
--   3. api.set_foo(val)            -> generic setter
--
-- Override entries:
--   function            -> callable alias exposed on read (renamed method)
--   { get?, set? }      -> explicit getter / setter closures
-------------------------------------------------------------------------------
---@param name string
local function proxy(name, overrides)
	local api = _s[name]
	overrides = overrides or {}
	return setmetatable({}, {
		__index = function(self, idx)
			local v = overrides[idx]
			if v then
				if type(v) == 'function' then return v end
				if v.get then return v.get() end
			end

			v = api[idx]
			if v ~= nil then return v end -- directly forward access to the old api

			v = api['get_' .. idx]
			if v then return v() end -- idiomatic getter

			v = rawget(self, '_' .. idx)
			if v ~= nil then return v end -- read local copy of the last set value

			error('invalid request of field: swi.' .. name .. '.' .. idx)
		end,

		__newindex = function(self, idx, val)
			local ov = overrides[idx]
			if type(ov) == 'table' and ov.set then
				ov.set(val)
			else
				local fn = api[(type(val) == 'boolean' and 'enable_' or 'set_') .. idx]
				if not fn then error('invalid attempt to set field: swi.' .. name .. '.' .. idx) end

				fn(val)
			end

			rawset(self, '_' .. idx, val) -- set in case a getter isn't available
		end,
	})
end

local function gen_unhookable(fn_name, api)
	local hooks = {}
	local initiated
	return function(fn)
		if not initiated then
			local function master_hook()
				local i = #hooks
				while i > 0 do
					if hooks[i]() then table.remove(hooks, i) end
					i = i - 1
				end
			end

			if not api then
				swi.gallery[fn_name](master_hook)
				swi.viewer[fn_name](master_hook)
				swi.slideshow[fn_name](master_hook)
			else
				api[fn_name](master_hook)
			end
			initiated = true
		end
		hooks[#hooks + 1] = fn
	end
end
local function mode_overrides(api)
	return {
		on_image_change = gen_unhookable('on_change_image', api),
		on_signal = gen_unhookable('on_signal', api),

		get_current_image = function()
			local img = api.current_image()
			img.marked = img.mark
			return img
		end,
		mark_current_image = _s.imagelist.mark,
		switch_image = api.select,
	}
end
local function viewer_overrides(api)
	local o = mode_overrides(api)
	o.switch_image = api.open
	o.scale_centered = api.set_abs_scale
	o.image_scale = {
		set = function(x)
			if type(x) == 'string' then
				api.set_fix_scale(x)
			else
				api.set_abs_scale(x)
			end
		end,
		get = api.get_scale,
	}
	o.image_pos = {
		set = function(x)
			if type(x) == 'string' then
				api.set_fix_position(x)
			else
				api.set_abs_position(x)
			end
		end,
		get = api.get_position,
	}
	return o
end

---@type swi
_G.swi = setmetatable({
	on_window_resize = gen_unhookable 'on_window_resize',

	imagelist = proxy('imagelist', {
		get = function()
			local list = _s.imagelist.get()
			for _, img in ipairs(list) do
				img.marked = img.mark
			end
			return list
		end,
	}),

	text = proxy('text', {
		allowed = {
			set = function(val)
				if type(val) == 'number' then
					_s.text.set_timer(val)
				elseif val then
					_s.text.show()
				else
					_s.text.hide()
				end
			end,
		},
		-- set_status lives at the swayimg root in the legacy API, not under swayimg.text
		set_status = _s.set_status,
	}),

	viewer = proxy('viewer', viewer_overrides(_s.viewer)),
	slideshow = proxy('slideshow', viewer_overrides(_s.slideshow)),
	gallery = proxy('gallery', mode_overrides(_s.gallery)),
}, {
	__index = function(self, idx)
		local v = _s[idx]
		if v then return v end -- directly forward access to the old api

		v = _s['get_' .. idx]
		if v ~= nil then return v() end -- idiomatic getter

		v = rawget(self, '_' .. idx)
		if v ~= nil then return v end -- read local copy of the last set value

		error('invalid request of field: swi.' .. idx)
	end,

	__newindex = function(self, idx, val)
		local fn = _s[(type(val) == 'boolean' and 'enable_' or 'set_') .. idx]
		if not fn then error('invalid attempt to set field: swi.' .. idx) end

		fn(val)
		rawset(self, '_' .. idx, val) -- set in case a getter isn't available
	end,
})
