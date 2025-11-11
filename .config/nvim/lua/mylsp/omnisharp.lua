return { -- https://github.com/OmniSharp/omnisharp-roslyn/wiki/Configuration-Options
	settings = {
		FormattingOptions = {
			OrganizeImports = true,
		},
		RoslynExtensionsOptions = {
			EnableAnalyzersSupport = true,
			EnableImportCompletion = true,
		},
		MsBuild = {
			LoadProjectsOnDemand = false,
		},
	},
}
