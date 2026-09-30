;; extends

; TextMate's HTML grammar gives inline tags (meta.tag.inline: a, span, em, br, ...) their own
; colour; the whole tag (brackets, name, attribute names) takes it, attribute values stay strings.

((start_tag "<" @tag.inline . (tag_name) @_name @tag.inline)
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((start_tag (tag_name) @_name ">" @tag.inline)
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((start_tag (tag_name) @_name (attribute (attribute_name) @tag.inline))
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((start_tag (tag_name) @_name (attribute "=" @tag.inline))
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((end_tag "</" @tag.inline . (tag_name) @_name @tag.inline ">" @tag.inline)
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((self_closing_tag "<" @tag.inline . (tag_name) @_name @tag.inline)
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((self_closing_tag (tag_name) @_name "/>" @tag.inline)
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((self_closing_tag (tag_name) @_name (attribute (attribute_name) @tag.inline))
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

((self_closing_tag (tag_name) @_name (attribute "=" @tag.inline))
  (#any-of? @_name "a" "abbr" "b" "bdi" "bdo" "cite" "code" "data" "del" "dfn" "em" "i" "ins"
    "kbd" "mark" "q" "rp" "rt" "ruby" "s" "samp" "small" "span" "strong" "sub" "sup" "time" "u"
    "var" "acronym" "big" "blink" "font" "strike" "tt" "xmp" "area" "br" "wbr")
  (#set! priority 101))

; <!DOCTYPE html> is dimmed (meta.tag.metadata.doctype)
((doctype) @tag.doctype (#set! priority 101))
((doctype "<!" @tag.doctype) (#set! priority 101))
