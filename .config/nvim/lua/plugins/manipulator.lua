local M = {
	'litoj/manipulator.nvim',
	dependencies = {
		'nvim-treesitter',
		'nvim-treesitter/nvim-treesitter-textobjects',
	},
	event = 'VeryLazy',
}
function M.config()
	local MODS = require 'manipulator.range_mods'
	local m = require 'manipulator'
	m.setup {
		-- debug = 3,
		batch = {
			pick = { picker = 'fzf-lua' },
		},
		region = {
			-- TODO: custom extender, not even fully linewise - opposite of trimmed -> extended?
			select = { linewise_end = '^,?%s*$' },
			current = { rangemod = { MODS.trimmed }, trimm_end = '%s*$' },
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
				},

				lua = {
					select = {
						rangemod = {
							inherit = true,
							function(ts) ---@param ts manipulator.TS
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
	local mts = mcp.ts.current

	map(
		{ '', 'i' },
		'<C-S-/>',
		mts[function(r)
			r:highlight()
			print { type = r:__tostring(), range = r.range, cursor = m.region.current().range }
			vim.defer_fn(function() r:highlight() end, 100)
		end].fn
	)

	local tsq = mts({ on_partial = '.' })['&1'].queue_or_swap['*1']
	map(
		{ 'v' },
		'<A-S-J>', -- TODO: cut&paste, not swap
		mcp.region.queue_or_swap:on_short_motion(function(reg)
			local r = reg.range
			return setmetatable(
				{ buf = 0, range = { r[3] + 1, 0, r[3] + 1, vim.v.maxcol } },
				getmetatable(reg)
			)
		end).queue_or_swap.dot_fn
	)
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

	local tsj = mts({ end_shift_ptn = '[, )]$', src = '.' })['&1'].jump['&$']['*1']:repeatable()
	map({ '', 'i' }, '<C-h>', tsj.prev.fn)
	map({ '', 'i' }, '<C-l>', tsj.next.fn)
	map({ '', 'i' }, '<C-A-h>', tsj:prev('path').fn)
	map({ '', 'i' }, '<C-A-l>', tsj:next('path')['*$']({ end_ = true }).fn)
	map(
		{ '', 'i' },
		'<C-p>',
		tsj
			:collect(mcp(m.ts.class)[MODS.until_new_pos]('parent', false, {
				types = { ['*'] = false, 'declaration$', 'definition$', 'statement$' },
			}))
			:pick({ picker = 'native' }).fn
	)

	local tss_doc = mts['&1']:select('with_docs')['*1']:repeatable()
	map({ '', 'i' }, '<A-s>', tss_doc.fn)
	map({ '', 'i' }, '<A-p>', tss_doc.parent.fn)
	map(
		{ '', 'i' },
		'<A-m>',
		tss_doc:with({ types = { inherit = true, do_statement = false } }):collect('parent'):at(-1).fn
	) -- master node

	map('', ' qa', mts.add_to_qf.fn)
	map('n', ' qo', '<Cmd>copen<CR>')
	map('n', ' qc', '<Cmd>cclose<CR>')
	map('n', ' [Q', '<Cmd>colderCR>')
	map('n', ' ]Q', '<Cmd>cnewerCR>')
	map('n', ' qx', '<Cmd>cexpr ""<CR>')
	map('n', ' qn', '<Cmd>cexpr ""<CR>')
	map('', ' la', mts.add_to_ll.fn)
	map('n', ' lo', '<Cmd>lopen<CR>')
	map('n', ' lc', '<Cmd>lclose<CR>')
	map('n', ' [L', '<Cmd>lolderCR>')
	map('n', ' ]L', '<Cmd>lnewerCR>')
	map('n', ' lx', '<Cmd>lexpr ""<CR>')
	map('n', ' ln', '<Cmd>lexpr ""<CR>')

	local tss = mts['&1'].select['*1']:repeatable()

	map('x', 'J', tss.child('closer_edge').fn)
	map('x', 'K', tss.parent.fn)
	map('x', 'H', tss.prev_sibling.fn)
	map('x', 'L', tss.next_sibling.fn)

	map('x', 'P', tss.parent.fn)
	map('x', 'i', tss.child('closer_edge').fn)
	map('x', 'n', tss.next('path').fn)
	map('x', 'N', tss.prev('path').fn)
	map('x', '<A-n>', tss.next.fn)
	map('x', '<A-S-N>', tss.prev.fn)

	local batch = {
		picked = {
			'n',
			'gt?',
			function(x, cfg)
				return x:collect(mcp():next(cfg), mcp():prev(vim.deepcopy(cfg, true))).pick.fn
			end,
		},
		upper = { 'n', 'gu?', function(x, cfg) return x[MODS.until_new_pos]('parent', false, cfg) end },
		prev = { 'n', { 'gp?' } },
		next = { 'n', { 'gn?' } },
	}
	m.ts.config.presets.last_types = m.ts.config
	local function mapAll(category, types, opts)
		local key = types and category:sub(1, 1) or ''
		local map_j = tsj[function(x)
			m.ts.config.presets.last_types = { types = types }
			return x
		end]
		local cfg = types and types[1] and { types = types } or types or {}
		opts = opts or {}
		for name, a in pairs(batch) do
			local action = m.batch.action_to_fn(a[3] or name, vim.deepcopy(cfg, true))(map_j)
			if type(action) ~= 'function' then action = action.dot_fn end

			opts.desc = ('jump to %s %s'):format(name, category)
			for _, bind in ipairs(type(a[2]) == 'table' and a[2] or { a[2] }) do
				map(a[1], bind:gsub('%?', key), action, opts)
			end
		end
	end
	-- NOTE: dirty workaround to allow filetypes to make their own mappings
	require('plugins.manipulator').mapAll = mapAll

	map({ 'n', 'i' }, '<A-n>', tsj:next('last_types').dot_fn)
	map({ 'n', 'i' }, '<A-S-N>', tsj:prev('last_types').dot_fn)
	mapAll('TS node', nil)
	-- TODO: make this possible (filter captures in direction etc.)
	-- mapAll('function', { query = 'textobjects', types = { 'function.outer' } })
	mapAll('function', {
		'function',
		'arrow_function',
		'function_definition',
		'function_declaration',
		'method_declaration',
	})
	mapAll('call', { 'function_call', 'call_expression', 'return_statement' })
	mapAll('var', { 'variable_declaration', 'parameter_declaration', 'field' })
	mapAll('switch', {
		'if_statement',
		'elseif_statement',
		'else_clause',
		'else_statement',
		'switch_statement',
		'case_statement',
	})
	mapAll('loop', { 'for_statement', 'while_statement', 'do_statement' })

	-- NOTE: overriding default paste behaviour to be better suited for insert mode
	local function paste(after)
		local type = vim.fn.getregtype(vim.v.register)
		if type:sub(1, 1) == '\022' then
			vim.api.nvim_input('"' .. vim.v.register .. (after and 'p' or 'P'))
			return
		end

		local r, is_visual = m.region.current { end_shift_ptn = '' }
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
		r:jump { end_ = type == 'v' and (after or mode == 'n') }
	end
	map({ '', 'i' }, '<C-v>', mcp:new(true)[paste].fn)
	map({ '', 'i' }, '<C-S-V>', mcp:new(false)[paste].fn)
	map('n', '<A-S-V>', '<C-S-V>') -- remap overriden keybind for visual block mode
end
return M
