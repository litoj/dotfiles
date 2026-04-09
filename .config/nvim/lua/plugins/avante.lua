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

local eInfra = {
	endpoint = 'https://llm.ai.e-infra.cz/v1',
	api_key_name = 'E_INFRA_KEY',
	timeout = 30000,
	extra_request_body = {
		max_tokens = 8192,
	},
	-- Model discovery via /v1/models endpoint
	list_models = function(self)
		local api_key = os.getenv(self.api_key_name) or error('No ' .. self.api_key_name)
		local p =
			io.popen(('curl -s -H "Authorization: Bearer %s" %s/models'):format(api_key, self.endpoint))
		local ok, decoded = pcall(vim.json.decode, p:read '*a')
		p:close()
		if not ok or not decoded.data then return {} end

		-- Transform the OpenAI models API response to Avante's expected format
		local models = {}
		-- print(decoded.data)
		local filter = {
			['deepseek-v3.2'] = 1,
			['glm-4.7'] = 1,
			['gpt-oss-120b'] = 1,
			['kimi-k2.5'] = 1,
			['llama-4-scout-17b-16e-instruct'] = 1,
			['mini'] = 1,
			['mistral-small-4'] = 1,
			['multilingual-e5-large-instruct'] = 1,
			['mxbai-embed-large:latest'] = 1,
			['nomic-embed-text-v1.5'] = 1,
			['nomic-embed-text-v2-moe'] = 1,
			['qwen3-coder'] = 1,
			['qwen3-coder-30b'] = 1,
			['qwen3-embedding-4b'] = 1,
			['qwen3-reranker-4b'] = 1,
			['qwen3.5-122b'] = 1,
			['redhatai-scout'] = 1,
		}
		for _, model in ipairs(decoded.data) do
			if not filter[model.id] then
				table.insert(models, {
					id = model.id,
					name = ('infra/%s'):format(model.id),
					display_name = model.id,
					provider_name = 'infra',
				})
			end
		end
		return models
	end,
}

function M.config()
	local a = require 'avante'

	-- This allows list_models to work (model_selector.lua checks __inherited_from == nil)
	local openai = require 'avante.providers.openai'
	-- Manually copy all functions from openai provider
	for k, v in pairs(openai) do
		if eInfra[k] == nil then eInfra[k] = v end
	end

	a.setup {
		behaviour = {
			auto_approve_tool_permissions = {
				-- str_replace = true,
				view = true,
				undo_edit = false,
			},
			use_cwd_as_project_root = true,
			enable_token_counting = false,
		},
		selection = { hint_display = 'none' },
		provider = 'infra',
		model = 'glm-5',
		providers = {
			infra = eInfra,
			copilot = { __inherited_from = 'copilot', model = 'gpt-4.1' },
			openai5mini = { __inherited_from = 'copilot', model = 'gpt-5-mini' },
			sonnet = { __inherited_from = 'copilot', model = 'claude-sonnet-4.5' },
		},
		web_search_engine = {
			provider = 'tavily',
		},
		system_prompt = [[
You are a seasoned developer writing well-structured modular code focused on separation-of-concerns,
high code flexibility and extensibility.
Your documentation provides concise additional information that the user might not understand
from the code on its own at the first glance, but no redundant descriptions of obvious statements.

**Be genuinely helpful, not performatively helpful.** Skip the "Great question!" and "I'd be happy
to help!" - just help. Actions speak louder than filler words.

**Have opinions.** You're allowed to disagree, prefer things, find stuff amusing or boring. But
always base your opinions on core thruths that you've found through thorough research. Don't just
say something because it seems most likely - always check that things really are that way.

When thinking about a problem, don't be afraid to explore multiple directions at the beginning and
then decide which one leads to the best path into the future. Always search the internet for the most
up-to-date documentation and information on the subject.

If you find yourself stuck or unsure about what to do, ask. It is always better to verify than to
waste time doing something nobody asked you to do.
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
				-- all_theirs = '<leader>aA',
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

	map('n', '<Leader>aA', function() require('avante.diff').process_position(0, 'all_theirs') end)
	map('n', '<Leader>ae', '<Cmd>AvanteEdit<CR>')
	map('n', '<Leader>ax', '<Cmd>AvanteClear<CR>')
	map('n', '<Leader>af', function()
		local fs = a.get().file_selector
		if vim.bo.filetype == 'NvimTree' then
			local file = require('nvim-tree.api').tree.get_node_under_cursor().absolute_path
			if vim.fn.isdirectory(file) then file = file .. '/' end

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
end

return M
