local snip = require 'swi.snippets'
snip.load_dir_if_single()

v.default_scale = 'optimal'
snip.resize_image_with_window()

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
v.text.topleft = {
	'File: {name}',
	'Size: {sizehr}',
	'Res: {frame.width}x{frame.height}',
	'Exposure: {ExposureTime} s',
	'ISO: {ISOSpeedRatings}',
	'FNumber: {FNumber}',
	'FL: {FocalLength} mm',
	'Rating: {Rating}',
}
e.subscribe {
	event = 'ImgChange',
	mode = 'viewer',
	callback = function(s)
		local i = s.data
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

snip.print_option_changes()
snip.print_shell_output()
