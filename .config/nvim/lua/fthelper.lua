---@alias map fun(mode:string|string[],bind:string,action:string|function,opts?:vim.keymap.set.Opts)
---@alias onetimetbl {[string]:fun(mod:{})}

local function modmap(modtbl)
	for k, v in pairs(modtbl) do
		withMod(k, v)
	end
end

local loaded = {}

---@param onetimetbl? onetimetbl
---@return map map with buffer bound to the current buffer
---@return fun(modtbl) modmap
return function(onetimetbl)
	local activeBuf = vim.api.nvim_get_current_buf()
	local bufmap = function(mode, from, to, opts)
		local def = { buffer = activeBuf }
		opts = opts and vim.tbl_extend('force', def, opts) or def
		_G.map(mode, from, to, opts)
	end

	local ft = vim.bo.ft
	if onetimetbl and not loaded[ft] then
		loaded[ft] = true
		modmap(onetimetbl, activeBuf)
	end

	return bufmap, modmap
end
