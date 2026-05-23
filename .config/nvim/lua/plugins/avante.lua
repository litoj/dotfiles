if vim.g.features_level < 7 then return {} end
local M = {
	'yetone/avante.nvim',
	keys = ' a',
	build = 'make',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
		{
			'zbirenbaum/copilot.lua',
			enabled = false,
			opts = {
				panel = { enabled = false },
				suggestion = {
					enabled = false,
					keymap = {
						accept = false,
						dismiss = false,
						next = false,
						prev = false,
					},
				},
				filetypes = {
					['*'] = false,
					-- c = true,
					-- cpp = true,
					cs = true,
					javascript = true,
					javascriptreact = true,
					-- lua = true,
					python = true,
					-- sh = true,
					typescript = true,
					typescriptreact = true,
					vue = true,
				},
			},
		},
	},
}

---Returns the first visible, modifiable, named buffer in a non-floating window.
---@return integer
---@return string
local function get_real_active_buf()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_config(win).relative == '' then
			local buf = vim.api.nvim_win_get_buf(win)
			if
				vim.bo[buf].buftype == 'terminal'
				or (
					vim.bo[buf].modifiable
					and vim.bo[buf].buftype == ''
					and vim.api.nvim_buf_get_name(buf) ~= ''
				)
			then
				return buf,
					---@diagnostic disable-next-line: redundant-return-value
					vim.api
						.nvim_buf_get_name(buf)
						:gsub('^term://(.+/)/%d+:.*$', '%1', 1)
						:gsub('^~', os.getenv 'HOME', 1)
			end
		end
	end
	error 'No valid buffer in current tab'
end

function M.config()
	local a = require 'avante'

	local old = require('avante.sidebar').show_input_hint
	require('avante.sidebar').show_input_hint = function(self)
		if vim.fn.mode() == 'n' then return old(self) end
		self:close_input_hint() -- Close the existing hint window
	end

	local aview = require 'avante.llm_tools.view'
	aview.enabled = nil
	local Helpers = require 'avante.llm_tools.helpers'
	local Utils = require 'avante.utils'
	aview.description = [[Reads the content of the given file in the project.

IMPORTANT NOTES:
- If the file content exceeds a certain size, the returned content will be truncated, and `is_truncated` will be set to true. If `is_truncated` is true, please use the `start_line` parameter and `end_line` parameter to call this `view` tool again.
- The cwd changes based on the type of file the user is currently in. Therefore the view tool tries
to adapt and tries to find your file anywhere in the tree upwards. It isn't necessarily the current
relative path, but it ensures you get the file if there was one.
]]

	function aview.func(input, opts)
		if not input.path then return false, 'path is required' end
		if opts.on_log then opts.on_log('path: ' .. input.path) end
		if input.path:sub(1, 1) ~= '/' then
			local d = select(2, get_real_active_buf()):match '.*/'
			while #d > 1 do
				if exists(d .. input.path) then
					input.path = d .. input.path
					break
				end
				d = d:gsub('[^/]*/$', '')
			end
		end
		if not exists(input.path) then return false, 'File does not exist: ' .. input.path end
		if vim.fn.isdirectory(input.path) == 1 then
			return 'List of files in directory:\n' .. vim.fn.glob(input.path .. '/*')
		end
		local abs_path = Helpers.get_abs_path(input.path)
		local lines = Utils.read_file_from_buf_or_disk(abs_path)
		local start_line = input.start_line
		local end_line = input.end_line
		if start_line and end_line and lines then
			lines = vim.list_slice(lines, start_line, end_line)
		end
		local truncated_lines = {}
		local is_truncated = false
		local size = 0
		for _, line in ipairs(lines or {}) do
			size = size + #line
			if size > 2048 * 100 then
				is_truncated = true
				break
			end
			table.insert(truncated_lines, line)
		end
		local total_line_count = lines and #lines or 0
		local content = truncated_lines and table.concat(truncated_lines, '\n') or ''
		local result = vim.json.encode {
			content = content,
			total_line_count = total_line_count,
			is_truncated = is_truncated,
		}
		if not opts.on_complete then return result, nil end
		opts.on_complete(result, nil)
	end

	---@type AvanteProviderFunctor
	---@diagnostic disable: missing-fields
	local eInfra = vim.tbl_deep_extend('force', require 'avante.providers.openai', {
		endpoint = 'https://llm.ai.e-infra.cz/v1',
		api_key_name = 'E_INFRA_KEY',
		timeout = 30000,
		is_reasoning_model = function() return true end,
	})

	local function list_models(self)
		local api_key = os.getenv(self.api_key_name) or error('No ' .. self.api_key_name)
		local p = io.popen(
			('curl -s -H "Authorization: Bearer %s" %s/models'):format(api_key, self.endpoint)
		) or error()
		local _, decoded = pcall(vim.json.decode, p:read '*a')
		p:close()

		local models = {}
		for _, model in ipairs(decoded.data) do
			local id = model.id
			models[#models + 1] = { id = id, name = 'infra/' .. id, display_name = 'infra/' .. id }
		end
		return models
	end
	local function infra(t) return vim.tbl_deep_extend('force', eInfra, t) end

	a.setup {
		provider = 'infra',
		---@type table<string,AvanteProviderFunctor>
		providers = {
			infra = infra {
				-- Model discovery via /v1/models endpoint
				list_models = list_models,
			},

			copilot = { __inherited_from = 'copilot', model = 'gpt-4.1' },
			open5 = { __inherited_from = 'copilot', model = 'gpt-5-mini' },
			sonnet = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
		},
		web_search_engine = {
			provider = 'tavily',
		},
		system_prompt = [[
**You:**
- are a pragmatic senior developer
- write code that is maintainable, well-structured, and appropriately simple for the problem at hand
- have good intuition and can continue writing the code in the same style it was already
- can write similar code to what's already there without studying the called method structure and implementation deeply until you need to fix errors in it

**Code Quality:**
- Respect existing conventions. Match the style, patterns, and structure already present in the codebase.
- Separation of concerns: each function/module should have one clear responsibility.
- But don't split a one-time-use function into smaller ones - abstract only for large code or repeated use.

**Documentation:**
- Document WHY, not WHAT. Comments should explain intent, trade-offs, or non-obvious behavior.
- Do not comment what is already stated by the method name. Comment only what isn't obvious from the name.
- Example of good comment: "lazyCleanup()-- Defer cleanup to avoid race with buffer deletion"
- Example of bad comment: "addOne()-- Increment counter by 1"

**Research:**
- AVOID USING TASKS/SUBTASKS OR YOU WILL BE FIRED FOR INEFFICIENCY!!!
- Tasks are extremely slow and you can get the same information much quicker.
- Use tasks ONLY if you have divided the entire plan into AT LEAST 5 SUBTASKS that can be done in parallel WHILE YOU KEEP WORKING.
- Use the web for API documentation, version-specific behavior, or when you're genuinely uncertain.

**Communication:**
- Skip pleasantries. No "Great question!", "You're right...", "But wait, no this, no that"...
- Present your reasoning briefly: context, assumptions, and why you chose this approach.

**When a tool call is rejected or fails:**
1. STOP. Do not re-implement the same solution.
2. Acknowledge the rejection/failure and analyze why, ask if you're uncertain.
3. Propose 2-3 alternative approaches in text and wait for the user to choose.

**Red flags you're off track:**
- You haven't consulted the official documentation first.
- Your tool calls are failing repeatedly.
- You have launched a task for reading or finding files.
]],
		-- - Use vim regexes for repetitive changes via the run_nvim_lua tool like vim.cmd'%s/\(keep\)bad/\1/g'
		windows = {
			spinner = {
				editing = { '' },
				generating = { '' },
				thinking = { '' },
			},
			input = {
				height = 20,
			},
		},
		selection = { hint_display = 'none' },
		behaviour = {
			auto_approve_tool_permissions = {
				run_python = false,
				'view',
				'str_replace',
			},
			confirmation_ui_style = 'inline_buttons', -- popup allows to provide rejection reason, but is awful otherwise
			use_cwd_as_project_root = false,
			enable_token_counting = true,
			auto_focus_on_diff_view = true,
		},
		history = {
			max_tokens = 4096,
		},
		-- 		 custom_tools = {
		-- 			{
		-- 				name = 'run_nvim_lua',
		-- 				description = [[Run Lua code in the current neovim session and return its return value.
		-- Note: you return the value you want, no printing

		-- Use the global variable `buf` to refer to the number of the buffer the user is actually editing!!
		-- ]],
		-- 				param = {
		-- 					type = 'table',
		-- 					fields = {
		-- 						{
		-- 							type = 'string',
		-- 							name = 'command',
		-- 							description = 'The multiline lua code to execute.',
		-- 							optional = false,
		-- 						},
		-- 					},
		-- 					usage = {
		-- 						command = 'Multiline lua code to run inside the currently used neovim editor with return value passthrough',
		-- 					},
		-- 				},
		-- 				returns = {
		-- 					{
		-- 						name = 'result',
		-- 						description = 'Return value of the code',
		-- 						type = 'string',
		-- 					},
		-- 					{
		-- 						name = 'error',
		-- 						description = 'Error message if execution failed',
		-- 						type = 'string',
		-- 						optional = true,
		-- 					},
		-- 				},
		-- 				---@type AvanteLLMToolFunc
		-- 				func = function(p, o)
		-- 					local command = p.command
		-- 					if not command then return nil, 'Error: missing argument `command`' end

		-- 					if a._command == command then
		-- 						return nil,
		-- 							'RED FLAG: trying to run the same command again.\nThink about what is wrong with the command and fix it.'
		-- 					end
		-- 					---@diagnostic disable-next-line: inject-field
		-- 					a._command = command

		-- 					-- Inject multiline code separately so it's visible in chat
		-- 					if command:find '\n' then
		-- 						local message = require('avante.history').Message:new(
		-- 							'assistant',
		-- 							('\nResult of:\n```lua\n%s\n```'):format(command),
		-- 							{ just_for_display = true }
		-- 						)
		-- 						o.session_ctx.on_messages_add { message }
		-- 					end

		-- 					for k, v in pairs {
		-- 						['print%('] = 'printing to the user instead of `return`',
		-- 						write = 'write not allowed, use str_replace tool or vim.cmd[[%s/xxx/yyy/]] for modifying the buffer.',
		-- 						[ 'vim.cmd%(([\'"])w%1%)' ] = 'writing files not allowed. if youuse str_replace tool for modifying the text',
		-- 						set_lines = 'changing text allowed only via str_replace tool',
		-- 						read = 'use the view tool to read a file',
		-- 					} do
		-- 						if command:match(k) then return nil, 'Logic error: ' .. v end
		-- 					end
		-- 					-- add missing `return` keyword
		-- 					if not command:match 'return ' and not command:match '=[^\n]+$' then
		-- 						command:gsub('([^\n=]+)$', 'return %1')
		-- 					end
		-- 					local chunk, err = loadstring(command)
		-- 					if not chunk then return nil, 'Syntax error: ' .. err end

		-- 					_G.buf = get_real_active_buf()
		-- 					local ok, result = xpcall(chunk, debug.traceback)
		-- 					_G.buf = nil
		-- 					if not ok then return nil, result or 'Error during execution' end

		-- 					if result == nil then return 'No value was returned' end

		-- 					return vim.inspect(result)
		-- 				end,
		-- 			},
		-- 		},

		mappings = {
			diff = {
				ours = '<leader>ao', -- reject
				theirs = '<leader>at',
				cursor = false,
				next = ']D',
				prev = '[D',
			},
			files = {
				add_current = false,
			},
			suggestion = {
				accept = false,
			},
			select_history = '<leader>ah',
		},
	}

	local function simulate_press(keyword, limit, cb)
		local cwin = vim.api.nvim_get_current_win()
		local cpos = vim.api.nvim_win_get_cursor(cwin)
		--   Allow      Allow Always      Reject -- no X for Reject because it can get wrapped
		keyword = ({ Allow = ' Allow', Always = ' Allow Always', Reject = ' Reject' })[keyword]

		local base = keyword:match '%w+$'
		local icon = keyword:sub(1, -#base - 1)

		local awin, abuf
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].ft == 'Avante' then
				awin, abuf = win, buf
				break
			end
		end

		local function press_next(remaining, last_line)
			local lines = vim.api.nvim_buf_get_lines(abuf, 0, -1, false)
			if remaining > 0 then
				for i = #lines, 1, -1 do
					local col = lines[i]:find(base, 1, true)
					if
						col -- check for matches at the edge of the line
						and (
							col > 1 and lines[i]:find(keyword, 1, true) == col - #icon
							or (col == 1 and i > 1 and lines[i - 1]:find(icon, -#icon, true))
						)
					then
						if last_line == i then break end -- matched some text

						vim.api.nvim_win_set_cursor(awin, { i, col })
						vim.api.nvim_input '\r'
						vim.defer_fn(function() press_next(remaining - 1, i) end, 120)
						return
					end
				end
			end

			-- Restore win/cursor if done
			if awin ~= cwin then
				vim.api.nvim_win_set_cursor(awin, { #lines, 0 })

				vim.api.nvim_set_current_win(cwin)
				vim.api.nvim_win_set_cursor(cwin, cpos)
				if cb then cb() end
			end
		end

		if awin then
			vim.cmd 'stopinsert'
			vim.api.nvim_set_current_win(awin)
			press_next(limit or 10, nil)
		end
	end

	require 'autocommands'('FileType', function(_) vim.wo.conceallevel = 0 end, 'Avante')
	require 'autocommands'('FileType', function(_)
		vim.bo.tw = 0
		map('n', '<A-Tab>', '<C-w>h', { buffer = true })
		map('i', '<A-Tab>', '<Esc><C-w>h', { buffer = true })
		map({ 'n', 'i' }, '<C-s>', function()
			simulate_press('Reject', 100, function()
				vim.cmd 'stopinsert'
				vim.api.nvim_input '\r'
			end)
		end, { buffer = true })
	end, 'AvanteInput')

	local api = require 'avante.api'
	map('n', ' aa', function() simulate_press('Allow', 1) end)
	map('n', ' aA', function() simulate_press('Always', 1) end)
	map('n', ' ar', function() simulate_press('Reject', 1) end)
	map('n', ' aS', function()
		api.stop()
		simulate_press 'Reject'
	end)

	map('n', ' a/', function()
		api.switch_provider 'opencode'
		api.select_acp_model()
	end)
	map('v', ' ae', ':AvanteEdit<CR>')
	map('n', ' ax', '<Cmd>AvanteClear<CR>')
	map('n', ' af', function()
		local fs = a.get().file_selector
		if vim.bo.filetype == 'NvimTree' then
			local file = require('nvim-tree.api').tree.get_node_under_cursor().absolute_path
			if vim.fn.isdirectory(file) == 1 then file = file .. '/' end

			local paths = fs.selected_filepaths
			local cnt = #paths
			local i = cnt
			while i > 0 do
				if vim.startswith(paths[i], file) then table.remove(paths, i) end
				i = i - 1
			end

			if #paths == cnt then
				fs:add_selected_file(file)
			else
				fs:emit 'update'
			end
		else
			-- toggles the file being included
			fs:add_current_buffer()
		end
	end)
	map('n', ' aq', function() a.get().file_selector:add_quickfix_files() end)
end

return M
