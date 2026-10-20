local snip = require 'sai.snippets'
-- ## Global
do
	---@param bind string|string[]
	---@param cb string|function shellcmd to execute or callback
	---@param desc string?
	local function amap(bind, cb, desc)
		v:map(bind, cb, desc)
		s:map(bind, cb, desc)
		g:map(bind, cb, desc)
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
	amap('r', function() sai.formats.raw.camera_wb = not sai.formats.raw.camera_wb end)
	amap('F5', function() sai[sai.mode]:reload() end)

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
	-- amap('<Del>', [[which trash && trash %f* || mv %f* /tmp/my/trash/]])
	amap('<Del>', [[mv %f* /tmp/my/trash/]])
	g:map('<A-Del>', [[bash -c 'for f in %s; do rm "$f"*; done']])
	amap('<A-f>', [[dragon-drop -x %f]])
	amap('<A-S-s>', [[adb push %s /storage/emulated/0/Download/]])
	amap('b', [[~/.config/sway/custombg %f]])
	amap('<S-b>', [[cp %f ~/Pictures/screen/]])

	g:map('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %s]])
	v:map('<C-e>', [[xdg-open -c ~/.config/ranger/edit.conf.sh %f]])
	amap('<A-e>', [[xterm ranger --selectfile=%f &>/dev/null &]])
	amap('<S-e>', [[mkdir -p /tmp/img_export/ && cp %s /tmp/img_export/]])
	amap('<C-u>', function()
		local found =
			sai.exec [[fd "$(echo %f | sed -E 's,.*/([0-9_-]{17}).*,\1,')" -t f ~/Pictures/sdcard/Pictures/ | head -n 1]]
		if found == '' then
			sai.notify 'File not found'
			return
		end
		l.clear()
		l.add(found, true)
		l.select(found)
	end)
	local raw_path = '/tmp/raw_to_jpg/'

	v:map('<C-S-e>', function()
		sai.exec('mkdir -p ' .. raw_path)
		local i = v.get_image()
		local dst = raw_path .. i.path:match '([^/]+)%.[^./]-$' .. '.jxl'
		sai.exec(([[darktable-cli '%s' '%s' --width %d --hq 0 \
		--style 'raw|swayimg' --style-overwrite]]):format(i.path, dst, i.width))
		-- TODO: try out dcraw -T %f; mv %f.TIFF ...
	end, 'Export raw to ' .. raw_path .. '<>.jxl')
	---@diagnostic disable-next-line: missing-fields
	local te = require('sai.mode.tag_edit').new {}
	amap('e', function()
		if l.get_current().path:match '%.RAF$' then
			if sai.mode == 'gallery' then
				sai.exec 'KIND=resizeOrExtractPreview xdg-open -c ~/.config/ranger/transform.conf.sh %f'
			else
				sai.exec 'KIND=renameOrRawToJPG xdg-open -c ~/.config/ranger/transform.conf.sh %f'
			end
		else
			te.enabled = not te.enabled
		end
	end, 'RawToPreview')

	-- TODO: implement similar to help mode for bindings list and variables
	---@diagnostic disable-next-line: missing-fields
	local fm = require('sai.mode.image_filter').new {}
	amap('/', function() fm.enabled = true end)

	local tp = snip.two_pane_mode '<S-t>'
	g:map('<S-t>', function() tp.enabled = true end, 'Two-pane mode')
	---@diagnostic disable-next-line: missing-fields
	local sort = require('sai.mode.sort').new {}
	g:map('o', function() sort.enabled = not sort.enabled end, 'Sort mode')
end

-- ## Gallery
do
	local gmap = g

	gmap:map('g', function() sai.mode = 'viewer' end)

	local osize = g.thumb_size
	gmap:map('0', function() g.thumb_size = osize end)
	gmap:map({ 'a', 'h', '<S-UMS>' }, g.go.left)
	gmap:map({ 's', 'j' }, g.go.down)
	gmap:map({ 'w', 'k' }, g.go.up)
	gmap:map({ 'd', 'l', '<S-DMS>' }, g.go.right)
	gmap:map('<C-h>', g.go.first)
	gmap:map('<C-j>', g.go.pgdown)
	gmap:map('<C-k>', g.go.pgup)
	gmap:map('<C-l>', g.go.last)

	gmap:map('<A-s>', 'dragon-drop -x -A %s')
	gmap:map({ ' ', 'm' }, function()
		l.marked:set_current 'toggle'
		g.go.right()
	end)
	gmap:map({ '<S- >', '<S-m>' }, function()
		l.marked:set_current 'toggle'
		g.go.left()
	end)
	local function set_marked_for_all(val)
		local path = g.get_image().path
		g.go.last()
		for _ = l.size, 1, -1 do
			l.marked:set_current(val)
			g.go.left()
		end
		g.go(path)
	end
	gmap:map('<C-a>', function() set_marked_for_all(true) end)
	gmap:map('<C-S-a>', function() set_marked_for_all(false) end)
	gmap:map('<S-Del>', function()
		if sai.exec '$(which trash || echo rm) %m' then
			local marked = l.marked:get()
			for _, f in ipairs(marked) do
				l.remove(f)
			end
		end
	end)

	gmap:map('<LMB>', function()
		local pos = sai.get_mouse_pos()
		g.go(pos.x, pos.y)
	end)
	gmap:map('<2-LMB>', function()
		local pos = sai.get_mouse_pos()
		g.go(pos.x, pos.y)
		sai.mode = 'viewer'
	end)
end

-- ## Slideshow
do
	local function stime(factor)
		-- round to 1/x sec steps
		s.timeout = math[factor < 1 and 'floor' or 'ceil'](s.timeout * factor * 4) / 4
	end

	s:map({ '=', '<S-+>' }, function() stime(6 / 5) end)
	s:map('-', function() stime(5 / 6) end)
end

-- ## Viewer
do
	local vmap = v
	vmap:map('g', function() sai.mode = 'gallery' end)

	vmap:map('m', function() l.marked:set_current 'toggle' end)
	vmap:map('p', snip.cycle_auto_pos, 'Cycle auto pos')

	vmap:map({ '<S- >', '<BS>', 'Left', ',', '<S-h>', '<S-n>' }, v.go.prev)
	vmap:map({ ' ', 'Right', '.', '<S-l>', 'n' }, v.go.next)
	vmap:map('<Home>', v.go.first)
	vmap:map('<End>', v.go.last)

	vmap:map('h', v.pan.left)
	vmap:map('j', v.pan.down)
	vmap:map('k', v.pan.up)
	vmap:map('l', v.pan.right)
	vmap:map('<S-ScrollVertical>', function(ver) v.pan.by(ver * 100, 0) end)

	-- ### Scaling TODO: make a custom mode for it with a searchbar for selection of settings to apply
	vmap:map('s', function()
		v.scale = 'fill'
		v.default_scale = 'fill'
	end)
	vmap:map('<S-s>', function()
		v.scale = 'fit'
		v.default_scale = 'fit'
	end)
	vmap:map('<A-s>', function()
		v.scale = 'optimal'
		v.default_scale = 'optimal'
	end)
	vmap:map('<S-a>', function()
		v.scale = 1
		v.default_scale = 'real'
	end)
	vmap:map('a', function() v.scale = 1 end)
	vmap:map('<A-a>', function()
		local t = { 'keep_width', 'keep_height', 'keep_size', 'keep_fit', 'keep_fill' }
		v.default_scale = snip.cycle_values(t, v.default_scale) or 'keep_width'
	end, "Cycle 'keep' scaling")
	vmap:map('f', function() v.scale = 'fill' end)
	vmap:map('<S-f>', function() v.scale = 'fit' end)
	vmap:map('<S-i>', function()
		v.scale = 0.35
		v.default_scale = 'keep_width'
	end)
	vmap:map('1', function() v.scale = v.get_abs_scale() * 2 end)
	vmap:map('2', function()
		if v.scale == 2 then
			local t = { 'keep_width', 'keep_height', 'keep_size', 'keep_fit', 'keep_fill' }
			v.default_scale = snip.cycle_values(t, v.default_scale) or 'keep_width'
		else
			v.scale = 2
			v.default_scale = 'keep_width'
		end
	end, "2x zoom + 'keep' scaling cycling")
	vmap:map('4', function() v.scale = 4 end)
	vmap:map('5', function() v.scale = 0.5 end)
	vmap:map({ '<Up>', 'i' }, function() v.scale = v.get_abs_scale() * 1.1 end)
	vmap:map({ '<Down>', 'o', '<S-_>' }, function() v.scale = v.get_abs_scale() / 1.1 end)

	vmap:map(
		'<MMB>',
		function() v.scale = ({ [1] = 2, [2] = v.default_scale })[v.get_abs_scale()] or 1 end
	)
end
