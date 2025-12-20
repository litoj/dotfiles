local M = { 'litoj/manipulator.nvim', dependencies = 'nvim-treesitter', event = 'VeryLazy' }
function M.config()
	require('manipulator').setup()
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

	local mcp = require 'manipulator.call_path'
	local mts = mcp.tsregion

	local tsq = mts({ v_partial = 0 }).queue_or_run
	map({ '', 'i' }, '<A-x>', tsq({ cursor_with = 'dst' }).fn)
	map({ '', 'i' }, '<A-H>', tsq.prev.queue_or_run.fn)
	map({ '', 'i' }, '<A-L>', tsq.next.queue_or_run.fn)

	local tsj = mts({ insert_fixer = '[, )]' })['&1'].jump['&$']['*1']:next_with_count 'fallback'
	map({ '', 'i' }, '<C-h>', tsj.prev_in_graph.fn)
	map({ '', 'i' }, '<C-l>', tsj.next_in_graph.fn)
	map({ '', 'i' }, '<C-A-H>', tsj.prev('path').fn)
	map({ '', 'i' }, '<C-A-L>', tsj.next('path')['*$']({ end_ = true }).fn)

	local tss = mts['&1'].select['*1']:next_with_count 'fallback'
	map({ '', 'i' }, '<A-s>', tss.fn)
	-- equiv to function() ts.current():parent():select() end
	map({ '', 'i' }, '<A-p>', tss.parent.fn)

	map('x', 'H', tss.prev.fn)
	map('x', 'J', tss.closer_edge_child.fn)
	map('x', 'K', tss.parent.fn)
	map('x', 'L', tss.next.fn)

	map('x', 'P', tss.parent.fn)
	map('x', 'i', tss.closer_edge_child.fn)
	-- TODO: add fallback selector for largest non-space object
	map('x', ',', tss.closer_edge_child.fn)
	map('x', '.', tss.parent.fn)
	map('x', 'n', tss.next('path').fn)
	map('x', 'N', tss.prev('path').fn)
	map('x', '<A-n>', tss.next_in_graph.fn)
	map('x', '<A-N>', tss.prev_in_graph.fn)

	local root = tsj.get_all
	local function mapAll(key, dst, opts)
		opts = opts and { desc = opts }
		map('n', 'gt' .. key, root({ types = dst }):pick({ picker = 'fzf-lua' }).fn, opts)
		map('n', '[' .. key, tsj:prev_in_graph({ types = dst }).fn, opts)
		map('n', ']' .. key, tsj:next_in_graph({ types = dst }).fn, opts)
	end
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
