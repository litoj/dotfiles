v.default_scale = 'optimal'
swi.on_window_resize(function()
	if swi.mode == 'viewer' and type(v.scale) == 'string' then v.scale = v.default_scale end
end)

swi.on_initialized(function()
	if l.size() == 1 then l.add(h.current().path:match '.+/') end
end)

swi.overlay = false
swi.antialiasing = false
l.order = 'alpha'
t.shadow = 0xff101010
t.foreground = 0xffffffff
t.padding = 0
t.line_spacing = 0.5
t.size = 23
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
l.marked.on_change(function(count)
	local t = g.text_tl
	t[#t] = 'Marked: ' .. count
	g.text_tl = t
end)

v.text_tr = { '{list.index}/{list.total}' }
v.text_br = { '{scale}' }
v.text_bl = {}
v.on_image_change(function()
	local i = v.get_image()
	if i.path:match '%.RAF$' then
		local o = tonumber(i.meta['Exif.Image.Orientation'])
		v.set_meta('Exif.Image.Orientation', '0') -- to not repeatedly rotate
		if o == 8 then
			v.rotate(90)
			v.scale = v.default_scale
		elseif o == 6 then
			v.rotate(270)
			v.scale = v.default_scale
		end
	end
	local t = {
		'File: ' .. i.path:match '[^/]+$',
		string.format('Size: %.1f MB', i.size / 1000000),
		string.format('Res: %dx%d', i.width, i.height),
	}
	local m = i.meta
	if m['Exif.Photo.ExposureTime'] then
		t[#t + 1] = 'Exposure: ' .. h.format_exif(m, 'ExposureTime') .. ' s'
		t[#t + 1] = 'ISO: ' .. h.format_exif(m, 'ISOSpeedRatings')
		t[#t + 1] = 'FNumber: ' .. h.format_exif(m, 'FNumber')
		t[#t + 1] = 'FL: ' .. h.format_exif(m, 'FocalLength') .. ' mm'
		t[#t + 1] = 'Rating: ' .. (h.format_exif(m, 'Exif.Image.Rating') or '0')
	end

	v.text_tl = t
end)
