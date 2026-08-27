-- ## Global
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	local function amap(bind, cb)
		v.map(bind, cb)
		s.map(bind, cb)
		g.map(bind, cb)
	end

	-- TODO: regulate the movement speed with a counter
	amap('x', function() l.remove(l.get_current().path) end)
	amap('q', function() sai.exit(0) end)

	-- ### Settings toggle
	amap('u', function() sai.antialiasing = not sai.antialiasing end)
	local osize = t.size
	amap('<C-=>', function() t.size = t.size + 1 end)
	amap('<C-->', function() t.size = t.size - 1 end)
	amap('<C-0>', function() t.size = osize end)
	amap('r', function() sai.format_params.raw.camera_wb = not sai.format_params.raw.camera_wb end)
	amap('F5', function() sai[sai.mode].reload() end)

	amap('<S-p>', function()
		if sai.mode == 'slideshow' then
			sai.mode = 'viewer'
		else
			sai.mode = 'slideshow'
		end
	end)
	local function gen_rating(r)
		return 'exiftool -overwrite_original_in_place -all:Rating=' .. r .. ' %f >/dev/null'
	end
	amap({ 'Alt+0', 'Alt+grave' }, gen_rating(0))
	amap('Alt+1', gen_rating(1))
	amap('Alt+2', gen_rating(2))
	amap('Alt+3', gen_rating(3))
	amap('Alt+4', gen_rating(4))
	amap('Alt+5', gen_rating(5))
	amap('<C-f>', [[pem -D --config-picker -- -e -x -c dummy %s]])
	amap('<Del>', [[which trash && trash %f || mv %f /tmp/my/trash/]])
	amap('<A-f>', [[dragon-drop -x %f]])
	amap('<A-S-s>', [[adb push %s /storage/emulated/0/Download/]])
	amap('b', [[~/.config/sway/custombg %f]])
	amap('<S-b>', [[cp %f ~/Pictures/screen/]])

	g.map('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %s]])
	v.map('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %f]])
	amap('<A-e>', [[xterm ranger --selectfile=%f &>/dev/null &]])
	amap('<S-e>', [[mkdir -p /tmp/img_export/ && cp %s /tmp/img_export/]])
	local raw_path = '/tmp/raw_to_jpg/'

	v.map('<C-S-e>', function()
		sai.exec('mkdir -p ' .. raw_path)
		local i = v.get_image()
		local dst = raw_path .. i.path:match '([^/]+)%.[^./]-$' .. '.jxl'
		sai.exec(([[darktable-cli '%s' '%s' --width %d --hq 0 \
		--style 'raw|swayimg' --style-overwrite]]):format(i.path, dst, i.width))
		-- TODO: try out dcraw -T %f; mv %f.TIFF ...
	end, 'Export raw to ' .. raw_path .. '<>.jxl')
	v.map('e', function()
		if v.get_image().path:match '%.RAF$' then
			sai.exec 'KIND=renameOrRawToJPG xdg-open -c ~/.config/ranger/transform.conf.sh %f'
		end
	end)
	g.map('e', function()
		if g.get_image().path:match '%.RAF$' then
			sai.exec 'KIND=resizeOrExtractPreview xdg-open -c ~/.config/ranger/transform.conf.sh %f'
		end
	end)

	---@diagnostic disable-next-line: missing-fields
	local fm = require('sai.mode.filter').new {}
	amap('/', function() fm.enabled = true end)

	---@diagnostic disable-next-line: missing-fields
	local cmd = require('sai.mode.cmd').new {}
	amap(':', function() cmd.enabled = true end)
end

-- ## Gallery
do
	local gmap = g.map

	gmap('g', function() sai.mode = 'viewer' end)

	gmap({ 'a', 'h', '<S-SMU>' }, g.go.left)
	gmap({ 's', 'j' }, g.go.down)
	gmap({ 'w', 'k' }, g.go.up)
	gmap({ 'd', 'l', '<S-SMD>' }, g.go.right)
	gmap('<C-h>', g.go.first)
	gmap('<C-j>', g.go.pgdown)
	gmap('<C-k>', g.go.pgup)
	gmap('<C-l>', g.go.last)

	gmap('<A-s>', 'dragon-drop -x -A %s')
	gmap({ ' ', 'm' }, function()
		l.marked.set_current 'toggle'
		g.go.right()
	end)
	gmap({ '<S- >', '<S-m>' }, function()
		l.marked.set_current 'toggle'
		g.go.left()
	end)
	local function set_marked_for_all(val)
		local path = g.get_image().path
		g.go.last()
		for _ = l.size(), 1, -1 do
			l.marked.set_current(val)
			g.go.left()
		end
		g.go(path)
	end
	gmap('<C-a>', function() set_marked_for_all(true) end)
	gmap('<C-S-a>', function() set_marked_for_all(false) end)
	gmap('<S-Del>', function()
		if sai.exec '$(which trash || echo rm) %m' then
			local marked = l.marked.get()
			for _, f in ipairs(marked) do
				l.remove(f)
			end
		end
	end)

	gmap('<LMB>', function()
		local pos = sai.get_mouse_pos()
		g.go(pos.x, pos.y)
	end)
	gmap('<2-LMB>', function()
		local pos = sai.get_mouse_pos()
		g.go(pos.x, pos.y)
		sai.mode = 'viewer'
	end)
end

-- ## Slideshow
do
	local function stime(factor)
		-- round to 1/x sec steps
		factor = math[factor < 1 and 'floor' or 'ceil'](s.timeout * factor * 4) / 4
	end

	s.map({ '=', '<S-+>' }, function() stime(6 / 5) end)
	s.map('-', function() stime(5 / 6) end)
end

-- ## Viewer
do
	local vmap = v.map
	vmap('g', function() sai.mode = 'gallery' end)

	vmap('m', function() l.marked.set_current 'toggle' end)
	vmap('c', function() v.auto_center = not v.auto_center end)

	vmap({ '<S-Space>', '<BS>', 'Left', 'comma', '<S-h>', '<S-n>' }, v.go.prev)
	vmap({ '<Space>', 'Right', 'period', '<S-l>', 'n' }, v.go.next)
	vmap('<Home>', v.go.first)
	vmap('<End>', v.go.last)

	vmap('h', v.pan.left)
	vmap('j', v.pan.down)
	vmap('k', v.pan.up)
	vmap('l', v.pan.right)
	vmap('<S-SML>', function() v.pan.left(20) end)
	vmap('<S-SMD>', function() v.pan.down(20) end)
	vmap('<S-SMU>', function() v.pan.up(20) end)
	vmap('<S-SMR>', function() v.pan.right(20) end)

	-- ### Scaling
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
	vmap('<A-a>', function() v.default_scale = 'keep_size' end)
	vmap('<S-k>', function()
		v.scale = 0.35
		v.default_scale = 'keep'
	end)
	vmap('f', function() v.scale = 'fill' end)
	vmap('<S-f>', function() v.scale = 'fit' end)
	vmap({ '<SMU>' }, function()
		local p = sai.get_mouse_pos()
		v.scale_centered(v.get_abs_scale() * 1.05, p.x, p.y)
	end)
	vmap({ '<SMD>' }, function()
		local p = sai.get_mouse_pos()
		v.scale_centered(v.get_abs_scale() / 1.05, p.x, p.y)
	end)
	vmap('1', function() v.scale = v.get_abs_scale() * 2 end)
	local snip = require 'sai.snippets'
	vmap('2', function()
		v.scale = 2
		local t = { 'width', 'height', 'size', 'fit', 'fill' }
		local pref = 'keep_'
		v.default_scale = pref .. (snip.cycle_values(t, v.default_scale:sub(#pref + 1)) or 'width')
	end)
	vmap('4', function() v.scale = 4 end)
	vmap('5', function() v.scale = 0.5 end)
	vmap({ '<Up>', 'i' }, function() v.scale = v.get_abs_scale() * 1.1 end)
	vmap({ '<Down>', 'o', '<S-_>' }, function() v.scale = v.get_abs_scale() / 1.1 end)

	vmap(
		'<MMB>',
		function() v.scale = ({ [1] = 2, [2] = v.default_scale })[v.get_abs_scale()] or 1 end
	)
end
