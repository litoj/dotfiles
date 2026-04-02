local snip = require 'swi.snippets'
snip.load_dir_if_single()
snip.pretty_print_tables(true)

v.default_scale = 'optimal'
snip.resize_image_with_window()

g.text.topleft = { 'File:\t{name}' }
g.text.topright = { 'Image:\t{list.index}/{list.total}', 'Marked:\t{swi.imagelist.marked.size}' }

v.text.topright = { '{list.index}/{list.total}' }
v.text.bottomright = { '{scale}' }
v.text.bottomleft = {}
v.text.topleft = {
	'File:\t{name}',
	'Size:\t{sizehr}',
	'Res:\t{frame.width}x{frame.height}',
	'Exposure:\t{ExposureTime} s',
	'ISO:\t{ISOSpeedRatings}',
	'FNumber:\t{FNumber}',
	'FL:\t{FocalLength} mm',
	'Rating:\t{Rating}',
}
-- e.subscribe {
-- 	event = 'ImgChange',
-- 	mode = 'viewer',
-- 	callback = function(s)
-- 		local i = s.data
-- 		if i.path:match '%.RAF$' then
-- 			local o = tonumber(i.meta['Exif.Image.Orientation'])
-- 			v.set_meta('Exif.Image.Orientation', '0') -- to not repeatedly rotate
-- 			if o == 8 then
-- 				v.rotate(90)
-- 				v.scale = v.default_scale
-- 			elseif o == 6 then
-- 				v.rotate(270)
-- 				v.scale = v.default_scale
-- 			end
-- 		end
-- 	end,
-- }

snip.print_option_changes()
snip.print_shell_output()
