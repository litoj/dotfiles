---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
local function amap(bind, cb)
	h.map(v, bind, cb)
	h.map(g, bind, cb)
	h.map(s, bind, cb)
end

-- ## Global
do
	-- TODO: what is freemove?
	-- TODO: regulate the movement speed with a counter
	amap('x', function() l.remove(l.get_current().path) end)
	amap({ 'q', '<Esc>' }, function() swi.exit(0) end)

	-- ### Settings toggle
	amap('u', function() swi.antialiasing = not swi.antialiasing end)
	amap('i', function() t.enabled = not t.enabled end)
	h.map(v, 'd', function() t.enabled = not t.enabled end)
	amap('<C-=>', function() t.size = t.size + 1 end)
	amap('<C-->', function() t.size = t.size - 1 end)

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
	amap('<A-f>', [[dragon-drop -x -T %s]])
	amap('<A-S-s>', [[adb push %s /storage/emulated/0/Download/]])
end

-- ## Gallery
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function gmap(bind, cb) h.map(g, bind, cb) end

	gmap('g', function() swi.mode = 'viewer' end)

	gmap({ 'a', 'h', '<S-SMU>' }, g.go.left)
	gmap({ 's', 'j' }, g.go.down)
	gmap({ 'w', 'k' }, g.go.up)
	gmap({ 'd', 'l', '<S-SMD>' }, g.go.right)
	gmap('<A-s>', 'dragon-drop -x -a %s')
	gmap({ ' ', 'm' }, function()
		l.marked.set_current 'toggle'
		g.go.right()
	end)
	gmap({ '<S- >', '<S-m>' }, function()
		l.marked.set_current 'toggle'
		g.go.left()
	end)
	gmap('<S-Del>', function()
		h.exec '$(which trash || echo rm) %s'
		local marked = l.marked.get()
		for _, f in ipairs(marked) do
			l.remove(f)
		end
	end)
end

-- ## Slideshow
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function smap(bind, cb) h.map(s, bind, cb) end

	local function stime(factor)
		-- round to 1/x sec steps
		factor = math[factor < 1 and 'floor' or 'ceil'](s.timeout * factor * 4) / 4
	end

	amap('<S-p>', function()
		if swi.mode == 'slideshow' then
			swi.mode = 'viewer'
		else
			swi.mode = 'slideshow'
		end
	end)

	smap({ '=', '<S-+>' }, function() stime(6 / 5) end)
	smap('-', function() stime(5 / 6) end)
end

-- ## Viewer
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function vmap(bind, cb) h.map(v, bind, cb) end

	vmap('g', function() swi.mode = 'gallery' end)

	vmap('m', function() l.marked.set_current 'toggle' end)

	vmap({ '<S-Space>', '<BS>', 'Left', 'comma', '<S-h>', '<S-n>' }, v.go.prev)
	vmap({ '<Space>', 'Right', 'period', '<S-l>', 'n' }, v.go.next)
	vmap('<Home>', v.go.first)
	vmap('<End>', v.go.last)
	vmap('c', function()
		local p = swi.get_mouse_pos()
		v.scale_centered(v.scale * 1.1, p.x, p.y)
	end)
	vmap('<S-c>', function()
		local p = swi.get_mouse_pos()
		v.scale_centered(v.scale / 1.1, p.x, p.y)
	end)

	vmap('h', v.step.left)
	vmap('j', v.step.down)
	vmap('k', v.step.up)
	vmap('l', v.step.right)
	vmap('<S-SML>', function() v.step.left(20) end)
	vmap('<S-SMD>', function() v.step.down(20) end)
	vmap('<S-SMU>', function() v.step.up(20) end)
	vmap('<S-SMR>', function() v.step.right(20) end)

	vmap('r', function() v.rotate(90) end)
	vmap('<S-r>', function() v.rotate(270) end)

	--- ### Scaling
	vmap('s', function()
		v.scale = 'fill'
		v.default_scale = 'fill'
	end)
	vmap('<S-s>', function()
		v.scale = 'fit'
		v.default_scale = 'fit'
	end)
	vmap('<A-s>', function()
		v.scale = 'optimal'
		v.default_scale = 'optimal'
	end)
	vmap('<S-a>', function()
		v.scale = 1
		v.default_scale = 'real'
	end)
	vmap('a', function() v.scale = 1 end)
	vmap('<A-a>', function() v.default_scale = 'keep_by_size' end)
	vmap('<S-k>', function()
		v.scale = 0.35
		v.default_scale = 'keep_by_width'
	end)
	vmap('f', function() v.scale = 'fill' end)
	vmap('<S-f>', function() v.scale = 'fit' end)
	vmap('<SMU>', function() v.scale = v.get_abs_scale() * 1.05 end)
	vmap('<SMD>', function() v.scale = v.get_abs_scale() / 1.05 end)
	vmap('1', function() v.scale = v.get_abs_scale() * 2 end)
	vmap('2', function()
		v.scale = 2
		v.default_scale = 'keep'
	end)
	vmap('4', function() v.scale = 4 end)
	vmap('5', function() v.scale = 0.5 end)
	vmap({ '<Up>', '=', '<S-+>', 'p' }, function() v.scale = v.get_abs_scale() * 1.1 end)
	vmap({ '<Down>', '-', '<S-_>', 'o' }, function() v.scale = v.get_abs_scale() / 1.1 end)

	vmap('b', [[~/.config/sway/custombg %f]])
	vmap('<S-b>', [[cp %f ~/Pictures/screen/]])
	vmap('<A-e>', [[xterm ranger --selectfile=%f &>/dev/null &]])
	vmap('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %f]])
	vmap('<S-e>', [[mkdir -p /tmp/img_export/ && cp %s /tmp/img_export/]])
end
