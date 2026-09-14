local snip = require 'sai.snippets'
snip.load_dir_if_single()
snip.resize_image_with_window()
snip.auto_open_video()

v.text.topright = { '{list.index}/{list.total}' }
v.text.bottomright = { '{scale}' }
v.text.bottomleft = {}
v.text.topleft = {
	'File:\t{name}',
	'Size:\t{sizehr}',
	'Res:\t{width}x{height}',
	'Exposure:\t{ExposureTime} s',
	'ISO:\t{ISOSpeedRatings}',
	'FNumber:\t{FNumber}',
	'FL:\t{FocalLength} mm',
	'Rating:\t{Rating}',
}

g.text.topleft = v.text.topleft
-- g.text.topleft = { 'File:\t{name}' }
g.text.topright = { 'Image:\t{list.index}/{list.total}', 'Marked:\t{sai.imagelist.marked.size}' }

require('sai.mode.key_help').short_binds = true

snip.print_option_changes()
snip.print_shell_output()
