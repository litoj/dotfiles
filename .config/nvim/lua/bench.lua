---@generic A:any[]
---@param cfg {iterations?:integer, duration?:number, warmup_s?:number, args?:A|fun(i:integer):(A), methods?:table<string,fun(...:A):...?>, return_results?:boolean}
function _G.bench(cfg)
	local gen = type(cfg.args) == 'function' and cfg.args
		or (cfg.args and function() return cfg.args end or function() return {} end)
	local methods = cfg.methods

	local iterations = cfg.iterations
	local dur = cfg.duration or (not iterations and 5 / #vim.tbl_keys(methods))
	cfg.warmup_s = cfg.warmup_s or 1

	local results = {}
	local s = os.time()

	local i = 0
	while os.time() - s < cfg.warmup_s do
		local args = gen(i)
		for _, f in ipairs(methods) do
			f(unpack(args))
		end
		i = i + 1
	end

	for name, fn in pairs(methods) do
		if iterations then
			s = os.clock()

			for i = 1, iterations do
				fn(unpack(gen(i)))
			end

			results[name] = (os.clock() - s)*1000
		elseif dur then
			local i = 1
			s = os.time()

			while os.time() - s < dur do
				fn(unpack(gen(i)))
				i = i + 1
			end

			results[name] = i - 1
		end
	end

	if cfg.return_results then
		return results
	else
		local log = {}
		local length, max, extreme = 0, 0, iterations and math.huge or 0
		for name, result in pairs(results) do
			name = tostring(name)
			if #name > length then length = #name end
			if result > max then max = result end
			if iterations then
				if result < extreme then extreme = result end
			else
				if result > extreme then extreme = result end
			end
		end
		local num_len = math.floor(math.log10(max)) + 1

		local fmt = '%'
			.. length
			.. 's | %'
			.. (iterations and (tostring(num_len) .. 'd ms') or (tostring(num_len) .. 'd runs'))
			.. ' | %6.2f%% perf'

		for name, result in pairs(results) do
			log[#log + 1] = string.format(
				fmt,
				name,
				result,
				100 * (iterations and extreme / result or result / extreme)
			)
		end
		table.sort(log)
		vim.notify(table.concat(log, '\n'), vim.log.levels.INFO)
	end
end
return _G.bench
