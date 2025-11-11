if vim.g.features_level < 4 then return {} end

---@type avante.Config
return {
	'yetone/avante.nvim',
	keys = ' a',
	build = 'make',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'MunifTanjim/nui.nvim',
	},
	config = function()
		local a = require 'avante'
		local api = require 'avante.api'

		local eInfraBase = {
			endpoint = 'https://chat.ai.e-infra.cz/api/',
			__inherited_from = 'openai',
			api_key_name = 'E_INFRA_API_KEY',
			timeout = 30000,
			extra_request_body = {
				temperature = 0.1,
				max_tokens = 16384,
			},
		}
		a.setup {
			behaviour = {
				auto_approve_tool_permissions = false --[[ {
					str_replace = true,
				} ]],
				use_cwd_as_project_root = true,
			},
			selection = { hint_display = 'none' },
			provider = 'claude45',
			providers = {
				gpt120 = vim.tbl_extend('force', eInfraBase, { model = 'gpt-oss-120b' }),
				qwen3 = vim.tbl_extend('force', eInfraBase, { model = 'qwen3-coder' }),
				ds1 = vim.tbl_extend('force', eInfraBase, { model = 'deepseek-r1' }),

				gpt4 = { __inherited_from = 'copilot', model = 'gpt-4.1' },
				o4 = { __inherited_from = 'copilot', model = 'o4' },
				gpt5 = { __inherited_from = 'copilot', model = 'gpt-5' },
				claude45 = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
			},
			web_search_engine = {
				provider = 'tavily',
			},
			system_prompt = [[
You are a seasoned developer with highest quality of code structure, flexibility, extensibility
as well as documentation and testing.
All comments you write provide additional information or explanation of the code rather than just
stating the obvious. You always aim to write code that is easy to read, maintain and extend in the future.
You carefully provide accurate, factual, thoughtful, nuanced answers, and are brilliant at reasoning.
If you think there might not be a correct answer, you say so. If you come to the conclusion you
cannot achieve a certain task, you say so.
Based on the set verbosity level spend a few sentences explaining background context, assumptions,
and step-by-step thinking BEFORE you try to answer a question.
Users communicating with you can specify level of detail of the steps and background of your thoughts
they would like in your response with the following notation: V=<level>, where <level> can be 0-5.
Level 0 is the least verbose (no additional context, just get straight to the answer),
while level 5 is extremely verbose. For example: V=5 What are your steps to solve this problem?
The default level is V=3.
]],
			windows = {
				spinner = {
					generating = { '' },
				},
			},
			mappings = {
				diff = {
					ours = '<leader>r', -- reject
					theirs = '<leader>t',
					all_theirs = '<leader>A',
					both = 'cb',
					cursor = 'cc',
					next = ']D',
					prev = '[D',
				},
				files = {
					add_current = false,
				},
				suggestion = {
					accept = false,
				},
				select_history = '<leader>al',
			},
		}

		require 'autocommands'('FileType', function(_) vim.wo.conceallevel = 2 end, 'Avante')
		require 'autocommands'('FileType', function(_)
			vim.bo.tw = 0
			map('n', '<A-Tab>', '<C-w>h', { buffer = true })
			map('i', '<A-Tab>', '<Esc><C-w>h', { buffer = true })
		end, 'AvanteInput')

		map('n', '<Leader>ax', '<Cmd>AvanteClear<CR>')
		map('n', '<Leader>ac', '<Cmd>AvanteChat<CR>')
		map('n', '<Leader>aa', function() -- needed only for non-floating ask
			if not a.get() then
				api.ask()
			else
				api.focus()
			end
		end)
		map('n', '<Leader>af', function()
			local fs = a.get().file_selector
			if vim.bo.filetype == 'NvimTree' then
				local file = require('nvim-tree.api').tree.get_node_under_cursor().absolute_path

				local cnt = #fs.selected_filepaths
				fs:remove_selected_file(file)
				-- otherwise add the file, if it previously wasn't selected
				if #fs.selected_filepaths == cnt then fs:add_selected_file(file) end
			else
				-- toggles the file being included
				fs:add_current_buffer()
			end
		end)
	end,
}
