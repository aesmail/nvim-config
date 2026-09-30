;; extends

; TextMate's Elixir grammar, as Sunburst paints it (colours in colors/sunburst.lua):
; the module being defined is entity.name.type (underlined)
((call
  target: (identifier) @_kw
  (arguments . (alias) @type.definition))
  (#any-of? @_kw "defmodule" "defprotocol" "defimpl")
  (#set! priority 101))

; a module used as a receiver (Enum.map, Repo.all) is entity.other.inherited-class
((dot left: (alias) @type.inherited) (#set! priority 101))

; code inside #{ } is "string.quoted source"; the #{ } themselves belong to the string
((interpolation) @embedded (#set! priority 99))
((interpolation ["#{" "}"] @string) (#set! priority 101))

; the . in post.title / Enum.map is plain punctuation, not keyword.operator
((dot operator: "." @punctuation.plain) (#set! priority 101))
