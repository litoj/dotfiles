;; extends

(string 
	content: (string_content) @injection.content
  (#match? @injection.content "^\\s*\\([a-z_]+\\s+[(\"]*")
  (#set! injection.language "query")
)

(string 
	content: (string_content) @injection.content
  (#match? @injection.content "\\[[^]]*[_.[^-][^]]*\\]")
  (#set! injection.language "regex")
)

