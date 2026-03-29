;; extends

(string 
	content: (string_content) @injection.content
  (#match? @injection.content "\\(.*\\@")
  (#set! injection.language "query")
)

