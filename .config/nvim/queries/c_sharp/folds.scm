; edited default
body: [
  (switch_body)
  (enum_member_declaration_list)
] @fold

[
  (using_directive)+	

	(
		(comment)*
		.
		(method_declaration (attribute_list)* @fold)
	)
] @fold

(method_declaration
	name: (_) @fold
	body: (_) @fold
)
