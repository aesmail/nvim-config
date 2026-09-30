;; extends

; Same TextMate conventions as Ruby: a type being declared is entity.name.type (underlined),
; the class it extends is entity.other.inherited-class, void is a primitive storage.type.
((class_definition name: (identifier) @type.definition) (#set! priority 101))
((mixin_declaration (identifier) @type.definition) (#set! priority 101))
((enum_declaration name: (identifier) @type.definition) (#set! priority 101))
((superclass . (type_identifier) @type.inherited) (#set! priority 101))
((void_type) @type.builtin (#set! priority 101))
