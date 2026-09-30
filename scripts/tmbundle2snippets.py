#!/usr/bin/env python3
"""Convert TextMate's Ruby and Ruby on Rails bundles into VS Code-format snippets for LuaSnip.

    git clone https://github.com/textmate/ruby.tmbundle
    git clone https://github.com/textmate/ruby-on-rails-tmbundle
    scripts/tmbundle2snippets.py ruby.tmbundle ruby-on-rails-tmbundle snippets/

TextMate snippet syntax is almost LSP/VS Code syntax. The differences handled here:
  * shell interpolation (`...`)          -> replaced with its (default) output
  * Oniguruma regex / (?1:..) / \\u$1    -> JavaScript regex + VS Code format (LuaSnip needs jsregexp)
  * scope selectors                      -> snippet "filetypes" (see lua/config/snippet_filetypes.lua)
The Rails bundle was last updated in 2019 (Rails 2/3 era), so snippets for APIs Rails has
since removed are dropped, and the rest are modernised (before_action, `key:` hashes, <%= blocks).

Both bundles: "Permission to copy, use, modify, sell and distribute this software is granted."
"""

import json
import plistlib
import re
import sys
from pathlib import Path

# --- Rails: snippets for APIs that no longer exist --------------------------------------------

RAILS_DROP = {
    "assert_rjs", "verify — render", "verify — redirect", "xhr delete", "xhr get", "xhr post",
    "xhr put", "returning do |variable| … end", "find(:all)", "find(:first)", "find(:last)",
    "map.catch_all", "map.named_route", "map.resource", "map.resources", "map.with_options",
    "match", "render (update)", "render (text)", "render (text, layout)",
    "render (text, layout => true)", "render (text, status)", "render (nothing)",
    "render (nothing, status)", "render (file, use_full_path)", "render (inline, type)",
    "link_to_function", "form_for with errors", "scoped_by", "Create sweeper class",
    "caches_action", "Create resources controller class", "def create - resource",
    "def test_should_get_action", "def test_should_post_action", "Drop / Create Table",
    "Remove / Add Column", "assert(var = assigns(:var))", "respond_to", "respond_with",
}

# --- Rewrites where the original can't be converted mechanically, or targets removed APIs --------

OVERRIDES = {
    ("ruby", "begin … rescue … end"): "begin\n\t${3:$TM_SELECTED_TEXT}\nrescue ${1:Exception}${2/.+/ => /}${2:e}\n\t$0\nend\n",
    ("rails", "Create functional test class"): 'require "test_helper"\n\nclass ${1:Model}ControllerTest < ActionDispatch::IntegrationTest\n\ttest$0\nend',
    ("rails", "find_each"): "find_each do |${1:record}|\n\t$0\nend",
    ("rails", "find_in_batches"): "find_in_batches do |${1:batch}|\n\t$1.each do |${2:record}|\n\t\t$0\n\tend\nend",
    ("rails", "redirect_to :back"): "redirect_back_or_to ${1:root_path}",
    ("rails", "javascript_include_tag"): '<%= javascript_include_tag "${1:application}"${2:, "data-turbo-track": "reload"} %>',
    ("rails", "stylesheet_link_tag"): '<%= stylesheet_link_tag "${1:application}"${2:, "data-turbo-track": "reload"} %>',
    ("rails", "default_scope"): "default_scope { ${1:order(${2:created_at: :desc})} }",
    ("rails", "scope"): "scope :${1:name}, -> { ${2:where(${3:field}: ${4:value})} }",
    ("rails", "scope lambda"): "scope :${1:name}, ->(${2:param}) { ${3:where(${4:field}: ${5:$2})} }",
    ("rails", "scope with extension"): "scope :${1:name}, -> { ${2:where(${3:field}: ${4:value})} } do\n\tdef ${5:method_name}\n\t\t$0\n\tend\nend",
    ("rails", "<%= Fixtures.identify(:symbol) %>"): "<%= ActiveRecord::FixtureSet.identify(:${1:name}) %>",
}

# Additions for things the 2019 bundle predates (clearly labelled in the completion menu)
ADDITIONS = {
    "rails": [
        ("ba", "before_action", "before_action :${1:method}${2:, only: %i[ ${3:show edit update destroy} ]}"),
    ],
    "rails_controller": [
        ("pe", "params.expect (strong parameters)", "def ${1:model}_params\n\tparams.expect(${1}: [ ${2::name} ])\nend"),
    ],
    "eruby": [
        ("fw", "form_with", "<%= form_with(model: ${1:@model}) do |${2:form}| %>\n\t$0\n<% end %>"),
    ],
}

ERB_VARS = {
    "TM_RAILS_TEMPLATE_START_RUBY_EXPR": "<%= ",
    "TM_RAILS_TEMPLATE_END_RUBY_EXPR": " %>",
    "TM_RAILS_TEMPLATE_START_RUBY_INLINE": "<% ",
    "TM_RAILS_TEMPLATE_END_RUBY_INLINE": " %>",
    "TM_RAILS_TEMPLATE_END_RUBY_BLOCK": "<% end %>",
}


class Unconvertible(Exception):
    pass


# --- Regex transformations ----------------------------------------------------------------------

# Transformations whose Oniguruma regex/format has no direct JS equivalent: (regex, format) -> (regex, format)
KNOWN_TRANSFORMS = {
    # snake_case -> CamelCase
    (r"[[:alpha:]]+|(_)", r"(?1::\u$0)"): (r"([a-zA-Z]+)|_", r"${1:/capitalize}"),
    # snake_case -> Title Words
    (r"[[:alpha:]]+|(_)", r"(?1: :\u$0)"): (r"([a-zA-Z]+)|(_)", r"${1:/capitalize}${2:+ }"),
    # my_file.rb -> MyFile
    (r"(?:\A|_)([A-Za-z0-9]+)(?:\.rb)?", r"(?2::\u$1)"): (r"(?:^|_)([A-Za-z0-9]+)(?:\.rb)?", r"${1:/capitalize}"),
    (r"(?:\A|_)([A-Za-z0-9]+)(?:\.[a-z]+)*", r"(?2::\u$1)"): (r"(?:^|_)([A-Za-z0-9]+)(?:\.[a-z]+)*", r"${1:/capitalize}"),
    # library_name -> LibraryName
    (r"([\w&&[^_]]+)|.", r"\u$1"): (r"([a-zA-Z0-9]+)|.", r"${1:/capitalize}"),
    # Model -> model
    (r".", r"\l$0"): (r"(.)", r"${1:/downcase}"),
}


def read_until_slash(s, i):
    out = []
    while s[i] != "/":
        if s[i] == "\\":
            out.append(s[i : i + 2])
            i += 2
        else:
            out.append(s[i])
            i += 1
    return "".join(out), i + 1


def count_groups(rx):
    n, i = 0, 0
    while i < len(rx):
        ch = rx[i]
        if ch == "\\":
            i += 2
            continue
        if ch == "[":
            i += 1
            while rx[i] != "]":
                i += 2 if rx[i] == "\\" else 1
        elif ch == "(" and (rx[i + 1] != "?" or (rx[i + 2] == "<" and rx[i + 3] not in "=!")):
            n += 1
        i += 1
    return n


def escape_text(s, extra=""):
    return "".join("\\" + ch if ch in "$}\\/" + extra else ch for ch in s)


def read_conditional(fmt, i):
    """fmt[i:] is just after '(?N:'. Returns (if_text, else_text|None, index after ')')."""
    depth, parts, cur = 0, [], []
    while True:
        ch = fmt[i]
        if ch == "\\":
            cur.append(fmt[i : i + 2])
            i += 2
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            if depth == 0:
                break
            depth -= 1
        elif ch == ":" and depth == 0 and not parts:
            parts.append("".join(cur))
            cur = []
            i += 1
            continue
        cur.append(ch)
        i += 1
    parts.append("".join(cur))
    if len(parts) == 1:
        return parts[0], None, i + 1
    return parts[0], parts[1], i + 1


def plain_format_text(fmt):
    """A conditional branch may only hold literal text in VS Code syntax."""
    if re.search(r"\$\d|\\[uUlL]|\(\?", fmt):
        raise Unconvertible(f"format branch with references: {fmt!r}")
    return re.sub(r"\\(.)", lambda m: {"n": "\n", "t": "\t"}.get(m.group(1), m.group(1)), fmt)


def convert_format(fmt, ngroups):
    """TextMate format string -> VS Code format string. The regex gets wrapped in one extra
    group (so TextMate's $0 becomes $1), hence every group reference shifts by one."""
    out, i = [], 0
    while i < len(fmt):
        if fmt.startswith("(?", i):
            m = re.match(r"\(\?(\d+):", fmt[i:])
            n = int(m.group(1))
            if_text, else_text, i = read_conditional(fmt, i + m.end())
            if_text = plain_format_text(if_text)
            else_text = None if else_text is None else plain_format_text(else_text)
            if n > ngroups:  # references a group that doesn't exist: always the else branch
                out.append(escape_text(else_text or ""))
            elif else_text is None:
                out.append("${%d:+%s}" % (n + 1, escape_text(if_text)))
            else:
                out.append("${%d:?%s:%s}" % (n + 1, escape_text(if_text, ":"), escape_text(else_text)))
            continue
        ch = fmt[i]
        if ch == "\\":
            nxt = fmt[i + 1]
            if nxt in "uUlL":
                raise Unconvertible(f"case conversion in {fmt!r}")
            out.append({"n": "\n", "t": "\t"}.get(nxt, escape_text(nxt)))
            i += 2
        elif ch == "$" and re.match(r"\$\d", fmt[i:]):
            m = re.match(r"\$(\d+)", fmt[i:])
            out.append("$%d" % (int(m.group(1)) + 1))
            i += m.end()
        else:
            out.append(escape_text(ch))
            i += 1
    return "".join(out)


def convert_transform(var, regex, fmt, flags):
    if (var, regex, fmt) == ("TM_FILENAME", r"\.\w+", ""):
        return "$TM_FILENAME_BASE"  # VS Code syntax doesn't allow an empty replacement
    if (regex, fmt) in KNOWN_TRANSFORMS:
        regex, fmt = KNOWN_TRANSFORMS[(regex, fmt)]
        return "${%s/%s/%s/%s}" % (var, regex, fmt, flags)
    if r"\g<var>" in regex:
        # TextMate's "only add |pipes| if the block variable is valid" idiom:
        # (?1:X) means "X when the tab stop holds a variable list".
        if_text, _, _ = read_conditional(fmt, len("(?1:"))
        return "${%s/(.+)/%s/}" % (var, escape_text(plain_format_text(if_text)))
    if re.search(r"\[\[:|\\[Azg]|&&|\(\?<[a-z]", regex):
        raise Unconvertible(f"regex {regex!r}")
    return "${%s/(%s)/%s/%s}" % (var, regex, convert_format(fmt, count_groups(regex)), flags)


def convert_transforms(content):
    out, i = [], 0
    for m in re.finditer(r"\$\{(\d+|[A-Z_]+)/", content):
        if m.start() < i:
            continue
        regex, j = read_until_slash(content, m.end())
        fmt, j = read_until_slash(content, j)
        k = content.index("}", j)
        out.append(content[i : m.start()])
        out.append(convert_transform(m.group(1), regex, fmt, content[j:k]))
        i = k + 1
    out.append(content[i:])
    return "".join(out)


# --- Content fixes --------------------------------------------------------------------------------

SNIPPET_PAREN = re.compile(r'`"\$TM_BUNDLE_SUPPORT/bin/snippet_paren\.rb"( end)?`')


def convert_shell(content):
    content = SNIPPET_PAREN.sub(lambda m: ")" if m.group(1) else "(", content)
    content = content.replace("`[[ $TM_LINE_INDEX != 0 ]] && echo; echo`", "")
    content = content.replace("${TM_RUBY_SWITCHES}", "")  # a TextMate preference, unset by default
    if "`" in content.replace("\\`", "") and "$TM_" in content:
        raise Unconvertible("shell code")
    return content


def modernise_ruby(content):
    # :key => value  ->  key: value   (also for ${1:key} placeholders)
    content = re.sub(r"(?<![\w:]):([a-z_]\w*[?!]?) => ", r"\1: ", content)
    content = re.sub(r"(?<=\$\{\d:):([a-z_]\w*) => ", r"\1: ", content)
    content = re.sub(r"(?<![\w:]):(\$\{\d+:[a-z_]\w*\}) => ", r"\1: ", content)
    return content


def modernise_rails(content):
    for var, value in ERB_VARS.items():
        content = content.replace("${%s}" % var, value).replace("$" + var, value)
    content = content.replace("before_filter", "before_action").replace("after_filter", "after_action")
    content = content.replace("-%>", "%>")
    # block helpers need <%= since Rails 3
    content = re.sub(r"<% (?=(?:f\.)?(?:form_for|form_tag|fields_for)\b)", "<%= ", content)
    content = content.replace("git://github.com/", "https://github.com/")
    # format validators reject ^/$ (multiline anchors) since Rails 4
    content = content.replace("/${2:^[", "/${2:\\A[").replace("]+\\$}/", "]+\\z}/")
    # :disable_with was a rails-ujs option; Turbo spells it data-turbo-submits-with
    content = re.sub(r""":?disable_with(?: =>|:) (['"])(\$\{\d+:[^}]*\})\1""", r'data: { turbo_submits_with: "\2" \\}', content)
    return content


# --- Scopes -> snippet filetypes -----------------------------------------------------------------


def rails_targets(scope):
    if "rjs" in scope:
        return []
    if "source.yaml" in scope:
        return ["rails_fixtures"]
    if "meta.rails.migration" in scope:
        return ["rails_migration"]
    for kind in ("model", "controller", "routes"):
        if f"meta.rails.{kind}" in scope:
            return [f"rails_{kind}"]
    targets = []
    if "source.ruby" in scope:
        targets.append("rails")
    if "text.html.erb" in scope:
        targets.append("eruby")
    return targets


def load_snippets(bundle):
    for path in sorted(Path(bundle, "Snippets").iterdir()):
        with path.open("rb") as f:
            snippet = plistlib.load(f)
        if snippet.get("tabTrigger"):
            yield snippet


def main(ruby_bundle, rails_bundle, out_dir):
    collections, problems, dropped = {}, [], set()

    def add(ft, trigger, name, body, source):
        # The key is the snippet's name in LuaSnip (and in the menu for ambiguous triggers).
        coll = collections.setdefault(ft, {})
        key, n = name, 2
        while key in coll:
            key, n = f"{name} ({n})", n + 1
        coll[key] = {"prefix": trigger, "body": body.split("\n"), "description": f"{source}: {name}"}

    for bundle, kind in ((ruby_bundle, "ruby"), (rails_bundle, "rails")):
        source = "TextMate " + ("Ruby" if kind == "ruby" else "Ruby on Rails") + " bundle"
        for snip in load_snippets(bundle):
            name, trigger, scope = snip["name"], snip["tabTrigger"], snip.get("scope", "")
            if kind == "rails" and name in RAILS_DROP:
                dropped.add(name)
                continue
            targets = ["ruby"] if kind == "ruby" else rails_targets(scope)
            if not targets:
                continue
            content = OVERRIDES.get((kind, name))
            try:
                if content is None:
                    content = convert_shell(snip["content"])
                    if kind == "rails":
                        content = modernise_rails(content)
                    content = convert_transforms(modernise_ruby(content))
            except Unconvertible as e:
                problems.append(f"{kind}: {name} [{trigger}]: {e}")
                continue
            for ft in targets:
                add(ft, trigger, name, content, source)

    for ft, items in ADDITIONS.items():
        for trigger, name, body in items:
            add(ft, trigger, name, body, "Added (Rails 7/8)")

    missing = RAILS_DROP - dropped
    if missing:
        problems.append(f"drop list entries not found: {sorted(missing)}")
    if problems:
        sys.exit("Could not convert:\n  " + "\n  ".join(problems))

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    package = {"name": "textmate-ruby-rails", "contributes": {"snippets": []}}
    for ft in sorted(collections):
        (out / f"{ft}.json").write_text(json.dumps(collections[ft], indent=2, ensure_ascii=False) + "\n")
        package["contributes"]["snippets"].append({"language": [ft], "path": f"./{ft}.json"})
        print(f"{ft:18} {len(collections[ft]):4} snippets")
    (out / "package.json").write_text(json.dumps(package, indent=2) + "\n")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
