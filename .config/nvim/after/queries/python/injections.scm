;; extends
(
  (string  (string_content) @injection.content)
  (#match? @injection.content "(^| )[A-Z][A-Z]+([ ,(]|$)")
  (#set! injection.language "sql") 
)
