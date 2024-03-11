local M = { 'ziontee113/syntax-tree-surfer', dependencies = 'nvim-treesitter', event = 'VeryLazy' }
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
	local opt = { silent = true }
	map({ 'n', 'i' }, '<A-S>', '<Cmd>STSSwapOrHold<CR>', opt)

	map({ 'n', 'i' }, '<C-S-H>', '<Cmd>STSSwapCurrentNodePrevNormal<CR>', opt)
	map({ 'n', 'i' }, '<A-L>', '<Cmd>STSSwapDownNormal<CR>', opt)
	map({ 'n', 'i' }, '<A-H>', '<Cmd>STSSwapUpNormal<CR>', opt)
	map({ 'n', 'i' }, '<C-S-L>', '<Cmd>STSSwapCurrentNodeNextNormal<CR>', opt)

	map('x', '<A-J>', '<Cmd>STSSwapNextVisual<CR>', opt)
	map('x', '<A-K>', '<Cmd>STSSwapPrevVisual<CR>', opt)

	map('n', '<A-s>', '<Cmd>STSSelectCurrentNode<CR>', opt)
	map('i', '<A-s>', '<C-o><Cmd>STSSelectCurrentNode<CR>', opt)

	map('x', 'H', '<Cmd>STSSelectPrevSiblingNode<CR>', opt)
	map('x', 'J', '<Cmd>STSSelectChildNode<CR>', opt)
	map('x', 'K', '<Cmd>STSSelectParentNode<CR>', opt)
	map('x', 'L', '<Cmd>STSSelectNextSiblingNode<CR>', opt)

	map('x', 'N', '<Cmd>STSSelectPrevSiblingNode<CR>', opt)
	map('x', 'C', '<Cmd>STSSelectChildNode<CR>', opt)
	map('x', 'P', '<Cmd>STSSelectParentNode<CR>', opt)
	map('x', 'n', '<Cmd>STSSelectNextSiblingNode<CR>', opt)

	local last = 'default'
	local function list(dst)
		return function()
			last = dst
			sts.targeted_jump(dst)
		end
	end
	map('n', 'gv', list { 'variable_declaration', 'parameter_declaration' })
	map('n', 'ge', list { 'function_call', 'call_expression' }) -- execution
	local function goTo(dst, fwd, opts)
		return function()
			last = dst
			sts.filtered_jump(dst, fwd, opts)
		end
	end
	map({ 'n', 'i' }, '<A-n>', function() sts.filtered_jump(last, true) end)
	map({ 'n', 'i' }, '<A-N>', function() sts.filtered_jump(last, false) end)
	local function mapAll(key, dst)
		map('n', 'g' .. key, list(dst))
		map('n', '[' .. key, goTo(dst, false))
		map('n', ']' .. key, goTo(dst, true))
		map('n', '<' .. key, goTo(dst, false, { destination = 'parent' }))
		map('n', '>' .. key, goTo(dst, true, { destination = 'children' }))
		map('n', '{' .. key, goTo(dst, false, { destination = 'siblings' }))
		map('n', '}' .. key, goTo(dst, true, { destination = 'siblings' }))
	end
	mapAll('f', { 'function', 'arrow_function', 'function_definition', 'method_declaration' })
	mapAll('i', {
		'if_statement',
		'elseif_statement',
		'else_clause',
		'else_statement',
		'switch_statement',
		'case_statement',
	})
	mapAll('l', { 'for_statement', 'while_statement', 'do_statement' })
end
return M
