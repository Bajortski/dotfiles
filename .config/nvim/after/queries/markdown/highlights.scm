;; extends

;; Render YAML/TOML frontmatter uniformly grey. The markdown parser injects a
;; yaml/toml parser into the metadata block, whose own highlights (keys, strings)
;; would otherwise colour it. Re-capturing the whole node at a higher priority
;; lets a single grey win over the injected language's captures.
((minus_metadata) @markdownFrontmatter (#set! priority 105))
((plus_metadata) @markdownFrontmatter (#set! priority 105))
