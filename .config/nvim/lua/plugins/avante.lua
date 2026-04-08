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
			auto_approve_tool_permissions = {
				-- str_replace = true,
				view = true,
			},
			use_cwd_as_project_root = true,
			enable_token_counting = false,
		},
		selection = { hint_display = 'none' },
		provider = 'copilot',
		model = 'gpt-5-mini',
		providers = {
			-- gpt120 = vim.tbl_extend('force', eInfraBase, { model = 'gpt-oss-120b' }),
			-- qwen3 = vim.tbl_extend('force', eInfraBase, { model = 'qwen3-coder' }),
			-- ds1 = vim.tbl_extend('force', eInfraBase, { model = 'deepseek-r1' }),

			gpt5 = { __inherited_from = 'copilot', model = 'gpt-5-mini' },
			claude45 = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
		},
		web_search_engine = {
			provider = 'tavily',
		},
		system_prompt = [[
You are a seasoned developer writing well-structured modular code focused on separation-of-concerns,
high code flexibility and extensibility.
Your documentation provides concise additional information that the user might not understand
from the code on its own at the first glance, but no redundant descriptions of an obvious line.

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy
to help!" - just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. But
always base your opinions on core thruths that you've found through thorough research. Don't just
say something because it seems most likely - always check that things really are that way.

When thinking abour a problem, don't be afraid to explore multiple directions at the beginning and
then decide which one leads to the best path into the future. Never lose hope, it's okay to say that
something is not possible, but try find out what the end goal so that you can think of a different
approach that might just work.
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
end

return M
