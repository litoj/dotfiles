-- require('swi.api.eventloop').debug_trigger = true
-- require'swi.api.eventloop'.debug_subscribe=true
require 'swi.api.globals'

-- maximize lazyload after the window has opened
local x
e.subscribe {
	event = 'WinResized',
	callback = function()
		if not x and not swi.overlay then -- resizes twice with overlay disabled
			x = true
			return
		end

		v.scale = v.default_scale
		require 'lazy'
		require 'keymappings'
		return true
	end,
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

v.window_background = 0xff000000
v.mark_color = 0xffbb33aa
v.history_limit = 5
v.preload_limit = 2
v.loop = true

g.pinch_factor = 100
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

swi.exif_orientation = false
e.subscribe {
	event = 'ImgChange',
	callback = function(s)
		if s.data.path:match '%.RAF$' then swi.exif_orientation = true end
		return true
	end,
}
