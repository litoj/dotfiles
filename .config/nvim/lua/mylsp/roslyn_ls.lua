-- dotnet tool install roslyn-language-server --prerelease -g
-- paru -S roslyn-ls

local function refresh(s) vim.lsp.diagnostic._refresh(s.buf) end

return {
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd(
			{ 'InsertLeavePre', 'BufWritePost' },
			{ buffer = bufnr, callback = refresh }
		)
	end,
	handlers = {
		['workspace/projectInitializationComplete'] = function(_, _, ctx) vim.lsp.diagnostic._refresh() end,
	},
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = false, -- true for neovim filewatching, false for roslyn
			},
		},
	},
	settings = {
		['csharp|background_analysis'] = {
			dotnet_analyzer_diagnostics_scope = 'openFiles',
			dotnet_compiler_diagnostics_scope = 'openFiles',
		},
		['csharp|inlay_hints'] = {
			csharp_enable_inlay_hints_for_implicit_object_creation = true,
			csharp_enable_inlay_hints_for_implicit_variable_types = true,
			csharp_enable_inlay_hints_for_lambda_parameter_types = true,
			csharp_enable_inlay_hints_for_types = false,
			dotnet_enable_inlay_hints_for_indexer_parameters = true,
			dotnet_enable_inlay_hints_for_literal_parameters = true,
			dotnet_enable_inlay_hints_for_object_creation_parameters = true,
			dotnet_enable_inlay_hints_for_other_parameters = true,
			dotnet_enable_inlay_hints_for_parameters = true,
			dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
			dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
			dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
		},
		['csharp|symbol_search'] = {
			dotnet_search_reference_assemblies = true,
		},
		['csharp|completion'] = {
			dotnet_show_name_completion_suggestions = false,
			dotnet_show_completion_items_from_unimported_namespaces = true,
			dotnet_provide_regex_completions = false,
		},
		['csharp|code_lens'] = {
			dotnet_enable_references_code_lens = false,
			dotnet_enable_tests_code_lens = false,
		},
		['csharp|formatting'] = {
			dotnet_organize_imports_on_format = true,
		},
	},
}
