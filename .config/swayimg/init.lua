-- require 'api'
require 'api_conv'
_G.v = swi.viewer
_G.g = swi.gallery
_G.l = swi.imagelist
_G.s = swi.slideshow
_G.t = swi.text
_G.h = require 'helpers'

v.default_scale = 'optimal'
swi.on_window_resize(function()
	if swi.mode == 'viewer' then v.scale = v.default_scale end
end)
swi.on_initialized(function()
	if l.size() == 1 then l.add(swi[swi.mode].get_image().path:match '.+/') end
end)
require 'keymappings'

swi.overlay = false
swi.antialiasing = false
l.order = 'alpha'
-- t.font = 'Nova Square'
t.shadow = 0xff101010
t.foreground = 0xffffffff
t.padding = 0
t.size = 20
t.status_timeout = 2
t.enabled = false

v.window_background = 0xff000000
v.mark_color = 0xffbb33aa
v.history_limit = 5
v.preload_limit = 2
v.loop = true

g.window_color = 0xff000000
g.mark_color = 0xffff55ff
g.border_size = 10
g.unselected_color = 0xff101010
g.border_color = 0xffbb33aa
g.thumb_size = 500
g.selected_scale = 1.2
g.aspect = 'keep'
g.cache_limit = 10000
g.preload = true
g.pstore = false

g.text_tr = {}
g.text_tl = { 'File: {name}', 'Image: {list.index}/{list.total}', 'Marked: 0' }
h.on_marked_count_change(function()
	local t = g.text_tl
	t[3] = 'Marked: ' .. h.get_marked_count()
	g.text_tl = t
end)

v.text_tr = { '{list.index}/{list.total}' }
v.text_br = { '{scale}' }
v.text_bl = {}
v.on_image_change(function()
	local i = v.get_image()
	local t = {
		'File: ' .. i.path:match '[^/]+$',
		string.format('Size: %.1f MB', i.size / 1000000),
		string.format('Res: %dx%d', i.width, i.height),
	}
	local m = i.meta
	if m['Exif.Image.ExifTag'] then
		local function fmt(name, val, default)
			if val and val:match '%.' then
				val = m[val] or default
			else
				val = m['Exif.Photo.' .. (val or name)] or default
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
		fmt('FL', 'FocalLength')
		fmt('Rating', 'meta.Exif.Image.Rating')
	end

	v.text_tl = t
end)
