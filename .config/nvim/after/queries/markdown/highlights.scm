;; extends
((atx_heading
  (atx_h1_marker) @markup.heading.marker
  (inline) @markup.heading.1) (#set! conceal "Ⅰ"))

((atx_heading
  (atx_h2_marker) @markup.heading.marker
  (inline) @markup.heading.2) (#set! conceal "Ⅱ"))

((atx_heading
  (atx_h3_marker) @markup.heading.marker
  (inline) @markup.heading.3) (#set! conceal "Ⅲ"))

((atx_heading
  (atx_h4_marker) @markup.heading.marker
  (inline) @markup.heading.4) (#set! conceal "Ⅳ"))

(fenced_code_block
  (fenced_code_block_delimiter) @markup.raw.delimiter)
