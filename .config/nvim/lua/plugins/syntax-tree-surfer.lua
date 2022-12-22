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
	map({ 'n', 'i' }, '<C-S-H>', '<Cmd>STSSwapCurrentNodePrevNormal<CR>', opt)
	map({ 'n', 'i' }, '<M-J>', '<Cmd>STSSwapDownNormal<CR>', opt)
	map({ 'n', 'i' }, '<M-K>', '<Cmd>STSSwapUpNormal<CR>', opt)
	map({ 'n', 'i' }, '<C-S-L>', '<Cmd>STSSwapCurrentNodeNextNormal<CR>', opt)
	map('n', 'gh', '<Cmd>STSSwapOrHold<CR>', opt)
	map('n', '<M-s>', '<Cmd>STSSelectCurrentNode<CR>', opt)
	map('i', '<M-s>', '<C-o><Cmd>STSSelectCurrentNode<CR>', opt)
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
	map({ 'n', 'i' }, '<M-n>', function() sts.filtered_jump(last, true) end)
	map({ 'n', 'i' }, '<M-N>', function() sts.filtered_jump(last, false) end)
	local function mapAll(key, dst)
		map('n', 'g' .. key, list(dst))
		map('n', '<' .. key, goTo(dst, false, { destination = 'parent' }))
		map('n', '>' .. key, goTo(dst, true, { destination = 'children' }))
		map('n', '{' .. key, goTo(dst, false, { destination = 'siblings' }))
		map('n', '}' .. key, goTo(dst, true, { destination = 'siblings' }))
		map('n', '[' .. key, goTo(dst, false))
		map('n', ']' .. key, goTo(dst, true))
	end
	mapAll('f', { 'function', 'arrow_function', 'function_definition' })
	mapAll('s', {
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
