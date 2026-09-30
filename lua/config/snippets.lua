-- TextMate-style snippet expansion for <Tab>: expand the trigger before the cursor, and when
-- several snippets share it (cla, mod, lt, t., asrt, ...) pick one from a menu, like TextMate did.
local M = {}

local function matching_snippets(line_to_cursor)
  local ls = require("luasnip")
  local found, seen = {}, {}
  for _, ft in ipairs(require("luasnip.util.util").get_snippet_filetypes()) do
    for _, snip in ipairs(ls.get_snippets(ft)) do
      if not seen[snip] and not snip.invalidated then
        seen[snip] = true
        local params = snip:matches(line_to_cursor)
        if params then table.insert(found, { snip = snip, params = params }) end
      end
    end
  end
  return found
end

local function expand_at(choice, row, col)
  local trigger = choice.params.trigger or choice.snip.trigger
  require("luasnip").snip_expand(choice.snip, {
    expand_params = choice.params,
    pos = { row, col },
    clear_region = choice.params.clear_region or { from = { row, col - #trigger }, to = { row, col } },
  })
end

--- Called from an <expr> mapping, so the actual expansion is scheduled.
--- Returns true when there was a trigger before the cursor.
function M.expand()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local found = matching_snippets(vim.api.nvim_get_current_line():sub(1, col))
  if #found == 0 then return false end

  vim.schedule(function()
    if #found == 1 then return expand_at(found[1], row, col) end
    vim.ui.select(found, {
      prompt = "Snippet",
      format_item = function(item) return item.snip.name end,
    }, function(choice)
      if choice then expand_at(choice, row, col) end
    end)
  end)
  return true
end

--- Language servers ship snippets too (Dart: stless, stful, stanim, ...). When the word before
--- the cursor is exactly such a snippet's trigger, <Tab> expands it like a LuaSnip trigger.
function M.accept_lsp_snippet(cmp)
  if not cmp.is_menu_visible() then return false end
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local word = vim.api.nvim_get_current_line():sub(1, col):match("[%w_]+$")
  if not word then return false end
  for i, item in ipairs(cmp.get_items()) do
    if item.kind == vim.lsp.protocol.CompletionItemKind.Snippet and item.source_id == "lsp"
      and (item.filterText or item.label) == word then
      cmp.accept({ index = i })
      return true
    end
  end
  return false
end

return M
