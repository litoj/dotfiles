---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
local function amap(bind, cb)
	v.map(bind, cb)
	s.map(bind, cb)
	g.map(bind, cb)
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
	v.map('d', function() t.enabled = not t.enabled end)
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
	amap('<A-f>', [[dragon-drop -x %f]])
	amap('<A-S-s>', [[adb push %s /storage/emulated/0/Download/]])
end

-- ## Gallery
do
	g.map('g', function() swi.mode = 'viewer' end)

	g.map({ 'a', 'h', '<S-SMU>' }, g.go.left)
	g.map({ 's', 'j' }, g.go.down)
	g.map({ 'w', 'k' }, g.go.up)
	g.map({ 'd', 'l', '<S-SMD>' }, g.go.right)
	g.map('<A-s>', 'dragon-drop -x -A %s')
	g.map({ ' ', 'm' }, function()
		l.marked.set_current 'toggle'
		g.go.right()
	end)
	g.map({ '<S- >', '<S-m>' }, function()
		l.marked.set_current 'toggle'
		g.go.left()
	end)
	g.map('<S-Del>', function()
		swi.exec '$(which trash || echo rm) %s'
		local marked = l.marked.get()
		for _, f in ipairs(marked) do
			l.remove(f)
		end
	end)
end

-- ## Slideshow
do
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

	s.map({ '=', '<S-+>' }, function() stime(6 / 5) end)
	s.map('-', function() stime(5 / 6) end)
end

-- ## Viewer
do
	v.map('g', function() swi.mode = 'gallery' end)

	v.map('m', function() l.marked.set_current 'toggle' end)

	v.map({ '<S-Space>', '<BS>', 'Left', 'comma', '<S-h>', '<S-n>' }, v.go.prev)
	v.map({ '<Space>', 'Right', 'period', '<S-l>', 'n' }, v.go.next)
	v.map('<Home>', v.go.first)
	v.map('<End>', v.go.last)

	v.map('h', v.step.left)
	v.map('j', v.step.down)
	v.map('k', v.step.up)
	v.map('l', v.step.right)
	v.map('<S-SML>', function() v.step.left(20) end)
	v.map('<S-SMD>', function() v.step.down(20) end)
	v.map('<S-SMU>', function() v.step.up(20) end)
	v.map('<S-SMR>', function() v.step.right(20) end)

	v.map('r', function() v.rotate(90) end)
	v.map('<S-r>', function() v.rotate(270) end)

	--- ### Scaling
	v.map('s', function()
		v.scale = 'fill'
		v.default_scale = 'fill'
	end)
	v.map('<S-s>', function()
		v.scale = 'fit'
		v.default_scale = 'fit'
	end)
	v.map('<A-s>', function()
		v.scale = 'optimal'
		v.default_scale = 'optimal'
	end)
	v.map('<S-a>', function()
		v.scale = 1
		v.default_scale = 'real'
	end)
	v.map('a', function() v.scale = 1 end)
	v.map('<A-a>', function() v.default_scale = 'keep_by_size' end)
	v.map('<S-k>', function()
		v.scale = 0.35
		v.default_scale = 'keep'
	end)
	v.map('f', function() v.scale = 'fill' end)
	v.map('<S-f>', function() v.scale = 'fit' end)
	v.map({ 'c', '<SMU>' }, function()
		local p = swi.get_mouse_pos()
		v.scale_centered(v.get_abs_scale() * 1.05, p.x, p.y)
	end)
	v.map({ '<S-c>', '<SMD>' }, function()
		local p = swi.get_mouse_pos()
		v.scale_centered(v.get_abs_scale() / 1.05, p.x, p.y)
	end)
	v.map('1', function() v.scale = v.get_abs_scale() * 2 end)
	v.map('2', function()
		v.scale = 2
		v.default_scale = 'keep_by_width'
	end)
	v.map('4', function() v.scale = 4 end)
	v.map('5', function() v.scale = 0.5 end)
	v.map({ '<Up>', '=', '<S-+>', 'p' }, function() v.scale = v.get_abs_scale() * 1.1 end)
	v.map({ '<Down>', '-', '<S-_>', 'o' }, function() v.scale = v.get_abs_scale() / 1.1 end)

	v.map('b', [[~/.config/sway/custombg %f]])
	v.map('<S-b>', [[cp %f ~/Pictures/screen/]])
	v.map('<A-e>', [[xterm ranger --selectfile=%f &>/dev/null &]])
	v.map('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %f]])
	v.map('<S-e>', [[mkdir -p /tmp/img_export/ && cp %s /tmp/img_export/]])
end
