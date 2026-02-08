return { -- dotnet tool install roslyn-language-server --prerelease -g
	cmd = {
		os.getenv 'HOME' .. '/.dotnet/tools/roslyn-language-server',
		'--logLevel=Information',
		'--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.log.get_filename()),
		'--stdio',
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
			dotnet_enable_tests_code_lens = true,
		},
		['csharp|formatting'] = {
			dotnet_organize_imports_on_format = true,
		},
	},
}
