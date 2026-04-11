if vim.g.features_level < 7 then return {} end
local M = {
	'yetone/avante.nvim',
	keys = ' a',
	build = 'make',
	-- enabled = false,
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
		{
			'zbirenbaum/copilot.lua',
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

function M.config()
	local a = require 'avante'

	---@type AvanteProviderFunctor
	---@diagnostic disable: missing-fields
	local eInfra = vim.tbl_deep_extend('force', require 'avante.providers.openai', {
		endpoint = 'https://llm.ai.e-infra.cz/v1',
		api_key_name = 'E_INFRA_KEY',
		timeout = 30000,
		is_reasoning_model = function() return true end,
	})

	local function infra(t) return vim.tbl_deep_extend('force', eInfra, t) end
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
			if not id:find '[%-0-9]' then
				models[#models + 1] = { id = id, name = 'infra/' .. id, display_name = id }
			end
		end
		return models
	end

	a.setup {
		provider = 'copilot',
		acp_providers = {
			opencode = {
				command = 'opencode',
				args = { 'acp' },
				list_models = list_models,
				include_model = true,
			},
		},
		---@type table<string,AvanteProviderFunctor>
		providers = {
			infra = vim.tbl_deep_extend('force', eInfra, {
				-- Model discovery via /v1/models endpoint
				list_models = list_models,
			}),
			glm = infra { model = 'glm-5', context_window = 200000 },
			qwen = infra { model = 'qwen3.5', context_window = 262000 },
			kimi = infra {
				model = 'kimi-k2.5',
				context_window = 256000,
				extra_request_body = { chat_template_kwargs = { thinking = true } },
			},
			ds = infra {
				model = 'deepseek-v3.2',
				context_window = 160000,
				extra_request_body = { chat_template_kwargs = { thinking = true } },
			},

			copilot = { __inherited_from = 'copilot', model = 'gpt-4.1' },
			open5 = { __inherited_from = 'copilot', model = 'gpt-5-mini' },
			sonnet = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
		},
		web_search_engine = {
			provider = 'tavily',
		},
		system_prompt = [[
You are a pragmatic senior developer. Write code that is maintainable, well-structured, and appropriately simple for the problem at hand.

**Code Quality:**
- Prefer working code over perfect code. Solve the problem first, refine second.
- Respect existing conventions. Match the style, patterns, and structure already present in the codebase.
- Separation of concerns: each function/module should have one clear responsibility.
  - But don't split a simple one-time-use function into smaller ones - just keep all the code in one!!!
- Prefer duplication over the wrong abstraction. Don't generalize until you have 3+ similar cases.

**Documentation:**
- Document WHY, not WHAT. The code shows what it does; comments should explain intent, trade-offs, or non-obvious behavior.
- Example of good comment: "-- Defer cleanup to avoid race with buffer deletion"
- Example of bad comment: "-- Increment counter by 1"
- For complex logic, a brief inline explanation of the approach is better than a long docstring.

**Research:**
- Search the web for API documentation, version-specific behavior, or when you're genuinely uncertain.
- Always check the official documentation before creating code.

**Communication:**
- Skip pleasantries. No "Great question!", "You're absolutely right...", or filler.
- When thinking through a problem, use the thinking tool for complex cases.
- Present your reasoning briefly: context, assumptions, and why you chose this approach.
- If stuck or requirements are unclear, ask before implementing.

**When I reject a change:**
1. STOP. Do not re-implement the same solution.
2. Acknowledge the rejection and analyze why based on my explanation.
3. Propose 2-3 alternative approaches in text BEFORE writing code.
4. Wait for my direction on which to pursue.

**Red flags you're off track:**
- You haven't consulted the official documentation first.
- You haven't proposed alternatives in text first.
- You're about to suggest the same edit for the 2nd time.
- Your changes are failing -> you should **view() the file you're working** to check for changes.
]],
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
			},
			confirmation_ui_style = 'inline_buttons', -- popup allows to provide rejection reason, but is awful otherwise
			use_cwd_as_project_root = false,
			enable_token_counting = true,
			auto_focus_on_diff_view = true,
		},
		history = {
			max_tokens = 4096,
		},
		custom_tools = {
			{
				name = 'run_viml',
				description = 'Execute VimL code in neovim.',
				command = 'vim.cmd[[...]]',
				param = {
					type = 'table',
					fields = {
						type = 'string',
						name = 'command',
						description = 'The VimL command to run.',
						optional = false,
					},
				},
				returns = {
					{
						name = 'result',
						description = 'Output of the code',
						type = 'string',
					},
					{
						name = 'error',
						description = 'Error message if execution failed',
						type = 'string',
						optional = true,
					},
				},
				---@type AvanteLLMToolFunc
				func = function(p, o)
					local command = p.command
					if not command then return nil, 'Error: missing argument `command`' end

					if command:find '\n' then
						local message = require('avante.history').Message:new(
							'assistant',
							('\nResult of:\n```vim\n%s\n```'):format(command),
							{
								just_for_display = true,
							}
						)
						o.session_ctx.on_messages_add { message }
					end

					local ui2 = require 'vim._core.ui2'
					local cmdbuf = ui2.bufs.cmd

					-- Clear command buffer before execution
					vim.api.nvim_buf_set_lines(cmdbuf, 0, -1, false, {})
					vim.api.nvim_buf_clear_namespace(cmdbuf, ui2.ns, 0, -1)

					local ok, err = pcall(function() vim.cmd(command) end)
					return ok and table.concat(vim.api.nvim_buf_get_lines(cmdbuf, 0, -1, false), '\n') or '',
						not ok and err or nil
				end,
			},

			{
				name = 'run_nvim_lua',
				description = 'Run Lua code in the current neovim instance.',
				command = '... -- example: return vim.bo.ft',
				param = {
					type = 'table',
					fields = {
						{
							type = 'string',
							name = 'command',
							description = 'The lua code to execute (supports multiline).',
							optional = false,
						},
					},
				},
				returns = {
					{
						name = 'result',
						description = 'Result of the execution',
						type = 'string',
					},
					{
						name = 'error',
						description = 'Error message if execution failed',
						type = 'string',
						optional = true,
					},
				},
				---@type AvanteLLMToolFunc
				func = function(p, o)
					local command = p.command
					if not command then return nil, 'Error: missing argument `command`' end

					if command:find '\n' then
						local message = require('avante.history').Message:new(
							'assistant',
							('\nResult of:\n```lua\n%s\n```'):format(command),
							{
								just_for_display = true,
							}
						)
						o.session_ctx.on_messages_add { message }
					end

					local chunk, err = loadstring(command)
					if not chunk then return nil, 'Syntax error: ' .. err end

					local ok, result = pcall(chunk)
					local output = ok and vim.inspect(result) or ''
					_G.data = { p, o }
					-- Include the code in the output so it's visible in chat
					return output, not ok and tostring(result) or nil
				end,
			},
		},

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

	require 'autocommands'('FileType', function(_) vim.wo.conceallevel = 2 end, 'Avante')
	local function simulate_press(keyword, limit, cb)
		local cwin = vim.api.nvim_get_current_win()
		local cpos = vim.api.nvim_win_get_cursor(cwin)
		--   Allow      Allow Always      Reject -- no X for Reject because it can get wrapped
		keyword = ({ Allow = ' Allow', AlwaysAllow = ' Allow Always', Reject = 'Reject' })[keyword]

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
					local col = lines[i]:find(keyword, 1, true)
					if col then
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
			press_next(limit or 100, nil)
		end
	end

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
	map('n', ' aA', function() simulate_press('Always Allow', 1) end)
	map('n', ' ar', function() simulate_press('Reject', 1) end)
	map('n', ' aS', function()
		api.stop()
		simulate_press 'Reject'
	end)

	map('n', ' a/', function()
		api.switch_provider 'opencode'
		api.select_acp_model()
	end)
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
