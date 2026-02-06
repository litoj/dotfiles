local M = {}

function _G.exists(f)
	---@diagnostic disable-next-line: param-type-mismatch
	f = io.open(f)
	if f then f:close() end
	return f ~= nil
end

---@param dir? string defaults to buf parent dir
function M.findUpFile(dir, luapat)
	return vim.fs.find(
		function(fname) return not not fname:find(luapat) end,
		{ path = dir or vim.api.nvim_buf_get_name(0):match '.+/', upward = true }
	)[1]
end

--- Find dir matching the luapat (if luapat ends with /)
--- or get dir of file `name` (if name is not a luapat or doesn't end with /)
---@param basedir? string defaults to buf parent dir
function M.findDir(basedir, name)
	basedir = basedir or vim.api.nvim_buf_get_name(0):match '.+/'
	if name:match '[^./%w_-]' then -- luapat
		basedir = M.findUpFile(basedir, name)
		if name:sub(-1) == '/' then return basedir end
		return basedir and basedir:match '.+/'
	end

	while not exists(basedir .. name) do
		basedir = basedir:gsub('[^/]+/$', '')
		if basedir == '/' then return end
	end
	return basedir
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
