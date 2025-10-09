---@type avante.Config
return {
	'yetone/avante.nvim',
	event = 'LspAttach',
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
				temperature = 0.5,
				max_tokens = 16384,
			},
		}
		a.setup {
			provider = 'claude45',
			behaviour = {
				auto_approve_tool_permissions = {},
			},
			providers = {
				gpt120 = vim.tbl_extend('force', eInfraBase, { model = 'gpt-oss-120b' }),
				qwen3 = vim.tbl_extend('force', eInfraBase, { model = 'qwen3-coder' }),
				ds1 = vim.tbl_extend('force', eInfraBase, { model = 'deepseek-r1' }),

				gpt4 = { __inherited_from = 'copilot', model = 'gpt-4.1' },
				o4 = { __inherited_from = 'copilot', model = 'o4-mini' },
				gpt5 = { __inherited_from = 'copilot', model = 'gpt-5' },
				claude45 = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
			},
			system_prompt = [[
You are an autoregressive language model that has been fine-tuned with instruction-tuning and RLHF.
You carefully provide accurate, factual, thoughtful, nuanced answers, and are brilliant at
reasoning. If you think there might not be a correct answer, you say so. Since you are
autoregressive, each token you produce is another opportunity to use computation, therefore you
always spend a few sentences explaining background context, assumptions, and step-by-step thinking
BEFORE you try to answer a question. Your users are experts in AI and ethics, so they already know
you’re a language model and your capabilities and limitations, so don’t remind them of that. They’re
familiar with ethical issues in general so you don’t need to remind them about those either. Your
users can specify the level of detail of the steps of your thoughts they would like in your response
with the following notation: V=((level)), where ((level)) can be 0-5. Level 0 is the least verbose
(no additional context, just get straight to the answer), while level 5 is extremely verbose.
For example: V=5 What are your steps to solve this problem?
The default level is V=3.
]],
			mappings = {
				files = {
					add_current = false,
				},
			},
		}

		require 'autocommands'('FileType', function(_) vim.wo.conceallevel = 2 end, 'Avante')
		require 'autocommands'('FileType', function(_)
			map('n', '<A-Tab>', '<C-w>h', { buffer = true })
			map('i', '<A-Tab>', '<Esc><C-w>h', { buffer = true })
		end, 'AvanteInput')

		map('n', '<Leader>ac', '<Cmd>AvanteChat<CR>')
		map('n', '<Leader>aa', function()
			if not a.get() then
				api.ask()
			else
				api.focus()
			end
		end)
		map('n', '<Leader>af', function()
			local fs = a.get().file_selector
			if vim.bo.filetype == 'NvimTree' then
				local cwd = vim.loop.cwd()
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
		map('n', '<Leader>ax', '<Cmd>AvanteClear<CR>')
	end,
}
