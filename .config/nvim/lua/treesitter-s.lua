require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		"bash",
		"bibtex",
		"c",
		"comment",
		"cpp",
		"css",
		"fish",
		"html",
		"javascript",
		-- "java",
		-- "jsdoc",
		"json",
		"latex",
		"lua",
		"python",
		"rust",
		-- "scss",
		-- "typescript",
		"yaml"
	}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	ignore_install = {"haskell"},
	highlight = {enable = true, additional_vim_regex_highlighting = false},
	autotag = {enable = true},
	autopairs = {enable = true},
	indent = {enable = true, disable = {"yaml"}}
}
vim.cmd[[
set fdm=expr fdn=3
set foldexpr=nvim_treesitter#foldexpr()
]]
