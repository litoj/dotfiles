return function(onetimetbl)
	local activeBuf = vim.api.nvim_get_current_buf()
	local bufmap = function(mode, from, to, opts)
		local def = { buffer = activeBuf }
		_G.map(mode, from, to, opts and vim.tbl_extend('force', def, opts) or def)
	end

	if not onetimetbl then return bufmap end
	local ft = onetimetbl[1]
	if type(ft) == 'string' then
		onetimetbl[1] = onetimetbl[2]
		onetimetbl[2] = nil
	end
	local tbl = vim.g.loaded or {}
	if tbl[ft] then return bufmap end
	tbl[ft] = true
	vim.g.loaded = tbl -- types are converted from native format -> convert modified copy back

	for k, v in pairs(onetimetbl) do
		if k == 1 then
			v(function(mode, from, to, opts)
				local def = { buffer = true }
				_G.map(mode, from, to, opts and vim.tbl_extend('force', def, opts) or def)
			end)
		else
			withMod(k, v)
		end
	end
	return bufmap
end
