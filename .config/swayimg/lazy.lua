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

snip.print_option_changes()
snip.print_shell_output()
