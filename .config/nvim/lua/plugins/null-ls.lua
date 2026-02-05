local M = {
	'nvimtools/none-ls.nvim',
	dependencies = 'nvim-lua/plenary.nvim',
	event = 'VeryLazy',
}
function M.config()
	local nls = require 'null-ls'

	nls.setup {
		single_file_support = true,
		sources = {
			nls.builtins.formatting.stylua.with {
				extra_args = function()
					local cwd = vim.loop.cwd():gsub('/lua$', '')
					for _, f in ipairs { '/.stylua.toml', '/stylua.toml' } do
						f = cwd .. f
						if exists(f) then return {} end
					end
					if not vim.tbl_isempty(vim.b.editorconfig) then return {} end
					return {
						'--column-width=' .. vim.bo.textwidth,
						'--indent-type=' .. (vim.bo.expandtab and 'Spaces' or 'Tabs'),
						'--indent-width=' .. vim.bo.shiftwidth,
						'--quote-style=AutoPreferSingle',
						'--collapse-simple-statement=Always',
						'--call-parentheses=None',
					}
				end,
			},
			nls.builtins.formatting.prettier.with {
				filetypes = { 'markdown', 'json', 'json5', 'jsonc', 'yaml', 'javascript', 'vue' },
				extra_args = function()
					if
						vim.bo.ft == 'javascript'
						and #(vim.lsp.get_clients { bufnr = 0, name = 'eslint' }) > 0
					then
						return false
					end
					return {
						'--print-width',
						vim.bo.textwidth,
						'--tab-width',
						vim.bo.tabstop,
						'--prose-wrap=always',
						'--no-bracket-spacing',
						'--single-quote',
						'--no-semi',
						vim.bo.expandtab and '--no-semi' or '--use-tabs',
					}
				end,
			},
			nls.builtins.formatting.shfmt.with {
				extra_args = function()
					if not vim.tbl_isempty(vim.b.editorconfig) then return {} end
					return { '-ci', '-s', '-i', (vim.bo.expandtab and vim.bo.tabstop or 0) }
				end,
			},
			nls.builtins.formatting.clang_format.with {
				filetypes = { 'c', 'cpp', 'java' },
				extra_args = function(client)
					if exists(client.cwd .. '/.clang-format') then return { '--style', 'file' } end
					return {
						'--style',
						string.format( --RemoveBracesLLVM: true,
							[[{
AllowAllParametersOfDeclarationOnNextLine: true,
AllowShortIfStatementsOnASingleLine: "AllIfsAndElse",
AllowShortLambdasOnASingleLine: "All",
AllowShortLoopsOnASingleLine: true,
AllowShortBlocksOnASingleLine: "Empty",
AllowShortCaseLabelsOnASingleLine: true,
AllowShortEnumsOnASingleLine: false,
AllowShortFunctionsOnASingleLine: "Inline",
AlignOperands: "DontAlign",
AlignAfterOpenBracket: "BlockIndent",
AlignConsecutiveAssignments: "AcrossEmptyLines",
AlignEscapedNewlines: "Left",
AlignTrailingComments: "Never",
BreakBeforeBraces: "Attach",
IndentCaseBlocks: false,
IndentCaseLabels: true,
SortJavaStaticImport: "After",
SpaceAfterCStyleCast: true,
JavaImportGroups: [ "java" ],
IndentWidth: %d, ContinuationIndentWidth: %d, TabWidth: %d, UseTab: %s, ColumnLimit: %d}]],
							vim.bo.shiftwidth,
							vim.bo.shiftwidth,
							vim.bo.tabstop,
							vim.bo.expandtab and 'Never' or 'ForIndentation',
							vim.bo.textwidth
						),
					}
				end,
			},
			nls.builtins.formatting.black,
		},
	}
end
return M
