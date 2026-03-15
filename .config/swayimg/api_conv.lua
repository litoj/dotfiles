local _s = swayimg -- local reference; avoids repeated global lookups

---@param name? string
---@param overrides? table
local function proxy(name, overrides)
	overrides = overrides or {}
	local api = name and _s[name] or _s
	name = name and 'swi.' .. name or 'swi'

	local base = {}
	for k, v in pairs(overrides) do
		if type(v) == 'function' or (not rawget(v, 'get') and not rawget(v, 'set')) then
			base[k] = v
			overrides[k] = nil
		end
	end

	return setmetatable(base, {
		__index = function(self, idx)
			local v = overrides[idx]
			if v and v.get then return v.get() end

			v = api[idx] -- get fn
			if v ~= nil then return v end -- directly forward access to the old api

			v = api['get_' .. idx] -- get variable
			if v then return v() end -- idiomatic getter

			v = rawget(self, '_' .. idx)
			if v ~= nil then return v end -- read local copy of the last set value

			error('invalid request of field: ' .. name .. '.' .. idx)
		end,

		__newindex = function(self, idx, val)
			local ov = overrides[idx]
			if type(ov) == 'table' and ov.set then
				ov.set(val)
			else
				local fn = api[(type(val) == 'boolean' and 'enable_' or 'set_') .. idx]
				if not fn then error('invalid attempt to set field: ' .. name .. '.' .. idx) end

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

			api[fn_name](master_hook)
			initiated = true
		end

		hooks[#hooks + 1] = fn
	end
end

local function mode_overrides(api)
	return {
		on_image_change = gen_unhookable('on_image_change', api),
		on_signal = gen_unhookable('on_signal', api),
		map = function(b, action)
			if b:match 'Mouse' or b:match 'Scroll' then
				api.on_mouse(b, action)
			else
				api.on_key(b, action)
			end
		end,
		text_tl = { set = function(x) api.set_text('topleft', x) end },
		text_tr = { set = function(x) api.set_text('topright', x) end },
		text_bl = { set = function(x) api.set_text('bottomleft', x) end },
		text_br = { set = function(x) api.set_text('bottomright', x) end },
	}
end

local function viewer_overrides(api)
	local o = mode_overrides(api)
	o.scale_centered = api.set_abs_scale
	o.scale = {
		set = function(x)
			if type(x) == 'string' then
				api.set_fix_scale(x)
			else
				api.set_abs_scale(x)
			end
		end,
		get = api.get_scale,
	}
	o.position = {
		set = function(x)
			if type(x) == 'string' then
				api.set_fix_position(x)
			else
				api.set_abs_position(x.x, x.y)
			end
		end,
		get = api.get_position,
	}
	o.image_background = {
		set = function(x)
			if type(x) == 'table' then
				api.set_image_chessboard(x.size, x[1], x[2])
			else
				api.set_image_background(x)
			end
		end,
	}
	o.preload_limit = { set = api.limit_preload }
	o.history_limit = { set = api.limit_history }
	return o
end

local function gallery_overrides(api)
	local o = mode_overrides(api)
	o.cache_limit = { set = api.limit_cache }
	return o
end

---@type swi
_G.swi = proxy(nil, {
	on_window_resize = gen_unhookable('on_window_resize', _s),

	imagelist = proxy 'imagelist',
	text = proxy('text', {
		enabled = {
			set = function(val)
				if val then
					_s.text.show()
				else
					_s.text.hide()
				end
			end,
		},
		is_visible = _s.text.visible,
	}),

	viewer = proxy('viewer', viewer_overrides(_s.viewer)),
	slideshow = proxy('slideshow', viewer_overrides(_s.slideshow)),
	gallery = proxy('gallery', gallery_overrides(_s.gallery)),
})
