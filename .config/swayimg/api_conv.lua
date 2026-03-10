--------------------------------------------------------------------------------
-- api_conv.lua
-- Conversion layer: wraps the legacy `swayimg` global into the redesigned API
-- described in api.lua, exposed as the global `swi`.
--
-- Naming convention translations (old -> new):
--   swayimg.foo.get_bar()           -> swi.foo.bar         (property read)
--   swayimg.foo.set_bar(v)          -> swi.foo.bar = v     (property write)
--   swayimg.foo.enable_bar(v)       -> swi.foo.bar = v     (boolean property write)
--   swayimg.foo.open(dir)           -> swi.foo.select(dir) (viewer/slideshow rename)
--   swayimg.foo.current_image()     -> swi.foo.get_current_image()
--   swayimg.foo.on_change_image(fn) -> swi.foo.on_image_change(fn)
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
local function proxy(api, overrides)
	overrides = overrides or {}
	return setmetatable({}, {
		__index = function(_, idx)
			local ov = overrides[idx]
			if ov ~= nil then
				if type(ov) == 'function' then return ov end
				if ov.get then return ov.get() end
				return nil
			end
			local v = api[idx]
			if type(v) == 'function' then return v end
			local getter = api['get_' .. idx]
			if getter then return getter() end
		end,
		__newindex = function(_, idx, val)
			local ov = overrides[idx]
			if ov ~= nil and type(ov) == 'table' and ov.set then
				ov.set(val)
				return
			end
			if type(val) == 'boolean' then
				local fn = api['enable_' .. idx]
				if fn then
					fn(val)
					return
				end
			end
			local fn = api['set_' .. idx]
			if fn then fn(val) end
		end,
	})
end

-------------------------------------------------------------------------------
-- viewer_overrides(v) -> table
--
-- Both viewer and slideshow share the same set of renamed methods.
-- Accepts the concrete sub-API table so each proxy closes over the right fns.
-------------------------------------------------------------------------------
local function viewer_overrides(v)
	return {
		select = v.open, -- open(dir) -> select(dir)
		get_current_image = v.current_image, -- current_image() -> get_current_image()
		on_image_change = v.on_change_image, -- on_change_image(fn) -> on_image_change(fn)
	}
end

-------------------------------------------------------------------------------
-- swi: root of the redesigned API
--
-- Sub-tables are eagerly constructed proxies.
-- Top-level properties fall through to the __index / __newindex metamethods
-- below, which mirror the same proxy convention applied to the root `swayimg`
-- table.
-------------------------------------------------------------------------------
_G.swi = setmetatable({

	---------------------------------------------------------------------------
	-- Image list
	-- All properties map via the generic set_/enable_ pattern:
	--   .order, .reverse, .recursive, .adjacent
	---------------------------------------------------------------------------
	imagelist = proxy(_s.imagelist),

	---------------------------------------------------------------------------
	-- Text overlay layer
	-- .visible is special: boolean -> show()/hide(), number -> set_timer(s)
	---------------------------------------------------------------------------
	text = proxy(_s.text, {
		visible = {
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
	}),

	---------------------------------------------------------------------------
	-- Viewer mode
	---------------------------------------------------------------------------
	viewer = proxy(_s.viewer, viewer_overrides(_s.viewer)),

	---------------------------------------------------------------------------
	-- Slideshow mode (same overrides as viewer; .timeout is handled
	-- automatically via the get_timeout() / set_timeout() auto-mapping)
	---------------------------------------------------------------------------
	slideshow = proxy(_s.slideshow, viewer_overrides(_s.slideshow)),

	---------------------------------------------------------------------------
	-- Gallery mode
	---------------------------------------------------------------------------
	gallery = proxy(_s.gallery, {
		get_current_image = _s.gallery.current_image,
		on_image_change = _s.gallery.on_change_image,
	}),
}, {
	---------------------------------------------------------------------------
	-- Top-level property reads.
	-- Direct functions (exit, set_mode, get_mode, ...) are returned as-is.
	-- Properties with a getter (window_size, mouse_pos) are auto-called.
	---------------------------------------------------------------------------
	__index = function(_, idx)
		local v = _s[idx]
		if v then return v end
		local getter = _s['get_' .. idx]
		if getter then return getter() end
		error('invalid request of field: ' .. idx)
	end,

	---------------------------------------------------------------------------
	-- Top-level property writes.
	-- Special cases that don't fit the generic set_/enable_ pattern:
	--   window_size: setter takes two positional args; unpack from tuple
	--   fullscreen:  old API only has toggle_fullscreen(), no set variant
	---------------------------------------------------------------------------
	__newindex = function(_, idx, val)
		if idx == 'window_size' then
			_s.set_window_size(val[1], val[2])
			return
		end
		if idx == 'fullscreen' then -- TODO: we need a proper setter and a getter
			_s.toggle_fullscreen()
			return
		end
		if type(val) == 'boolean' then
			local fn = _s['enable_' .. idx]
			if fn then
				fn(val)
				return
			end
		end
		local fn = _s['set_' .. idx]
		if fn then fn(val) end
	end,
})
