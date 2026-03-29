---@diagnostic disable: duplicate-doc-field
local _s = swayimg -- local reference; avoids repeated global lookups

do
	local ts = tostring
	---Debugging helper - print tables as they're defined
	local function tbl_cont(t, indent)
		local s = {}
		local has_t = false
		for k, v in pairs(t) do
			if type(v) == 'table' then
				has_t = true
				v = tbl_cont(v, indent .. '  ')
			elseif type(v) == 'function' then
				v = 'fn()'
			elseif type(v) == 'string' then
				v = ('"%s"'):format(v)
			end

			if type(k) == 'table' then k = '[]' end

			s[#s + 1] = type(k) == 'string' and ('%s=%s'):format(k, ts(v)) or ts(v)
		end
		if has_t then
			return ('{\n%s%s}'):format(indent, table.concat(s, ',\n' .. indent))
		else
			return #s == 0 and '{}' or ('{ %s }'):format(table.concat(s, ', '))
		end
	end

	---@diagnostic disable-next-line: duplicate-set-field
	function _G.tostring(x)
		if type(x) == 'table' then return tbl_cont(x, '  ') end
		return ts(x)
	end
end

local function lazy(loader)
	return setmetatable({}, {
		__index = function(self, idx)
			for k, v in pairs(loader()) do
				self[k] = v
			end
			return rawget(self, idx)
		end,
	})
end

local modes = { 'viewer', 'gallery', 'slideshow' }

---@private
---@class swi.eventloop.hook: swi.eventloop.subscribe.opts
---@field pattern table<string|integer,string>
---@field mode string[]

---@type swi.eventloop
local evloop = {
	---@type {[event_name_t]:{[appmode_t]:{[hook_id]:swi.eventloop.hook}}}
	_hooks = {},
}

do
	local function tabled(x) return type(x) == 'table' and x or { x } end
	local function rev_idx(t)
		local r = {}
		for k, v in pairs(t) do
			r[v] = k
		end
		return r
	end

	---@param cfg swi.eventloop.subscribe.opts
	---@return swi.eventloop.hook
	local function mk_hook(cfg)
		local t = {}
		for _, p in ipairs(tabled(cfg.pattern or '')) do
			if p:match '[*+?%%^$%[%]()]' then
				t[#t + 1] = p
			elseif p:sub(1, 1) == '!' then
				t[p:sub(2)] = false
			else
				t[p] = true
			end
		end
		cfg.pattern = t ---@cast cfg swi.eventloop.hook
		return cfg
	end

	local function has_match(match, ptnlist)
		local direct = ptnlist[match]
		if direct ~= nil then return direct end
		for _, p in ipairs(ptnlist) do
			if match:match(p) then return true end
		end
	end

	---@param f swi.eventloop.filter.opts
	---@param on_match fun(h:swi.eventloop.hook,idx:hook_id,m:appmode_t,ev:event_name_t)
	local function apply_filtered(f, on_match)
		local modes = tabled(f.mode or modes)
		for _, ev in pairs(tabled(f.event or rev_idx(evloop._hooks))) do
			local ev_hooks = evloop._hooks[ev]
			if ev_hooks then
				for _, m in pairs(modes) do
					local m_hooks = ev_hooks[m]
					if m_hooks then
						for i, hook in pairs(m_hooks) do
							local ok = not f.match or has_match(f.match, hook.pattern)
							if f.id and ok then ok = f.id == i end
							if f.group and ok then ok = f.group == hook.group end
							if ok then on_match(hook, i, m, ev) end
						end
					end
				end
			end
		end
	end

	function evloop.unsubscribe(f)
		apply_filtered(f, function(_, id, m, ev)
			local ev_hooks = evloop._hooks[ev]
			local m_hooks = ev_hooks[m]
			local m_idx = next(m_hooks)
			if m_idx == id and not next(m_hooks, m_idx) then
				local ev_idx = next(ev_hooks)
				if ev_idx == m and not next(ev_hooks, ev_idx) then
					evloop._hooks[ev] = nil
				else
					ev_hooks[m] = nil
				end
			else
				m_hooks[id] = nil
			end
		end)
	end

	function evloop.get_subscribed(f)
		local t = {}
		apply_filtered(f or {}, function(h, id) t[id] = h end)
		return t
	end

	function evloop.trigger(state)
		---@cast state swi.eventloop.filter.opts
		state.mode = state.mode or _s.get_mode()
		apply_filtered(state, function(hook)
			local ok, ret = xpcall(hook.callback, debug.traceback, state)
			if not ok then ---@diagnostic disable-next-line: param-type-mismatch
				swayimg.text.set_status(string.gsub(ret, '\t', '  '))
			elseif ret then
				evloop.unsubscribe { id = hook }
			end
		end)
	end

	function evloop.subscribe(hook) -- TODO: generalize ptn matching to matching and registering mode
		if not hook.callback then error('missing callback in: ' .. tostring(hook)) end
		hook = mk_hook(hook)
		hook.mode = tabled(hook.mode or modes)
		for _, e in ipairs(tabled(hook.event or error('missing event in: ' .. tostring(hook)))) do
			local ev_hooks = evloop._hooks[e]
			if not ev_hooks then
				ev_hooks = {}
				evloop._hooks[e] = ev_hooks
			end

			for _, m in ipairs(hook.mode) do
				local m_hooks = ev_hooks[m]
				if not m_hooks then
					m_hooks = {}
					ev_hooks[m] = m_hooks
				end

				m_hooks[hook] = hook
				evloop.trigger { event = 'NewHook', mode = m, match = e, data = hook }
			end
		end

		return hook
	end

	_s.on_initialized(function()
		evloop.trigger { event = 'SwiEnter' }
		if evloop._hooks.SwiEnter then
			evloop._hooks.SwiEnter = nil

			-- easteregg
			local p = io.popen 'date +%d%m' or {}
			local o = p:read '*a'
			p:close()
			if o == '1003\n' then print [[Naughty, naughty! Didn't clean those hookers today...]] end
		end
	end)
end

---
--- Overider construction
---

---@generic O
---@param name? string
---@param overrides? `O`
---@return O
local function proxy(name, overrides)
	overrides = overrides or {}
	local api = name and _s[name] or (name and {} or _s)
	name = name and 'swi.' .. name or 'swi'

	---@type api_conv
	local base = { _overrides = overrides }
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
			evloop.trigger { event = 'OptionSet', match = ('%s.%s'):format(name, idx), data = val }
		end,
	})
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
local function transform_key(bind) -- to be able to map keys like in vim
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

---@param api swayimg_appmode|swayimg.gallery
---@param name string
local function mode_overrides(api, name, extend)
	evloop.subscribe {
		event = 'NewHook',
		mode = name,
		pattern = 'ImgChange',
		callback = function()
			api.on_image_change(
				function() evloop.trigger { event = 'ImgChange', mode = name, data = lazy(api.get_image) } end
			)
			return true
		end,
	}
	-- Emitted rarely, so it is better to register it straight away
	for _, sig in ipairs { 'USR1', 'USR2' } do
		api.on_signal(sig, function() evloop.trigger { event = 'Signal', match = sig } end)
	end

	local mappings = {}
	local ret = {
		map = function(b, action, desc)
			if type(action) == 'string' then
				local cmd = action
				action = function() swi.exec(cmd) end
			end

			local i = debug.getinfo(action, 'S')
			for _, b in ipairs(type(b) == 'table' and b or { b }) do
				b = transform_key(b)

				if mappings[b] then error(string.format('%s.map("%s") already set', name, b)) end
				mappings[b] =
					{ at = ('%s: %d'):format(i.short_src, i.linedefined), fn = action, desc = desc }

				if b:match 'Mouse' or b:match 'Scroll' then
					api.on_mouse(b, action)
				else
					api.on_key(b, action)
				end
			end
		end,
		get_mappings = function() return mappings end,
		unmap = function(b)
			b = transform_key(b)
			mappings[b] = nil
			local action = function() end

			if b:match 'Mouse' or b:match 'Scroll' then
				api.on_mouse(b, action)
			else
				api.on_key(b, action)
			end
		end,
		bind_reset = function()
			mappings = {}
			api.bind_reset()
		end,
		text = proxy(
			name .. '.text',
			{ ['*'] = { set = function(x, _, idx) api.set_text(idx, x) end } }
		),
	}
	for k, v in pairs(extend or {}) do
		ret[k] = v
	end
	return ret
end

---@param name 'viewer'|'slideshow'
local function viewer_proxy(name)
	local api = _s[name] ---@type swayimg.viewer
	local self

	---@alias lastimg {w:integer,h:integer,x:integer,y:integer}?
	local last
	---@type {[block_position_t]:string[]} text layer items with metadata to get replaced
	local update_text = {}
	api.on_image_change(function()
		rawset(self, '_scale', nil)
		---@type swayimg.image
		local img = last or next(update_text) and api.get_image()

		if last then
			---@diagnostic disable-next-line: undefined-field
			local mode = self._default_scale:sub(9)

			local f
			if mode == 'width' then
				f = last.w / img.width
			elseif mode == 'height' then
				f = last.h / img.height
			elseif mode == 'size' then
				f = (last.w + last.h) / (img.width + img.height)
			end
			api.set_abs_scale(api.get_scale() * f, 0, 0)
			api.set_abs_position(last.x, last.y)
		end

		if next(update_text) then
			local m = img.meta
			local f = swi.text.format_exif
			for k, text_cfg in pairs(update_text) do
				local replaced = {}
				for i, str in ipairs(text_cfg) do
					local var, path = str:match '({([A-Z][A-Za-z0-9.]+)})'
					while path do
						path = f(m, path) -- format the value
						if not path then break end
						str = str:gsub(var, path)

						var, path = str:match '({([A-Z][A-Za-z0-9.].+)})'
					end

					if not var then replaced[#replaced + 1] = str end
				end
				api.set_text(k, replaced)
			end
		end
	end)

	evloop.subscribe {
		event = 'OptionSet',
		pattern = name .. '.text.*',
		callback = function(state)
			local k = state.match:match '[^.]+$'
			for _, v in ipairs(state.data) do
				if v:find '{[A-Z]' then
					update_text[k] = state.data
					return
				end
			end
			update_text[k] = nil
		end,
	}

	local overrides = {
		default_scale = {
			set = function(x)
				if x:sub(1, 8) == 'keep_by_' then
					if not ({ width = 1, height = 1, size = 1 })[x:sub(9)] then
						error('Invalid default scale: ' .. x)
					end
					x = 'keep'
					last = { s = 0, x = 0, y = 0 }
					evloop.subscribe {
						event = 'ImgChangePre',
						group = '_cust_default_scale',
						callback = function(state)
							local i = state.data
							last = api.get_position() ---@type lastimg
							last.w = i.width
							last.h = i.height
						end,
					}
				else
					evloop.unsubscribe { group = '_cust_default_scale' }
					last = nil
				end
				api.set_default_scale(x)
			end,
		},
		scale_centered = function(s, x, y)
			api.set_abs_scale(s, x, y)
			rawset(self, '_scale', s)
		end,
		scale = {
			set = function(x)
				if type(x) == 'string' then
					api.set_fix_scale(x)
				else
					api.set_abs_scale(x)
				end
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
				tbl[idx] = function()
					evloop.trigger { event = 'ImgChangePre', data = lazy(api.get_image) }
					api.switch_image(idx)
				end
				return tbl[idx]
			end,
		}),
	}

	self = proxy(name, mode_overrides(api, name, overrides))

	return self
end

local function gallery_proxy()
	local name = 'gallery'
	local api = _s[name]

	local overrides = {
		cache_limit = { set = api.limit_cache },
		go = setmetatable({}, {
			__index = function(tbl, idx)
				tbl[idx] = function() api.switch_image(idx) end
				return tbl[idx]
			end,
		}),
	}
	return proxy(name, mode_overrides(api, name, overrides))
end

local function imagelist_proxy()
	local api = _s.imagelist
	local mlist = {}
	local msize = 0

	---@type swi.imagelist.marked
	local marked = {}
	local last_lsize = 0
	local function set_mark(x, enabled, silent)
		if msize ~= marked.size() then
		elseif enabled == not mlist[x] then
			if enabled then
				mlist[x] = 1
				msize = msize + 1
			else
				mlist[x] = nil
				msize = msize - 1
			end
		else
			return
		end

		if not silent then
			evloop.trigger { event = 'OptionSet', match = 'swi.imagelist.marked.size', data = msize }
		end
	end
	function marked.size()
		local lsize = api.size()
		if lsize ~= last_lsize then
			mlist = {}
			for _, v in ipairs(api.get()) do
				if v.mark then
					mlist[v.path] = 1
					msize = msize + 1
				end
			end
			last_lsize = lsize
		end
		return msize
	end

	function marked.get()
		local t = {}
		for p, _ in pairs(mlist) do
			t[#t + 1] = p
		end
		return t
	end
	function marked.set_current(enabled, silent)
		local api = _s[_s.get_mode()] ---@type swayimg.gallery
		local img = api.get_image()
		if enabled == 'toggle' then enabled = not img.mark end
		api.mark_image(enabled)
		set_mark(img.path, enabled, silent)
	end

	return proxy('imagelist', {
		remove = function(x, silent)
			local ci = swi.imagelist.get_current()
			if x == ci.path then evloop.trigger { event = 'ImgChangePre', data = ci } end
			api.remove(x)
			set_mark(x, false)
			if not silent then
				evloop.trigger { event = 'OptionSet', match = 'swi.imagelist.size', data = last_lsize }
			end
		end,
		add = function(x, silent)
			api.add(x)
			last_lsize = api.size()
			if not silent then
				evloop.trigger { event = 'OptionSet', match = 'swi.imagelist.size', data = last_lsize }
			end
		end,
		marked = marked,
		get_current = function() return _s[_s.get_mode()].get_image() end,
	})
end

local function text_proxy()
	local api = _s.text
	return proxy('text', {
		enabled = {
			set = function(val)
				if val == true then
					api.show()
					api.set_timeout(0)
				elseif val == false then
					api.hide()
				else
					api.set_timeout(val)
				end
			end,
		},
		is_visible = api.visible,
		line_spacing = {
			-- transform scale factor into a pixel value
			set = function(val)
				_s.text.set_spacing(math.floor((val - 1) * (rawget(swi.text, '_size') or 0)))
			end,
		},
		size = {
			set = function(val)
				api.set_size(val)

				-- update line spacing
				rawset(swi.text, '_size', val)
				swi.text.line_spacing = swi.text.line_spacing
			end,
		},

		format_exif = function(img_meta, val)
			if val and val:find('.', 0, true) then
				val = img_meta[val]
			else
				val = img_meta['Exif.Photo.' .. val] or img_meta['Exif.Image.' .. val]
			end
			if not val then return end

			local a, b = val:match '^(%-?[0-9]+)/([0-9]+)$'
			if a then
				local x, y = tonumber(a), tonumber(b)
				local n = x / y
				if math.floor(n) == n then -- integer, not rational number -> done
					return n
				elseif math.floor(n * 10) == n * 10 then -- print just 1 decimal point
					return string.format('%.1f', n)
				elseif b:match '^10*$' then -- just a decimal point offset
					return string.format('%.2f', n)
				elseif a:match '^10*$' then -- decimal point offset through the other side
					return string.format('1/%d', y / x)
				end
			end

			return val
		end,
	})
end

_s.on_window_resize(function()
	local ws = _s.get_window_size()
	local ows = rawget(swi, '_window_size')
	if not ows or ows.width ~= ws.width or ows.height ~= ws.height then
		-- TODO: find a way to distinguish focus events from resizing (both can happen at once)
		evloop.trigger { event = 'WinResized', data = ws }
		rawset(swi, '_window_size', ws)
	end
end)
---@type swi
_G.swi = proxy(nil, {
	eventloop = evloop,

	mode = {
		set = function(v)
			local m = _s.get_mode()
			_s.set_mode(v)
			evloop.trigger { event = 'ModeChanged', mode = m, match = v }
		end,
	},

	exit = function(code)
		local ev = { event = 'SwiLeavePre', match = tostring(code), data = code }
		evloop.trigger(ev)
		if not next(evloop.get_subscribed(ev)) then _s.exit(code) end
	end,

	-- TODO: how to make stderr appear? 2>&1 doesn't work
	---@param cmd string
	exec = function(cmd)
		cmd = cmd
			:gsub('([^%%])%%f', function(a) return string.format("%s'%s'", a, l.get_current().path) end)
			:gsub('([^%%])%%s', function(a)
				local s = table.concat(l.marked.get(), "' '")
				return string.format("%s'%s'", a, #s > 0 and s or l.get_current().path)
			end)
			:gsub(
				'([^%%])%%([^%%])',
				function(a, b) return string.format('%s%s%s', a, l.get_current().path, b) end
			)
			:gsub('%%%%', '%%')

		local p = io.popen(cmd, 'r')
		if not p then error('invalid command: ' .. cmd) end
		local out = p:read '*a'
		p:close()
		evloop.trigger { event = 'ShellCmdPost', data = { cmd = cmd, out = out } }
	end,

	imagelist = imagelist_proxy(),
	text = text_proxy(),
	viewer = viewer_proxy 'viewer',
	slideshow = viewer_proxy 'slideshow',
	gallery = gallery_proxy(),
})
