v.default_scale = 'optimal'
e.subscribe {
	event = 'SwiEnter',
	callback = function()
		if l.size() == 1 then
			l.adjacent = true
			l.add(l.get_current().path:match '.+/')
		end

		e.subscribe {
			event = 'OptionSet',
			pattern = '^swi%.?[^.]*%.[^.]*$', -- all main opt accesses
			callback = function(state)
				local v = state.data
				if type(v) == 'number' then
					v = string.format('%.2f', v)
				elseif type(v) == 'table' then
					return
				end

				local name = state.match:match '([^.]+%.[^.]+)$'
				t.set_status(
					('%s%s: %s'):format(
						name:sub(1, 1):upper(),
						name:sub(2):gsub('[_.](.)', function(x) return ' ' .. x:upper() end),
						v
					)
				)
			end,
		}

		return true
	end,
}
e.subscribe {
	event = 'WinResized',
	mode = 'viewer',
	callback = function()
		if type(v.scale) == 'string' then swayimg.viewer.set_fix_scale(v.scale) end
	end,
}

e.subscribe {
	event = 'ShellCmdPost',
	callback = function(state) t.set_status(state.data.out) end,
}

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

swi.exif_orientation = false
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

g.text.topleft = { 'File: {name}' }
g.text.topright = { 'Image: {list.index}/{list.total}', 'Marked: 0' }
e.subscribe {
	event = 'OptionSet',
	pattern = 'swi.imagelist.marked.size',
	callback = function(state) g.text.topright = { g.text.topright[1], 'Marked: ' .. state.data } end,
}

v.text.topright = { '{list.index}/{list.total}' }
v.text.bottomright = { '{scale}' }
v.text.bottomleft = {}
v.text.topleft = {'File: {name}', 'Size: {sizehr}', 'Res: {frame.width}x{frame.height}',
	'Exposure: {ExposureTime} s',
	'ISO: {ISOSpeedRatings}',
	'FNumber: {FNumber}',
	'FL: {FocalLength} mm',
	'Rating: {Rating}'
}
e.subscribe {
	event = 'ImgChange',
	mode = 'viewer',
	callback = function()
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
	end,
}
