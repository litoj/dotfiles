_G.swi = swayimg
_G.v = swi.viewer
_G.g = swi.gallery
_G.l = swi.imagelist
_G.s = swi.slideshow

--[[ local meta = {
	__index = function(self, idx) return self._api[idx] or self._api['get_' .. idx]() end,
	__new_index = function(self, idx, val)
		(type(val) == 'boolean' and self._api['enable_' .. idx] or self._api['set_' .. idx])(val)
	end,
}
_G.o = setmetatable({}, {
	__index = function(self, idx)
		local val = swayimg[idx]
		if type(val) == 'function' then return val end
		if val == nil then return swayimg['get_' .. idx]() end

		self[idx] = setmetatable({ _api = swayimg[idx] }, meta)
		return self[idx]
	end,
	__new_index = meta.__new_index,
}) ]]

swi.on_initialized(function()
	if l.size() == 1 then l.add(v.current_image().path:match '.+/') end
end)
require 'keymappings'

swi.enable_overlay(false)
l.set_order 'alpha'
-- s.text.set_font('Nova Square')
swi.text.set_shadow(0xff101010)
swi.text.set_foreground(0xffffffff)
swi.text.set_padding(0)
swi.text.set_size(20)
swi.text.set_status_timer(2)
-- s.text.set_timer(0)

v.set_window_background(0xff000000)
v.set_history_limit(5)
v.set_preload_limit(2)
v.enable_loop(true)
v.set_default_scale 'optimal'

g.set_window_color(0xff000000)
g.set_border_size(10)
g.set_background_color(0xff101010)
g.set_border_color(0xffbb33aa)
g.set_thumb_size(500)
g.set_selected_scale(1.2)
g.set_aspect 'keep'
g.set_cache_size(0)
g.enable_preload(false)
g.enable_pstore(false)

v.set_text_tr { '{list.index}/{list.total}' }
v.set_text_br { '{scale}' }
v.set_text_bl {}
v.on_change_image(function()
	for _, v in pairs({swi.imagelist.get()[1],v.current_image()}) do
	for x, y in pairs(v) do
			if not x:match'meta' then
		print(x..':'..tostring(y))end
	end
	end
	local i = v.current_image()
	local t = {
		'File: ' .. i.path:match '[^/]+$',
		string.format('Size: %.1f MB', i.size / 1000000),
		string.format('Res: %dx%d', i.width, i.height),
	}
	if i['meta.Exif.Image.ExifTag'] then
		local function fmt(name, val, default)
			if val and val:match '%.' then
				val = i[val] or default
			else
				val = i['meta.Exif.Photo.' .. (val or name)] or default
			end
			if not val then return end

			local a, b = val:match '^(%-?[0-9]+)/([0-9]+)$'
			if a then
				local x, y = tonumber(a), tonumber(b)
				local n = x / y
				if math.floor(n) == n then
					val = n
				elseif math.floor(n * 10) == n * 10 then
					val = string.format('%.1f', n)
				elseif b:match '^10*$' then
					val = string.format('%.2f', n)
				elseif a:match '^10*$' then
					val = string.format('1/%d', y / x)
				end
			end

			t[#t + 1] = name .. ': ' .. val
		end
		fmt('Exposure', 'ExposureTime')
		fmt('ISO', 'ISOSpeedRatings')
		fmt 'FNumber'
		fmt 'FocalLength'
		fmt('Rating', 'meta.Exif.Image.Rating')
	end

	v.set_text_tl(t)
end)
