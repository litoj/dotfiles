local M = { 'litoj/syntax-tree-surfer', dependencies = 'nvim-treesitter', event = 'VeryLazy' }
function M.config()
	local sts = require 'syntax-tree-surfer'
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
	}

	local mts = require 'manipulator.ts'
	local mn = require 'manipulator.manipulate'
	map({ 'n', 'i' }, '<A-S>', '<Cmd>STSSwapOrHold<CR>')

	map({ 'n', 'i' }, '<A-L>', '<Cmd>STSSwapDownNormal<CR>')
	map({ 'n', 'i' }, '<A-H>', '<Cmd>STSSwapUpNormal<CR>')
	map({ '', 'i' }, '<C-S-H>', function()
		local cur = mts.current { v_partial = 0 }
		cur:move { dst = cur:prev() }
	end)
	map({ '', 'i' }, '<C-S-L>', function()
		local cur = mts.current { v_partial = 0 }
		cur:move { dst = cur:next() }
	end)
	-- TODO: when working well make this into <C-l>
	map({ '', 'i' }, '<C-A-L>', function() mts.current({ v_modes = {} }):next():jump(true) end)
	-- TODO: why does this always jump up
	map({ '', 'i' }, '<C-A-H>', function() mts.current({ v_modes = {} }):prev():jump() end)

	map('x', '<A-J>', '<Cmd>STSSwapNextVisual<CR>')
	map('x', '<A-K>', '<Cmd>STSSwapPrevVisual<CR>')

	map({ '', 'i' }, '<A-s>', function() mts.current({ v_modes = { v = true } }):select(true) end)
	map({ '', 'i' }, '<A-p>', function() mts.current():parent():select() end)

	map('x', 'H', '<Cmd>STSSelectPrevSiblingNode<CR>')
	map('x', 'J', '<Cmd>STSSelectChildNode<CR>')
	map('x', 'K', '<Cmd>STSSelectParentNode<CR>')
	map('x', 'L', '<Cmd>STSSelectNextSiblingNode<CR>')

	map('x', 'P', function() mts.current():parent():select() end)
	map('x', 'i', function() mts.current():closer_edge_child():select() end)
	-- TODO: add fallback selector for largest non-space object
	map('x', ',', function() mts.current():closer_edge_child():select() end)
	map('x', '.', function() mts.current():parent():select() end)
	map('x', 'n', function() mts.current():next('path'):select() end)
	map('x', 'N', function() mts.current():prev('path'):select() end)

	local last = {}
	local function list(dst)
		return function()
			last = dst
			sts.fzf_jump(dst)
		end
	end
	map('n', 'gtv', list { 'variable_declaration', 'parameter_declaration', 'field' })
	map('n', 'gtc', list { 'function_call', 'call_expression', 'return_statement' })
	local function goTo(dst, fwd, s)
		return function()
			last = dst
			sts.filtered_jump(dst, fwd, s)
		end
	end
	-- jumps of the same kind as the previous one we used
	map('n', 'gtt', function() sts.fzf_jump(last) end)
	map({ 'n', 'i' }, '<A-n>', function() sts.filtered_jump(last, true) end)
	map({ 'n', 'i' }, '<A-N>', function() sts.filtered_jump(last, false) end)
	local function mapAll(key, dst, opts)
		opts = opts and { desc = opts }
		map('n', 'gt' .. key, list(dst), opts)
		map('n', '[' .. key, goTo(dst, false), opts)
		map('n', ']' .. key, goTo(dst, true), opts)
	end
	sts.list = list
	sts.goTo = goTo
	sts.mapAll = mapAll
	mapAll('f', {
		'function',
		'arrow_function', --[[ 'function_definition', ]]
		'method_declaration',
	}, 'jump to functions')
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
