;; extends

; Extra captures so Ruby gets the scopes TextMate's Ruby + Rails grammars gave it.
; Colours for these are set in colors/sunburst.lua.

; Whole literals, so every delimiter (', %w[, /, <<~SQL ...) takes the literal's colour.
((string) @string (#set! priority 98))
((subshell) @string (#set! priority 98))
((heredoc_body) @string (#set! priority 98))
((regex) @string.regexp (#set! priority 98))
((delimited_symbol) @string.special.symbol (#set! priority 98))
((string_array) @string (#set! priority 98))
((symbol_array) @string.special.symbol (#set! priority 98))
((regex "/" @string.regexp) (#set! priority 101))

; |block, params| pipes are plain punctuation (the default query also tags "|" as an operator)
((block_parameters "|" @punctuation.plain) (#set! priority 101))

; Code inside #{ } — "string.quoted source"
((interpolation) @embedded (#set! priority 99))

; `key:` includes its colon (constant.other.symbol.hashkey)
((pair key: (hash_key_symbol) ":" @string.special.symbol) (#set! priority 101))

; class Foo / module Foo — entity.name.type; `< Bar` — entity.other.inherited-class
((class name: (_) @type.definition) (#set! priority 101))
((module name: (_) @type.definition) (#set! priority 101))
((class name: (scope_resolution (constant) @type.definition)) (#set! priority 101))
((module name: (scope_resolution (constant) @type.definition)) (#set! priority 101))
((superclass (_) @type.inherited) (#set! priority 101))
((superclass (scope_resolution (constant) @type.inherited)) (#set! priority 101))
((superclass "<" @punctuation.delimiter) (#set! priority 101))

; User.find, Foo::Bar, Foo[...] — support.class
((call receiver: (constant) @type.support) (#set! priority 101))
((scope_resolution scope: (constant) @type.support) (#set! priority 101))
((element_reference object: (constant) @type.support) (#set! priority 101))

; keyword.control.pseudo-method
((super) @keyword (#set! priority 101))
(((identifier) @keyword
  (#any-of? @keyword "block_given?" "alias_method"))
  (#set! priority 101))
(("defined?" @keyword) (#set! priority 101))

; keyword.other.special-method
((call
  method: (identifier) @keyword.special
  (#any-of? @keyword.special
    "initialize" "new" "loop" "include" "extend" "prepend" "fail" "raise" "attr_reader"
    "attr_writer" "attr_accessor" "attr" "catch" "throw" "private" "private_class_method"
    "module_function" "public" "public_class_method" "protected" "refine" "using"
    "require" "require_relative"))
  (#set! priority 101))
([(body_statement (identifier) @keyword.special) (program (identifier) @keyword.special)]
  (#any-of? @keyword.special
    "private" "protected" "public" "module_function" "private_class_method" "public_class_method")
  (#set! priority 101))

; support.function.kernel
((call
  !receiver
  method: (identifier) @function.support
  (#any-of? @function.support
    "abort" "at_exit" "autoload" "autoload?" "binding" "callcc" "caller" "caller_locations"
    "chomp" "chop" "eval" "exec" "exit" "exit!" "fork" "format" "gets" "global_variables"
    "gsub" "lambda" "load" "local_variables" "open" "p" "print" "printf" "proc" "putc" "puts"
    "rand" "readline" "readlines" "select" "set_trace_func" "sleep" "spawn" "sprintf" "srand"
    "sub" "syscall" "system" "test" "trace_var" "trap" "untrace_var" "warn"))
  (#set! priority 101))
((lambda "->" @function.support) (#set! priority 101))

; support.function.*.rails — the Rails bundle's list, plus the DSL added since Rails 3
((call
  !receiver
  method: (identifier) @function.support
  (#any-of? @function.support
    ; actionpack
    "before_action" "after_action" "around_action" "skip_before_action" "skip_after_action"
    "skip_around_action" "before_filter" "after_filter" "around_filter" "skip_before_filter"
    "layout" "require_dependency" "render" "rescue_from" "url_for" "redirect_to"
    "redirect_back" "redirect_back_or_to" "respond_to" "helper" "helper_method" "head"
    "protect_from_forgery" "http_basic_authenticate_with" "rate_limit"
    "allow_unauthenticated_access" "require_authentication" "serialize"
    ; view helpers
    "check_box" "content_for" "form_for" "form_with" "fields_for" "file_field" "hidden_field"
    "image_submit_tag" "label" "link_to" "button_to" "password_field" "radio_button" "submit"
    "text_field" "text_area" "image_tag" "javascript_include_tag" "stylesheet_link_tag"
    "javascript_importmap_tags" "csrf_meta_tags" "csp_meta_tag" "content_tag"
    "turbo_frame_tag" "turbo_stream_from" "dom_id"
    ; activerecord
    "after_create" "after_destroy" "after_save" "after_update" "after_validation"
    "after_commit" "after_create_commit" "after_update_commit" "after_destroy_commit"
    "after_save_commit" "after_initialize" "after_find" "after_touch" "before_create"
    "before_destroy" "before_save" "before_update" "before_validation" "around_save"
    "composed_of" "belongs_to" "has_one" "has_many" "has_and_belongs_to_many"
    "has_one_attached" "has_many_attached" "has_rich_text" "has_secure_password"
    "has_secure_token" "delegated_type" "validate" "validates" "validates_with"
    "validates_numericality_of" "validates_acceptance_of" "validates_associated"
    "validates_confirmation_of" "validates_each" "validates_format_of" "validates_inclusion_of"
    "validates_exclusion_of" "validates_length_of" "validates_presence_of" "validates_size_of"
    "validates_uniqueness_of" "attr_readonly" "accepts_nested_attributes_for" "default_scope"
    "scope" "enum" "normalizes" "encrypts" "store_accessor" "generates_token_for"
    "broadcasts" "broadcasts_to" "broadcasts_refreshes"
    ; activesupport
    "alias_attribute" "delegate" "delegate_missing_to" "cattr_accessor" "mattr_accessor"
    "class_attribute" "included" "class_methods"
    ; migrations
    "create_table" "change_table" "drop_table" "create_join_table" "add_column"
    "remove_column" "rename_column" "change_column" "change_column_default"
    "change_column_null" "add_index" "remove_index" "rename_index" "add_reference"
    "remove_reference" "add_foreign_key" "remove_foreign_key" "add_timestamps"
    "remove_timestamps" "rename_table"
    ; routes
    "resources" "resource" "namespace" "member" "collection" "root" "mount" "concern"
    "concerns"))
  (#set! priority 101))
