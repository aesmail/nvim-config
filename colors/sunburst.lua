-- Sunburst
-- Colors come from TextMate's Sunburst.tmTheme (github.com/textmate/themes.tmbundle).
-- The theme's translucent colors (selection, line highlight, invisibles, ...) are
-- pre-blended onto its black background because terminals can't do alpha.
-- Each group notes the TextMate scope it stands in for.

vim.cmd.highlight("clear")
vim.o.background = "dark"
vim.g.colors_name = "sunburst"

local c = {
  -- global settings
  bg = "#000000",
  fg = "#F8F8F8",
  caret = "#A7A7A7",
  selection = "#2C3033", -- #DDF0FF33
  line = "#1A1A1A", -- lineHighlight #FFFFFF1A
  invisibles = "#30363C", -- #CAE2FB3D

  -- scopes
  comment = "#AEAEAE", -- comment (italic)
  constant = "#3387CC", -- constant
  entity = "#89BDFF", -- entity
  keyword = "#E28964", -- keyword
  storage = "#99CF50", -- storage
  string = "#65B042", -- string
  support = "#9B859D", -- support
  variable = "#3E87E3", -- variable
  invalid = "#FD5FF1", -- invalid
  invalid_bg = "#402240", -- invalid.illegal background #562D56BF
  inherited = "#9B5C2E", -- entity.other.inherited-class (italic)
  embedded = "#DAEFA3", -- string.quoted source (code inside #{ })
  escape = "#DDF2A4", -- string constant
  regexp = "#E9C062", -- string.regexp
  regexp_special = "#CF7D34", -- string.regexp constant.character.escape
  support_fn = "#DAD085", -- support.function
  support_const = "#CF6A4C", -- support.constant
  preproc = "#8996A8", -- meta.preprocessor.c
  tag = "#89BDFF", -- meta.tag
  tag_inline = "#E0C589", -- meta.tag.inline
  doctype = "#494949", -- meta.tag.metadata.doctype
  css_tag = "#CDA869",
  css_pseudo = "#8F9D6A",
  css_id = "#8B98AB",
  css_class = "#9B703F",
  css_prop = "#C5AF75",
  css_value = "#F9EE98",
  css_at = "#8693A5",
  css_const = "#DD7B3B",
  diff_header = "#0E2231",
  diff_del = "#420E09",
  diff_change = "#4A410D",
  diff_add = "#253B22",
  heading_fg = "#FEDCC5",
  heading_bg = "#632D04",
  quote = "#E1D4B9",
  quote_bg = "#12100B", -- #FEE09C12
  raw = "#578BB3",

  -- UI greys (TextMate had no equivalents; picked to sit between bg and invisibles)
  float_bg = "#0E0E0E",
  menu_bg = "#141414",
  border = "#3A3A3A",
  gutter = "#4A4A4A",
  split = "#2A2A2A",
  erb_bg = "#0B0B0C", -- "Embedded Source (Bright)" #B1B3BA08, nudged to be visible
}

local groups = {
  -- Editor UI ----------------------------------------------------------------
  Normal = { fg = c.fg, bg = c.bg },
  NormalNC = { link = "Normal" },
  NormalFloat = { fg = c.fg, bg = c.float_bg },
  FloatBorder = { fg = c.border, bg = c.float_bg },
  FloatTitle = { fg = c.entity, bg = c.float_bg, bold = true },
  Cursor = { fg = c.bg, bg = c.caret },
  lCursor = { link = "Cursor" },
  TermCursor = { link = "Cursor" },
  CursorLine = { bg = c.line },
  CursorColumn = { bg = c.line },
  ColorColumn = { bg = c.line },
  LineNr = { fg = c.gutter },
  CursorLineNr = { fg = c.caret, bold = true },
  SignColumn = { bg = c.bg },
  FoldColumn = { fg = c.gutter },
  Folded = { fg = c.comment, bg = c.float_bg, italic = true },
  Visual = { bg = c.selection },
  VisualNOS = { bg = c.selection },
  Search = { fg = c.bg, bg = c.regexp },
  CurSearch = { fg = c.bg, bg = c.keyword, bold = true },
  IncSearch = { link = "CurSearch" },
  Substitute = { fg = c.bg, bg = c.support_const },
  MatchParen = { bg = "#3D4245", bold = true },
  NonText = { fg = c.invisibles },
  Whitespace = { fg = c.invisibles },
  SpecialKey = { fg = c.invisibles },
  EndOfBuffer = { fg = c.bg },
  WinSeparator = { fg = c.split },
  StatusLine = { fg = c.fg, bg = c.line },
  StatusLineNC = { fg = c.comment, bg = c.float_bg },
  TabLine = { fg = c.comment, bg = c.float_bg },
  TabLineSel = { fg = c.fg, bg = c.line, bold = true },
  TabLineFill = { bg = c.float_bg },
  WinBar = { fg = c.comment, bold = true },
  WinBarNC = { fg = c.gutter },
  Pmenu = { fg = c.fg, bg = c.menu_bg },
  PmenuSel = { bg = c.selection, bold = true },
  PmenuSbar = { bg = c.line },
  PmenuThumb = { bg = c.gutter },
  PmenuKind = { fg = c.support },
  PmenuExtra = { fg = c.comment },
  PmenuMatch = { fg = c.keyword, bold = true },
  PmenuMatchSel = { fg = c.keyword, bold = true },
  WildMenu = { link = "PmenuSel" },
  Directory = { fg = c.entity },
  Title = { fg = c.entity, bold = true },
  ErrorMsg = { fg = c.invalid },
  WarningMsg = { fg = c.regexp },
  ModeMsg = { fg = c.fg, bold = true },
  MoreMsg = { fg = c.string },
  Question = { fg = c.string },
  QuickFixLine = { bg = c.selection },
  Conceal = { fg = c.comment },
  SpellBad = { undercurl = true, sp = c.invalid },
  SpellCap = { undercurl = true, sp = c.regexp },
  SpellLocal = { undercurl = true, sp = c.entity },
  SpellRare = { undercurl = true, sp = c.support },
  DiffAdd = { bg = c.diff_add },
  DiffDelete = { fg = "#7A2A22", bg = c.diff_del },
  DiffChange = { bg = "#262106" },
  DiffText = { bg = c.diff_change },
  Added = { fg = c.string },
  Changed = { fg = c.regexp },
  Removed = { fg = c.support_const },
  OkMsg = { fg = c.string },

  -- Diagnostics
  DiagnosticError = { fg = c.invalid },
  DiagnosticWarn = { fg = c.regexp },
  DiagnosticInfo = { fg = c.entity },
  DiagnosticHint = { fg = c.comment },
  DiagnosticOk = { fg = c.string },
  DiagnosticUnderlineError = { undercurl = true, sp = c.invalid },
  DiagnosticUnderlineWarn = { undercurl = true, sp = c.regexp },
  DiagnosticUnderlineInfo = { undercurl = true, sp = c.entity },
  DiagnosticUnderlineHint = { undercurl = true, sp = c.comment },
  DiagnosticDeprecated = { strikethrough = true, sp = c.invalid },
  DiagnosticUnnecessary = { fg = c.gutter },
  LspReferenceText = { bg = c.split },
  LspReferenceRead = { bg = c.split },
  LspReferenceWrite = { bg = c.split, underline = true },
  LspInlayHint = { fg = "#5A5A5A", italic = true },
  LspSignatureActiveParameter = { fg = c.regexp, bold = true },
  LspCodeLens = { fg = c.gutter },

  -- Legacy syntax groups (fallback for filetypes without a treesitter parser)
  Comment = { fg = c.comment, italic = true }, -- comment
  Constant = { fg = c.constant }, -- constant
  String = { fg = c.string }, -- string
  Character = { fg = c.string },
  Number = { fg = c.constant },
  Boolean = { fg = c.constant },
  Float = { fg = c.constant },
  Identifier = { fg = c.variable }, -- variable
  Function = { fg = c.entity }, -- entity.name.function
  Statement = { fg = c.keyword }, -- keyword
  Conditional = { fg = c.keyword },
  Repeat = { fg = c.keyword },
  Label = { fg = c.keyword },
  Operator = { fg = c.keyword }, -- keyword.operator
  Keyword = { fg = c.keyword },
  Exception = { fg = c.keyword },
  PreProc = { fg = c.preproc }, -- meta.preprocessor
  Include = { fg = c.keyword },
  Define = { fg = c.preproc },
  Macro = { fg = c.preproc },
  PreCondit = { fg = c.preproc },
  Type = { fg = c.storage }, -- storage.type
  StorageClass = { fg = c.storage }, -- storage.modifier
  Structure = { fg = c.storage },
  Typedef = { fg = c.storage },
  Special = { fg = c.support_fn }, -- support.function
  SpecialChar = { fg = c.escape }, -- string constant
  Tag = { fg = c.tag },
  Delimiter = { fg = c.fg },
  SpecialComment = { fg = c.comment, italic = true },
  Debug = { fg = c.support_const },
  Underlined = { underline = true },
  Error = { fg = c.invalid, bg = c.invalid_bg }, -- invalid.illegal
  Todo = { fg = c.bg, bg = c.regexp, bold = true },

  -- Treesitter ---------------------------------------------------------------
  -- Empty group: a capture linked here shows whatever is underneath it, the way
  -- text with no theme rule did in TextMate (e.g. calls inside #{ }).
  SunburstNone = {},

  ["@variable"] = {}, -- locals have no scope colour in TextMate
  ["@variable.builtin"] = { fg = c.variable }, -- variable.language (self)
  ["@variable.parameter"] = { fg = c.variable }, -- variable.parameter / variable.other.block
  ["@variable.parameter.builtin"] = { fg = c.variable },
  ["@variable.member"] = { fg = c.variable }, -- variable.other.readwrite.instance (@ivar)

  ["@constant"] = { fg = c.variable }, -- variable.other.constant (FOO)
  ["@constant.builtin"] = { fg = c.constant }, -- constant.language (nil)
  ["@constant.macro"] = { fg = c.constant },

  ["@module"] = { fg = c.support }, -- support.class
  ["@module.builtin"] = { fg = c.support },
  ["@label"] = { fg = c.keyword },

  ["@string"] = { fg = c.string },
  ["@string.documentation"] = { fg = c.comment, italic = true },
  ["@string.regexp"] = { fg = c.regexp },
  ["@string.escape"] = { fg = c.escape },
  ["@string.special"] = { fg = c.escape },
  ["@string.special.symbol"] = { fg = c.constant }, -- constant.other.symbol (:sym, key:)
  ["@string.special.url"] = { fg = c.string, underline = true },
  ["@string.special.path"] = { fg = c.string },
  ["@character"] = { fg = c.string },
  ["@character.special"] = { fg = c.constant }, -- constant.character.entity (&amp;)

  ["@boolean"] = { fg = c.constant },
  ["@number"] = { fg = c.constant },
  ["@number.float"] = { fg = c.constant },

  ["@type"] = { fg = c.variable }, -- variable.other.constant (Ruby constants)
  ["@type.builtin"] = { fg = c.storage }, -- storage.type
  ["@type.definition"] = { fg = c.entity, underline = true }, -- entity.name.type
  ["@type.support"] = { fg = c.support }, -- support.class (User.find, Foo::)
  ["@type.inherited"] = { fg = c.inherited, italic = true }, -- entity.other.inherited-class
  ["@attribute"] = { fg = c.support },
  ["@attribute.builtin"] = { fg = c.support },
  ["@property"] = {},

  ["@function"] = { fg = c.entity }, -- entity.name.function
  ["@function.builtin"] = { fg = c.support_fn }, -- support.function
  ["@function.call"] = { link = "SunburstNone" },
  ["@function.method"] = { fg = c.entity },
  ["@function.method.call"] = { link = "SunburstNone" },
  ["@function.macro"] = { fg = c.support_fn },
  ["@function.support"] = { fg = c.support_fn }, -- support.function.kernel / *.rails
  ["@constructor"] = { link = "SunburstNone" },

  ["@keyword"] = { fg = c.keyword }, -- keyword.control
  ["@keyword.special"] = { fg = c.keyword }, -- keyword.other.special-method (new, include, ...)
  ["@keyword.directive"] = { fg = c.preproc },
  ["@operator"] = { fg = c.keyword }, -- keyword.operator

  ["@punctuation"] = {},
  ["@punctuation.delimiter"] = {},
  ["@punctuation.bracket"] = {},
  ["@punctuation.plain"] = { fg = c.fg },
  ["@punctuation.special"] = { fg = c.keyword },

  ["@comment"] = { fg = c.comment, italic = true },
  ["@comment.documentation"] = { fg = c.comment, italic = true },
  ["@comment.error"] = { fg = c.bg, bg = c.invalid, bold = true },
  ["@comment.warning"] = { fg = c.bg, bg = c.regexp, bold = true },
  ["@comment.todo"] = { fg = c.bg, bg = c.regexp, bold = true },
  ["@comment.note"] = { fg = c.bg, bg = c.entity, bold = true },

  ["@embedded"] = { fg = c.embedded }, -- string.quoted source (#{ ... })

  ["@tag"] = { fg = c.tag }, -- meta.tag
  ["@tag.builtin"] = { fg = c.tag },
  ["@tag.attribute"] = { fg = c.tag },
  ["@tag.delimiter"] = { fg = c.tag },
  ["@tag.inline"] = { fg = c.tag_inline }, -- meta.tag.inline (a, span, em, ...)
  ["@tag.doctype"] = { fg = c.doctype }, -- meta.tag.metadata.doctype

  ["@markup.heading"] = { fg = c.heading_fg, bg = c.heading_bg }, -- markup.heading
  ["@markup.strong"] = { fg = c.regexp, bold = true }, -- markup.bold
  ["@markup.italic"] = { fg = c.regexp, italic = true }, -- markup.italic
  ["@markup.underline"] = { fg = "#E18964", underline = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.quote"] = { fg = c.quote, bg = c.quote_bg, italic = true },
  ["@markup.list"] = { fg = c.quote },
  ["@markup.raw"] = { fg = c.raw },
  ["@markup.link"] = { fg = c.entity },
  ["@markup.link.label"] = { fg = c.entity },
  ["@markup.link.url"] = { fg = c.string, underline = true },
  ["@markup.math"] = { fg = c.constant },

  ["@diff.plus"] = { fg = c.string },
  ["@diff.minus"] = { fg = c.support_const },
  ["@diff.delta"] = { fg = c.regexp },

  -- Ruby
  ["@label.ruby"] = { fg = c.string }, -- heredoc delimiters are part of the string
  ["@punctuation.special.ruby"] = { fg = c.string }, -- #{ } punctuation sits in the string
  ["@keyword.directive.ruby"] = { fg = c.comment, italic = true }, -- shebang
  ["@function.builtin.ruby"] = { fg = c.keyword }, -- attr_accessor/include: special-method

  -- ERB: delimiters are plain; embedded code gets a faint background
  ["@keyword.embedded_template"] = { fg = c.fg },
  ["@embedded.erb"] = { bg = c.erb_bg },

  -- HTML: text inside <h1>/<strong>/<a> isn't styled in TextMate
  ["@markup.heading.html"] = { bold = true },
  ["@markup.heading.1.html"] = { bold = true },
  ["@markup.heading.2.html"] = { bold = true },
  ["@markup.heading.3.html"] = { bold = true },
  ["@markup.heading.4.html"] = { bold = true },
  ["@markup.heading.5.html"] = { bold = true },
  ["@markup.heading.6.html"] = { bold = true },
  ["@markup.strong.html"] = { bold = true },
  ["@markup.italic.html"] = { italic = true },
  ["@markup.link.label.html"] = { link = "SunburstNone" },
  ["@markup.raw.html"] = { link = "SunburstNone" },
  ["@operator.html"] = { fg = c.tag }, -- the = in attributes is part of meta.tag
  ["@string.special.url.html"] = { fg = c.string }, -- href values are plain strings
  ["@constant.html"] = { fg = c.doctype },

  -- CSS
  ["@tag.css"] = { fg = c.css_tag },
  ["@type.css"] = { fg = c.css_class },
  ["@constant.css"] = { fg = c.css_id },
  ["@attribute.css"] = { fg = c.css_pseudo },
  ["@property.css"] = { fg = c.css_prop },
  ["@keyword.directive.css"] = { fg = c.css_at },
  ["@string.css"] = { fg = c.css_value },
  ["@number.css"] = { fg = c.css_const },
  ["@number.float.css"] = { fg = c.css_const },
  ["@function.css"] = { fg = c.css_pseudo },

  -- YAML / JSON keys
  ["@property.yaml"] = { fg = c.entity }, -- entity.name.tag.yaml
  ["@property.json"] = { fg = c.support }, -- support.type.property-name.json

  -- Regular expressions (injected into Ruby/JS regex literals)
  ["@string.regexp.regex"] = { fg = c.regexp },
  ["@string.escape.regex"] = { fg = c.regexp_special },
  ["@constant.regex"] = { fg = c.regexp_special },
  ["@operator.regex"] = { fg = c.regexp_special },
  ["@number.regex"] = { fg = c.regexp_special },
  ["@property.regex"] = { fg = c.regexp_special },
  ["@variable.builtin.regex"] = { fg = c.regexp_special },
  ["@punctuation.bracket.regex"] = { fg = c.regexp_special },
  ["@punctuation.delimiter.regex"] = { fg = c.regexp_special },

  -- Plugins ------------------------------------------------------------------
  -- Telescope
  TelescopeNormal = { link = "NormalFloat" },
  TelescopeBorder = { link = "FloatBorder" },
  TelescopeTitle = { fg = c.entity, bold = true },
  TelescopeSelection = { bg = c.selection, bold = true },
  TelescopeSelectionCaret = { fg = c.keyword, bg = c.selection },
  TelescopeMatching = { fg = c.keyword, bold = true },
  TelescopePromptPrefix = { fg = c.keyword },

  -- Neo-tree
  NeoTreeNormal = { fg = c.fg, bg = "#050505" },
  NeoTreeNormalNC = { link = "NeoTreeNormal" },
  NeoTreeEndOfBuffer = { fg = "#050505", bg = "#050505" },
  NeoTreeWinSeparator = { fg = c.split, bg = c.bg },
  NeoTreeRootName = { fg = c.keyword, bold = true },
  NeoTreeDirectoryName = { fg = c.entity },
  NeoTreeDirectoryIcon = { fg = c.entity },
  NeoTreeFileNameOpened = { fg = c.fg, bold = true },
  NeoTreeIndentMarker = { fg = c.split },
  NeoTreeGitAdded = { fg = c.string },
  NeoTreeGitModified = { fg = c.regexp },
  NeoTreeGitDeleted = { fg = c.support_const },
  NeoTreeGitUntracked = { fg = c.support },
  NeoTreeGitIgnored = { fg = c.gutter },
  NeoTreeGitConflict = { fg = c.invalid, bold = true },
  NeoTreeDotfile = { fg = c.comment },

  -- Gitsigns
  GitSignsAdd = { fg = c.string },
  GitSignsChange = { fg = c.regexp },
  GitSignsDelete = { fg = c.support_const },
  GitSignsAddInline = { bg = c.diff_add },
  GitSignsChangeInline = { bg = c.diff_change },
  GitSignsDeleteInline = { bg = c.diff_del },
  GitSignsAddPreview = { bg = c.diff_add },
  GitSignsDeletePreview = { bg = c.diff_del },
  GitSignsCurrentLineBlame = { fg = c.gutter, italic = true },

  -- which-key
  WhichKey = { fg = c.keyword },
  WhichKeyGroup = { fg = c.entity },
  WhichKeyDesc = { fg = c.fg },
  WhichKeySeparator = { fg = c.comment },
  WhichKeyNormal = { link = "NormalFloat" },
  WhichKeyBorder = { link = "FloatBorder" },
  WhichKeyTitle = { link = "FloatTitle" },

  -- blink.cmp
  BlinkCmpMenu = { link = "Pmenu" },
  BlinkCmpMenuBorder = { fg = c.border, bg = c.menu_bg },
  BlinkCmpMenuSelection = { link = "PmenuSel" },
  BlinkCmpLabelMatch = { fg = c.keyword, bold = true },
  BlinkCmpLabelDetail = { fg = c.comment },
  BlinkCmpLabelDescription = { fg = c.comment },
  BlinkCmpSource = { fg = c.gutter },
  BlinkCmpDoc = { link = "NormalFloat" },
  BlinkCmpDocBorder = { link = "FloatBorder" },
  BlinkCmpSignatureHelp = { link = "NormalFloat" },
  BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
  BlinkCmpKind = { fg = c.support },
  BlinkCmpKindSnippet = { fg = c.regexp },
  BlinkCmpKindKeyword = { fg = c.keyword },
  BlinkCmpKindFunction = { fg = c.entity },
  BlinkCmpKindMethod = { fg = c.entity },
  BlinkCmpKindConstructor = { fg = c.keyword },
  BlinkCmpKindClass = { fg = c.support },
  BlinkCmpKindModule = { fg = c.support },
  BlinkCmpKindConstant = { fg = c.constant },
  BlinkCmpKindVariable = { fg = c.variable },
  BlinkCmpKindField = { fg = c.variable },
  BlinkCmpKindProperty = { fg = c.variable },
  BlinkCmpKindText = { fg = c.comment },
  BlinkCmpKindFile = { fg = c.string },
  BlinkCmpKindFolder = { fg = c.entity },

  -- lazy.nvim
  LazyH1 = { fg = c.bg, bg = c.keyword, bold = true },
  LazyButton = { bg = c.line },
  LazyButtonActive = { fg = c.bg, bg = c.entity, bold = true },
  LazySpecial = { fg = c.keyword },
}

for name, spec in pairs(groups) do
  vim.api.nvim_set_hl(0, name, spec)
end

-- ruby-lsp's semantic tokens would paint over the TextMate-style colours above
-- (TextMate never distinguished e.g. local variables from method calls).
for _, name in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, name, {})
end

-- :terminal colours (rails console, lazygit, ...)
local term = {
  c.bg, c.support_const, c.string, c.regexp, c.constant, c.support, c.entity, c.comment,
  c.gutter, c.keyword, c.storage, c.support_fn, c.variable, c.invalid, c.embedded, c.fg,
}
for i, color in ipairs(term) do
  vim.g["terminal_color_" .. (i - 1)] = color
end
