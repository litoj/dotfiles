---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
local function amap(bind, cb)
	h.map(bind, cb, v)
	h.map(bind, cb, g)
	h.map(bind, cb, s)
end

-- ## Global
do
	-- TODO: what is freemove?
	-- TODO: regulate the movement speed with a counter
	amap('x', function() l.remove(swi[swi.mode].get_current_image().path) end)
	amap({ 'q', '<Esc>' }, function() swi.exit(0) end)

	-- ### Settings toggle
	swi.antialiasing = false
	amap('u', function() swi.antialiasing = not swi.antialiasing end)
	t.allowed = false
	amap('i', function() t.allowed = not t.allowed end)
	amap('m', h.toggle_mark)

	local function gen_rating(r)
		return 'exiftool -overwrite_original_in_place -all:Rating=' .. r .. ' "%" >/dev/null'
	end
	amap({ 'Alt+0', 'Alt+grave' }, gen_rating(0))
	amap('Alt+1', gen_rating(1))
	amap('Alt+2', gen_rating(2))
	amap('Alt+3', gen_rating(3))
	amap('Alt+4', gen_rating(4))
	amap('Alt+5', gen_rating(5))
	amap('<C-f>', [[EDIT_PRESET=editFixManualFl pem -e -x -c dummy "%"]])
	amap('<Del>', [[x="%" && which trash && trash "$x" || mv "$x" /tmp/my/trash/]])
	amap('<A-f>', [[dragon-drop -x -T '%']])
end

-- ## Gallery
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function gmap(bind, cb) h.map(bind, cb, g) end

	gmap('g', function() swi.mode = 'viewer' end)

	gmap({ 'a', 'h', '<S-SMU>' }, h.ggo.left)
	gmap({ 's', 'j' }, h.ggo.down)
	gmap({ 'w', 'k' }, h.ggo.up)
	gmap({ 'd', 'l', '<S-SMD>' }, h.ggo.right)
	gmap(
		'<A-s>',
		function() h.exec('dragon-drop -x -a "' .. table.concat(h.get_marked(), '" "') .. '"') end
	)
	gmap(
		'<S-Del>',
		function() h.exec('$(which trash || echo rm) "' .. table.concat(h.get_marked(), '" "') .. '"') end
	)
end

-- ## Slideshow
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function smap(bind, cb) h.map(bind, cb, s) end

	local function stime(factor)
		-- round to 1/x sec steps
		factor = math[factor < 1 and 'floor' or 'ceil'](s.timeout * factor * 4) / 4
		s.timeout = factor
		t.set_status(string.format('Delay: %.2f s', factor))
	end

	amap('p', function()
		swi.mode = 'slideshow'
		stime(1)
	end)

	smap('p', function() swi.mode = 'viewer' end)
	smap({ '=', '<S-+>' }, function() stime(6 / 5) end)
	smap('-', function() stime(5 / 6) end)
end

-- ## Viewer
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function vmap(bind, cb) h.map(bind, cb, v) end

	vmap('g', function() swi.mode = 'gallery' end)

	vmap({ '<S-Space>', '<BS>', 'Left', 'comma', '<S-h>' }, h.vgo.prev)
	vmap({ '<Space>', 'Right', 'period', '<S-l>' }, h.vgo.next)
	vmap('<Home>', h.vgo.first)
	vmap('<End>', h.vgo.last)
	vmap('c', function()
		local px, py = unpack(swi.get_mouse_pos())
		v.scale_centered(v.image_scale * 1.1, px, py)
	end)
	vmap('<S-c>', function()
		local px, py = unpack(swi.get_mouse_pos())
		v.scale_centered(v.image_scale / 1.1, px, py)
	end)

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
		v.image_scale = 'fill'
		v.default_scale = 'fill'
	end)
	vmap('<S-s>', function()
		v.image_scale = 'fit'
		v.default_scale = 'fit'
	end)
	vmap('<A-s>', function()
		v.image_scale = 'optimal'
		v.default_scale = 'optimal'
	end)
	vmap('<S-a>', function()
		v.image_scale = 'real'
		v.default_scale = 'real'
	end)
	vmap('a', function() v.image_scale = 1 end)
	vmap('<A-a>', function() v.default_scale = 'keep' end)
	vmap('<S-k>', function()
		v.image_scale = 0.35
		v.default_scale = 'keep'
	end)
	vmap('f', function() v.image_scale = 'fill' end)
	vmap('<S-f>', function() v.image_scale = 'fit' end)
	vmap('<Up>', function() v.image_scale = v.image_scale * 1.1 end)
	vmap('<Down>', function() v.image_scale = v.image_scale / 1.1 end)
	vmap('1', function() v.image_scale = v.image_scale * 2 end)
	vmap('2', function()
		v.image_scale = 2
		v.default_scale = 'keep'
	end)
	vmap('4', function() v.image_scale = 4 end)
	vmap('5', function() v.image_scale = 0.5 end)
	vmap({ '<S-o>', '<S-_>', '=', '<S-+>' }, function() v.image_scale = v.image_scale * 1.1 end)
	vmap({ 'o', '-' }, function() v.image_scale = v.image_scale / 1.1 end)

	vmap('b', [[~/.config/sway/custombg '%']])
	vmap('<S-b>', [[cp '%' ~/Pictures/screen/]])
	vmap('<A-S-s>', [[adb push '%' /storage/emulated/0/Download/]])
	vmap('<A-e>', [[nohup xterm ranger --selectfile='%' &>/dev/null]])
	vmap('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh '%']])
	vmap('<S-e>', [[mkdir -p /tmp/img_export/ && cp '%' /tmp/img_export/]])
end
