---@class helpers
local M = {}

local key_map = {
	BS = 'BackSpace',
	Del = 'Delete',
	Esc = 'Escape',
	CR = 'Enter',
	[','] = 'comma',
	['.'] = 'period',
	['`'] = 'grave',
	['~'] = 'asciitilde',
	[' '] = 'space',
	['+'] = 'plus',
	['-'] = 'minus',
	['='] = 'equal',
}
for _, v in ipairs { 'Middle', 'Left', 'Right' } do
	key_map[v:sub(1, 1) .. 'MB'] = 'Mouse' .. v
end
for _, v in ipairs { 'Left', 'Right', 'Up', 'Down' } do
	key_map['SM' .. v:sub(1, 1)] = 'Scroll' .. v
end
local function transform_key(bind)
	if bind:match '^<.+>$' then bind = bind:sub(2, -2) end
	bind = bind:gsub('[AM][+-]', 'Alt+', 1):gsub('S[+-]', 'Shift+', 1):gsub('C[+-]', 'Ctrl+', 1)

	if bind:match 'Shift%+Tab$' then
		bind = bind:gsub('Shift%+Tab$', 'Shift+ISO_Left_Tab')
	else
		local key = bind:match '[^+-]*.$'
		bind = bind:sub(1, -#key - 1) .. (key_map[key] or key)
	end
	return bind
end

---@param bind string|string[]
---@param cb string|function shellcmd to execute or callback
function M.map(api, bind, cb)
	if type(cb) == 'string' then
		local cmd = cb
		cb = function() swi.exec(cmd) end
	end

	for _, b in ipairs(type(bind) == 'table' and bind or { bind }) do
		api.map(transform_key(b), cb)
	end
end

---@param img_meta table<string,string>
---@param val string name/path of the exif value to get (defaults to `Exif.Photo.<>` path)
---@return string?
function M.format_exif(img_meta, val)
	if val and val:match '%.' then
		val = img_meta[val]
	else
		val = img_meta['Exif.Photo.' .. val]
	end
	if not val then return end

	local a, b = val:match '^(%-?[0-9]+)/([0-9]+)$'
	if a then
		local x, y = tonumber(a), tonumber(b)
		local n = x / y
		if math.floor(n) == n then -- integer, not rational number -> done
			---@diagnostic disable-next-line: cast-local-type
			val = n
		elseif math.floor(n * 10) == n * 10 then -- print just 1 decimal point
			val = string.format('%.1f', n)
		elseif b:match '^10*$' then -- just a decimal point offset
			val = string.format('%.2f', n)
		elseif a:match '^10*$' then -- decimal point offset through the other side
			val = string.format('1/%d', y / x)
		end
	end

	return val
end

return M
