local M = {}

function _G.exists(f)
	---@diagnostic disable-next-line: param-type-mismatch
	f = io.open(f)
	if f then f:close() end
	return f ~= nil
end

---@param dir? string defaults to buf parent dir
function M.findUpFile(luapat, dir, allow_home)
	dir = dir or vim.api.nvim_buf_get_name(0):match '.+/'

	local file = true
	if luapat:sub(-1) == '/' then
		luapat = luapat:sub(1, -2)
		file = false
	end

	dir = dir:gsub('/+$', '')
	local end_at = not allow_home and os.getenv 'HOME'
	while dir and dir ~= end_at do
		for name, type in vim.fs.dir(dir) do
			if file == (type == 'file') and name:find(luapat) then return dir .. '/' .. name end
		end

		dir = dir:match '^(.*)/'
	end
end

--- Find dir containing the given file matched by luapat
--- (use '.*/' to get a directory that contains other directories)
---@param basedir? string defaults to buf parent dir
function M.findDirOf(luapat, basedir)
	basedir = basedir or vim.api.nvim_buf_get_name(0):match '.+/'

	basedir = M.findUpFile(luapat, basedir)
	return basedir and basedir:match '.+/'
end

---@return string[]
function M.glob(glob)
	local ret = vim.split(vim.fn.glob(glob), '\n', { plain = true })
	if ret[1] == '' then return {} end
	return ret
end

---@alias map fun(mode:string|string[],bind:string,action:string|function,opts?:vim.keymap.set.Opts)
---@alias modtbl {[string]:fun(mod:{}, buf:integer)}
do
	local function modmap(modtbl)
		local buf = vim.api.nvim_get_current_buf()
		for k, v in pairs(modtbl) do
			M.withMod(k, v, buf)
		end
	end

	local loaded = {}

	---@param onetimetbl? modtbl
	---@return map map with buffer bound to the current buffer
	---@return fun(modtbl:modtbl) modmap
	function M.once(onetimetbl)
		local activeBuf = vim.api.nvim_get_current_buf()
		local bufmap = function(mode, from, to, opts)
			local def = { buffer = activeBuf }
			opts = opts and vim.tbl_extend('force', def, opts) or def
			_G.map(mode, from, to, opts)
		end

		local ft = vim.bo.ft
		if onetimetbl and not loaded[ft] then
			loaded[ft] = true
			modmap(onetimetbl)
		end

		return bufmap, modmap
	end
end

function M.withMod(mod, cb, ...)
	if package.loaded[mod] then return cb(package.loaded[mod], ...) end
	local old = package.preload[mod]
	local args = { ... }
	package.preload[mod] = function()
		package.preload[mod] = nil
		if old then
			old()
		else
			package.loaded[mod] = nil
			package.loaded[mod] = package.loaders[2](mod)()
		end
		vim.schedule(function() cb(package.loaded[mod], unpack(args)) end)
	end
end

return M
