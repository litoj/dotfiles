local h = require 'helpers'

---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
local function amap(bind, cb)
	h.map(bind, cb, 'viewer')
	h.map(bind, cb, 'gallery')
	h.map(bind, cb, 'slideshow')
end

-- ## Global
do
	-- TODO: make PR to make opts into variables, not fn
	-- TODO: what is freemove?
	-- TODO: regulate the movement speed with a counter
	amap('x', function() l.remove(h.current().path) end)
	amap({ 'q', '<Esc>' }, function() swi.exit(0) end)

	-- ### Settings toggle
	local alias = false
	swi.enable_antialiasing(alias)
	amap('u', function()
		alias = not alias
		swi.enable_antialiasing(alias)
	end)
	local info = false
	swi.text.hide()
	amap('m', function() -- m for metadata
		info = not info
		if info then
			swi.text.show()
		else
			swi.text.hide()
		end
	end)

	local function gen_rating(r)
		return function()
			h.exec('exiftool -overwrite_original_in_place -all:Rating=' .. r .. ' "%" >/dev/null')
			v.set_meta('Exif.Image.Rating', r)
		end
	end
	amap({ 'Alt+0', 'Alt+grave' }, gen_rating(0))
	amap('Alt+1', gen_rating(1))
	amap('Alt+2', gen_rating(2))
	amap('Alt+3', gen_rating(3))
	amap('Alt+4', gen_rating(4))
	amap('Alt+5', gen_rating(5))
	amap('<C-f>', [[EDIT_PRESET=editFixManualFl pem -e -x -c dummy "%"]])
	amap(
		'<Del>',
		[[bash -c 'x="%" && which trash && trash "$x" || mv "$x" "/tmp/my/trash/${x##*/}"']]
	)
end

-- ## Viewer
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function vmap(bind, cb) h.map(bind, cb, 'viewer') end

	vmap('g', function() swi.set_mode 'gallery' end)

	vmap({ '<S-Space>', '<BS>', 'Left', 'comma', '<S-h>' }, h.vgo.prev)
	vmap({ '<Space>', 'Right', 'period', '<S-l>' }, h.vgo.next)
	vmap('<Home>', h.vgo.first)
	vmap('<End>', h.vgo.last)

	vmap('h', h.vgo.left(5))
	vmap('<SML>', h.vgo.left(2))
	vmap('j', h.vgo.down(5))
	vmap('<SMD>', h.vgo.down(2))
	vmap('k', h.vgo.up(5))
	vmap('<SMU>', h.vgo.up(2))
	vmap('l', h.vgo.right(5))
	vmap('<SMR>', h.vgo.right(2))

	vmap('r', function() v.rotate(90) end)
	vmap('<S-r>', function() v.rotate(270) end)

	--- ### Scaling
	vmap('s', function()
		v.set_fix_scale 'fill'
		v.set_default_scale 'fill'
	end)
	vmap('<S-s>', function()
		v.set_fix_scale 'fit'
		v.set_default_scale 'fit'
	end)
	vmap('<A-s>', function()
		v.set_fix_scale 'optimal'
		v.set_default_scale 'optimal'
	end)
	vmap('<S-a>', function()
		v.set_fix_scale 'real'
		v.set_default_scale 'real'
	end)
	vmap('a', function() v.set_abs_scale(1) end)
	vmap('<A-a>', function() v.set_default_scale 'keep' end)
	vmap('<S-k>', function()
		v.set_abs_scale(0.35)
		v.set_default_scale 'keep'
	end)
	vmap('f', function() v.set_fix_scale 'fill' end)
	vmap('<S-f>', function() v.set_fix_scale 'fit' end)
	vmap('<Up>', function() v.set_abs_scale(v.get_scale() * 1.1) end)
	vmap('<Down>', function() v.set_abs_scale(v.get_scale() / 1.1) end)
	vmap('1', function() v.set_abs_scale(v.get_scale() * 2) end)
	vmap('2', function()
		v.set_abs_scale(2)
		v.set_default_scale 'keep'
	end)
	vmap('4', function() v.set_abs_scale(4) end)
	vmap('5', function() v.set_abs_scale(0.5) end)
	vmap('i', function() v.set_abs_scale(v.get_scale() * 1.1) end)
	vmap('o', function() v.set_abs_scale(v.get_scale() / 1.1) end)

	vmap('b', [[~/.config/sway/custombg '%']])
	vmap('<S-b>', [[cp '%' ~/Pictures/screen/]])
	vmap('<A-S-s>', [[adb push '%' /storage/emulated/0/Download/]])
	vmap('<A-f>', [[dragon-drop -x -T '%']])
	vmap('<A-e>', [[nohup xterm ranger --selectfile='%' &>/dev/null]])
	vmap('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh '%']])
	vmap('<S-e>', [[mkdir -p /tmp/img_export/ && cp '%' /tmp/img_export/]])
end

-- ## Gallery
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function gmap(bind, cb) h.map(bind, cb, 'gallery') end

	gmap('g', function() swi.set_mode 'viewer' end)

	gmap({ 'a', 'h', '<S-SMU>' }, h.ggo.left)
	gmap({ 's', 'j' }, h.ggo.down)
	gmap({ 'w', 'k' }, h.ggo.up)
	gmap({ 'd', 'l', '<S-SMD>' }, h.ggo.right)
end

-- ## Slideshow
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function smap(bind, cb) h.map(bind, cb, 'slideshow') end

	local function stime(factor)
		-- round to 1/x sec steps
		factor = math[factor < 1 and 'floor' or 'ceil'](s.get_timeout() * factor * 4) / 4
		s.set_timeout(factor)
		swi.set_status(string.format('Delay: %.2f s', factor))
	end

	amap('p', function()
		swi.set_mode 'slideshow'
		stime(1)
	end)

	smap('p', function() swi.set_mode 'viewer' end)
	smap({ '=', '<S-+>' }, function() stime(6 / 5) end)
	smap('-', function() stime(5 / 6) end)
end
