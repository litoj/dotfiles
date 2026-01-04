local M = { 'litoj/manipulator.nvim', dependencies = 'nvim-treesitter', event = 'VeryLazy' }
function M.config()
	--[[ local sts = require 'syntax-tree-surfer'
	sts.setup {
		highlight_group = 'Search',
		left_hand_side = 'qwertasdfgzxcvb12345QWERTASDFGZXCVB!@#$%',
		right_hand_side = '[poiu\';lkjh/.,mny-0987{POIU":LKJH?><MNY_)(*&',
		icon_dictionary = {
			if_statement = '󰨚',
			else_clause = '󰨚',
			else_statement = '󰨚',
			elseif_statement = '󰨚',
			switch_statement = '󰨚',
			case_statement = '󰨚',
			for_statement = '󰑖',
			while_statement = '󰑖',
			do_statement = '󰑖',
			['function'] = '󰊕',
			function_definition = '󰊕',
			arrow_function = '󰊕',
			variable_declaration = '',
			parameter_declaration = '',
		},
	} ]]

	local MODS = require 'manipulator.range_mods'
	local m = require 'manipulator'
	m.setup {
		-- debug = 3,
		batch = {
			pick = { picker = 'fzf-lua' },
		},
		region = {
			select = { linewise_end = '^,?%s*$' }, -- TODO: custom extender, not even fully linewise - opposite of trimmed -> extended?
			current = { rangemod = { MODS.trimmed }, trimm_end = '%s*$' },
		},
		ts = {
			presets = {
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
	local mts = mcp.ts

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

	map(
		{ '', 'i' },
		'<C-S-/>',
		mts.current[function(r)
			r:highlight()
			print { type = r:__tostring(), range = r.range, cursor = m.region.current().range }
			vim.defer_fn(function() r:highlight() end, 100)
		end].fn
	)

	local tsq = mts({ on_partial = '.' })['&1'].queue_or_swap['*1']
	map(
		{ 'v' },
		'<A-S-J>', -- TODO: cut&paste, not swap
		mcp.region.queue_or_swap:with_count(function(reg)
			local r = reg.range
			return setmetatable(
				{ buf = 0, range = { r[3] + 1, 0, r[3] + 1, vim.v.maxcol } },
				getmetatable(reg)
			)
		end).queue_or_swap.dot_fn
	)
	map({ '', 'i' }, '<A-x>', tsq.fn)
	map({ '', 'i' }, '<A-H>', tsq:queue_or_swap({ hl_group = '' }):with_count('prev_sibling').dot_fn)
	map({ '', 'i' }, '<A-L>', tsq:queue_or_swap({ hl_group = '' }):with_count('next_sibling').dot_fn)

	local tsj =
		mts({ end_shift_ptn = '[, )]$', src = '.' })['&1'].jump['&$']['*1']:with_count 'on_next'
	map({ '', 'i' }, '<C-h>', tsj.prev.fn)
	map({ '', 'i' }, '<C-l>', tsj.next.fn)
	map({ '', 'i' }, '<C-A-h>', tsj:prev('path').fn)
	map({ '', 'i' }, '<C-A-l>', tsj:next('path')['*$']({ end_ = true }).fn)

	local tss_doc = mts['&1']:select('with_docs')['*1']:with_count 'on_next'
	map({ '', 'i' }, '<A-s>', tss_doc.fn)
	map({ '', 'i' }, '<A-p>', tss_doc.parent.fn)
	map(
		{ '', 'i' },
		'<C-p>',
		tss_doc
			:collect(
				mcp
					:new(m.ts.class)
					:parent { types = { ['*'] = false, 'declaration$', 'definition$', 'statement$' } }
			)
			:reverse()
			:pick({ picker = 'native' }).fn
	)
	map(
		{ '', 'i' },
		'<A-m>',
		tss_doc:with({ types = { inherit = true, do_statement = false } }):collect('parent'):at(-1).fn
	) -- master node

	local tss = mts['&1'].select['*1']:with_count 'on_next'

	map('x', 'J', tss:child('closer_edge').fn)
	map('x', 'K', tss.parent.fn)
	map('x', 'H', tss.prev_sibling.fn)
	map('x', 'L', tss.next_sibling.fn)

	map('x', 'P', tss.parent.fn)
	map('x', 'i', tss:child('closer_edge').fn)
	-- TODO: add fallback selector for largest non-space object
	map('x', 'n', tss.next('path').fn)
	map('x', 'N', tss.prev('path').fn)
	map('x', '<A-n>', tss.next.fn)
	map('x', '<A-N>', tss.prev.fn)

	m.ts.config.presets.last_types = m.ts.config
	local function mapAll(key, dst, opts)
		opts = type(opts) == 'string' and { desc = opts } or opts
		local cfg = { types = dst, save_as = 'last_types' }
		map('n', 'gt' .. key, tsj:collect(mcp():next(cfg), mcp():prev(cfg)).pick.fn, opts)
		-- map('n', 'gt' .. key, tsj.get_all(cfg).pick.fn, opts)
		map('n', 'gp' .. key, tsj:parent(cfg).fn, opts)
		map('n', '[' .. key, tsj:prev(cfg).dot_fn, opts)
		map('n', ']' .. key, tsj:next(cfg).dot_fn, opts)
	end
	-- NOTE: dirty workaround to allow filetypes to make their own mappings
	require('plugins.manipulator').mapAll = mapAll

	map({ 'n', 'i' }, '<A-n>', tsj:next('last_types').dot_fn)
	map({ 'n', 'i' }, '<A-S-N>', tsj:prev('last_types').dot_fn)
	mapAll('f', {
		'function',
		'arrow_function',
		'function_definition',
		'function_declaration',
		'method_declaration',
	}, 'jump to functions')
	mapAll('c', { 'function_call', 'call_expression', 'return_statement' })
	mapAll('v', { 'variable_declaration', 'parameter_declaration', 'field' })
	mapAll('s', {
		'if_statement',
		'elseif_statement',
		'else_clause',
		'else_statement',
		'switch_statement',
		'case_statement',
	}, 'jump to switches / conditionals')
	mapAll('l', { 'for_statement', 'while_statement', 'do_statement' }, 'jump to loops')
end
return M
