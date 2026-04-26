-- require('swi.api.eventloop').debug_trigger = true
-- require'swi.api.eventloop'.debug_subscribe=true
require 'swi.api.globals'

-- maximize lazyload after the window has opened
e.subscribe {
	event = 'SwiEnter',
	callback = function()
		require 'lazy'
		require 'binds'
		return true
	end,
}

swi.apply_raw_wb = false
swi.overlay = false
l.order = 'alpha'
t.shadow = 0xff101010
t.foreground = 0xffffffff
t.padding = 0
t.line_spacing = 0.5
t.size = 23
t.status_timeout = 2
t.enabled = false

swi.antialiasing = false
v.window_background = 0xff000000
v.mark_color = 0xffbb33aa
v.history_limit = 5
v.preload_limit = 2

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
