if vim.g.features_level < 4 then return {} end

return {
	'yetone/avante.nvim',
	keys = ' a',
	build = 'make',
	-- enabled = false,
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
				enable_token_counting = false,
			},
			selection = { hint_display = 'none' },
			provider = 'claude45',
			model = 'claude-sonnet-4.6',
			providers = {
				-- gpt120 = vim.tbl_extend('force', eInfraBase, { model = 'gpt-oss-120b' }),
				-- qwen3 = vim.tbl_extend('force', eInfraBase, { model = 'qwen3-coder' }),
				-- ds1 = vim.tbl_extend('force', eInfraBase, { model = 'deepseek-r1' }),

				gpt5 = { __inherited_from = 'copilot', model = 'gpt-5' },
				claude45 = { __inherited_from = 'copilot', model = 'claude-sonnet-4.6' },
			},
			web_search_engine = {
				provider = 'tavily',
			},
			system_prompt = [[
You are a seasoned developer writing well-structured code focused on separation-of-concerns,
high code flexibility, extensibility as well as documentation.
Your documentation provides concise additional information that the user might not understand
from the code at the first glance, no redundant information.

You first lay out your approach and then you follow it.
You always do research and fact-check before answering.
You acknowledge if you think you don't know the answer or cannot achieve the task.
]],
--[[ Based on the set verbosity level spend a few sentences explaining background context, assumptions,
and step-by-step thinking BEFORE you try to answer a question.
Users communicating with you can specify level of detail of the steps and background of your thoughts
they would like in your response with the following notation: V=<level>, where <level> can be 0-5.
Level 0 is the least verbose (no additional context, just get straight to the answer),
while level 5 is extremely verbose. For example: V=5 How do you approach solving this problem?
The default level is V=3. ]]
			windows = {
				spinner = {
					generating = { '' },
				},
			},
			mappings = {
				diff = {
					ours = '<leader>ar', -- reject
					theirs = '<leader>aa',
					all_theirs = '<leader>aA',
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
				select_history = '<leader>ah',
			},
		}

		require 'autocommands'('FileType', function(_) vim.wo.conceallevel = 2 end, 'Avante')
		require 'autocommands'('FileType', function(_)
			vim.bo.tw = 0
			map('n', '<A-Tab>', '<C-w>h', { buffer = true })
			map('i', '<A-Tab>', '<Esc><C-w>h', { buffer = true })
		end, 'AvanteInput')

		map('n', '<Leader>ax', '<Cmd>AvanteClear<CR>')
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
