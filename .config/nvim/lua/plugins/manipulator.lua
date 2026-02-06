local M = {
	'litoj/manipulator.nvim',
	dependencies = {
		'nvim-treesitter',
		'nvim-treesitter/nvim-treesitter-textobjects',
	},
	event = 'VeryLazy',
}
function M.config()
	local RM = require 'manipulator.range_mods'
	local m = require 'manipulator'
	m.setup { -- TODO: make input window repeatable (macro renaming)
		-- debug = 3,
		batch = {
			pick = { picker = 'fzf-lua' },
		},
		region = {
			-- TODO: custom extender, not even fully linewise - opposite of trimmed -> extended?
			select = { linewise_end = '^,?%s*$' },
			current = {
				rangemod = { RM.pos_shift, RM.trimmed },
				trimm_end = '%s*$',
				shift_modes = { i = true, n = true },
				shift_by_luapat = '^%s+',
			},
		},
		ts = {
			presets = { -- TODO: create MOD for lookahead+lookbehind
				with_docs = {
					types = {
						inherit = 'with_docs',
						'^if_',
						'^else_',
						'^case_',
						'^while_',
						'^for_',
					},
					next_sibling = {
						types = {
							'comment',
						},
					},
				},

				lua = {
					select = {
						rangemod = {
							inherit = true,
							[5] = function(ts) ---@param ts manipulator.TS
								if
									ts.node
									and ts.node:type() == 'assignment_statement'
									and ts.node:parent():type() == 'variable_declaration'
								then
									return ts:parent().range
								end
								return ts.range
							end,
						},
					},
				},
			},
		},
	}

	local mcp = m.call_path
	local ctc = mcp.ts.current -- callpath ts current

	map(
		{ '', 'i' },
		'<C-S-/>',
		ctc[function(r)
			r:highlight()
			print { type = r:__tostring(), range = r.range, cursor = m.region.current().range }
			vim.defer_fn(function() r:highlight() end, 100)
		end].fn
	)

	local tsq = ctc({ on_partial = '.' })['&1'].queue_or_swap['*1']
	--[[ map(
		{ 'v' },
		'<A-S-J>', -- TODO: cut&paste, not swap
		mcp.region.queue_or_swap:on_short_motion(function(reg)
			local r = reg.range
			return setmetatable(
				{ buf = 0, range = { r[3] + 1, 0, r[3] + 1, vim.v.maxcol } },
				getmetatable(reg)
			)
		end).queue_or_swap.dot_fn
	) ]]
	map({ '', 'i' }, '<A-x>', tsq.fn)
	map(
		{ '', 'i' },
		'<A-S-H>',
		tsq:queue_or_swap({ hl_group = '' }):repeatable('prev_sibling').dot_fn
	)
	map(
		{ '', 'i' },
		'<A-S-L>',
		tsq:queue_or_swap({ hl_group = '' }):repeatable('next_sibling').dot_fn
	)

	local tsj = ctc({ end_shift_ptn = '[, )]$', src = '.' })['&1'].jump['&$']['*1']:repeatable()
	map({ '', 'i' }, '<C-S-H>', tsj.prev.fn)
	map({ '', 'i' }, '<C-S-L>', tsj.next.fn)
	map({ '', 'i' }, '<C-A-h>', tsj:prev('path').fn)
	map({ '', 'i' }, '<C-A-l>', tsj:next('path')['*$']({ end_ = true }).fn)
	map(
		{ '', 'i' },
		'<C-p>',
		tsj
			:collect(mcp(m.ts.class)[RM.until_new_pos]('parent', false, {
				types = { ['*'] = false, 'declaration$', 'definition$', 'statement$' },
			}))
			:pick({ picker = 'native' }).fn
	)

	local tss_doc = ctc['&1']:select('with_docs')['*1']:repeatable()
	map({ '', 'i' }, '<A-s>', tss_doc.fn)
	map({ '', 'i' }, '<A-p>', tss_doc.parent.fn)
	map(
		{ '', 'i' },
		'<A-m>',
		tss_doc:with({ types = { inherit = true, do_statement = false } }):collect('parent'):at(-1).fn
	) -- master node

	map('', ' qa', ctc.add_to_qf.fn)
	map('n', ' qo', '<Cmd>copen<CR>')
	map('n', ' qc', '<Cmd>cclose<CR>')
	map('n', '[Q', '<Cmd>colderCR>')
	map('n', ']Q', '<Cmd>cnewerCR>')
	map('n', ' qx', '<Cmd>cexpr ""<CR>')
	map('n', ' qn', '<Cmd>cexpr ""<CR>')
	map('', ' la', ctc.add_to_ll.fn)
	map('n', ' lo', '<Cmd>lopen<CR>')
	map('n', ' lc', '<Cmd>lclose<CR>')
	map('n', '[L', '<Cmd>lolderCR>')
	map('n', ']L', '<Cmd>lnewerCR>')
	map('n', ' lx', '<Cmd>lexpr ""<CR>')
	map('n', ' ln', '<Cmd>lexpr ""<CR>')

	local tss = ctc['&1'].select['*1']:repeatable()

	map({ 'x', 'o' }, 'J', tss.child('closer_edge').fn)
	map({ 'x', 'o' }, 'K', tss.parent.fn)
	map({ 'x', 'o' }, 'H', tss.prev_sibling.fn)
	map({ 'x', 'o' }, 'L', tss.next_sibling.fn)

	map({ 'x', 'o' }, 'P', tss.parent.fn)
	map('', '<A-n>', tss.next('path').fn)
	map('', '<A-S-N>', tss.prev('path').fn)

	local opj = tsj:new(nil, { call = { on_no_fn = 'extend-prev' } })
	local operators = {
		{
			lhs = function(m, c) return (m:match '[%[%]]' and '' or 'g') .. m .. c end,
			rhs = opj,
			desc = 'jump to',
			map_as = 'dot_fn',
		},
		{
			lhs = function(m, c) return m:match '[%[%]]' and (m .. c:upper()) or ('g' .. m:upper() .. c) end,
			rhs = opj['&1']['*$']({ end_ = true })['*1'],
			desc = 'jump to end of',
			map_as = 'dot_fn',
		},
		select = {
			mode = { 'o', 'x' },
			lhs = function(m, c) return m:match '[^%[%]]' and '' .. m .. c end, -- no ''/[/]
			rhs = tss,
		},
	}
	local moves = {
		picked = {
			lhs = 't',
			rhs = function(x, cfg)
				return x:collect(mcp():next(cfg), mcp():prev(vim.deepcopy(cfg, true))).pick.fn
			end,
		},
		upper = { rhs = function(x, cfg) return x[RM.until_new_pos]('parent', false, cfg) end },
		prev = { lhs = { '[', 'p' } },
		next = { lhs = { ']', 'n' } },
		active = { rhs = function(x, cfg) return x(cfg) end },
		inner = { rhs = function(x, cfg) return x(cfg):child { types = { 'block', 'chunk' } } end },
	}
	m.ts.config.presets.last_types = m.ts.config
	local function mapAll(c_name, mapper_cfg_or_types, map_opts)
		local cat = mapper_cfg_or_types
		if cat[1] then cat = { opts = { types = cat } } end

		local function fill_info(name, x)
			x.lhs = x.lhs or name:sub(1, 1)
			x.rhs = x.rhs or name
			x.desc = x.desc or name
		end

		fill_info(c_name, cat)
		if type(cat.opts) == 'table' and cat.opts.save_as ~= false then
			cat.opts.save_as = 'last_types'
		end
		map_opts = type(map_opts) == 'table' and map_opts or { desc = map_opts }

		for o_name, op in pairs(operators) do
			fill_info(o_name, op)

			-- operator can filter which mappings will get created and which won't
			local lhs = type(op.lhs) == 'function' and op.lhs
				or function(m, c) return op.lhs .. m .. c end

			for m_name, move in pairs(moves) do
				fill_info(m_name, move)

				local rhs = m.batch.action_to_fn(move.rhs, vim.deepcopy(cat.opts, true))(op.rhs)
				if type(rhs) ~= 'function' then rhs = rhs[op.map_as or 'fn'] end

				for _, m_lhs in ipairs(type(move.lhs) == 'table' and move.lhs or { move.lhs }) do
					local lhs = lhs(m_lhs, cat.lhs)
					if lhs then
						map_opts.desc = ('%s %s %s'):format(op.desc, move.desc, cat.desc)
						map(op.mode or '', lhs, rhs, map_opts)
					end
				end
			end
		end
	end
	-- NOTE: dirty workaround to allow filetypes to make their own mappings
	require('plugins.manipulator').mapAll = mapAll

	mapAll('saved node', { opts = 'last_types' })
	mapAll('node', { opts = { save_as = false } })
	mapAll('function', { opts = { query = 'textobjects', types = { 'function.outer' } } })
	mapAll('parameter', { opts = { query = 'textobjects', types = { 'parameter.inner' } } })
	mapAll('var', { '^variable_de', '^parameter_de' })
	mapAll('assignment', { 'assignment_statement' })
	mapAll('condition', { '^if', '^else', '^switch', '^case' })
	mapAll('loop', { '^for', '^while', 'do_statement' })

	-- overriding default paste behaviour to be better suited for insert mode
	local function paste(after)
		local type = vim.fn.getregtype(vim.v.register)
		if type:sub(1, 1) == '\022' then
			vim.api.nvim_input('"' .. vim.v.register .. (after and 'p' or 'P'))
			return
		end

		local r, is_visual = m.region.current { shift_mode = false }
		local mode = vim.fn.mode()
		local text = vim.fn.getreg(vim.v.register)
		if type == 'v' and text:sub(#text) == '\n' then type = 'V' end
		if type == 'V' then text = text:gsub('\n$', '') end

		if is_visual then
			r:set_reg { register = 'd', type = type }
			vim.api.nvim_feedkeys('\027', 'n', false)
			if mode == 'v' then r = r:paste { text = '' } end
		else
			r.range[3] = vim.fn.foldclosedend '.' - 1
			if r.range[3] < 0 then
				r.range[3] = r.range[1]
			else
				r.range[1] = r.range[3]
			end
		end

		r = r:paste {
			text = text,
			linewise = type == 'V',
			mode = mode == 'V' and 'over' or (after and 'after' or 'before'),
		}
		r:jump { inherit = false, end_ = type == 'v' and (after or mode == 'n') }
	end
	map({ '', 'i' }, '<C-v>', mcp:new(true)[paste].fn)
	map('i', '<C-S-V>', mcp:new(false)[paste].fn)
end
return M
