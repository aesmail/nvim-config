-- Decides which snippet collections apply where, mimicking TextMate's scope selectors:
--   ruby              source.ruby                          every Ruby file
--   rails             source.ruby.rails                    Ruby files inside a Rails app
--   rails_model       meta.rails.model                     app/models/**
--   rails_controller  meta.rails.controller                app/controllers/**
--   rails_routes      meta.rails.routes                    config/routes.rb, config/routes/**
--   rails_migration   meta.rails.migration(.create_table)  db/migrate/**
--   rails_fixtures    source.yaml (fixtures)               test/fixtures/**
--   eruby             text.html.erb.rails                  ERB templates
--   elixir            source.elixir                        Elixir files
--   heex, eelixir     text.html.elixir                     HEEx / EEx templates
-- Inside <% %> in an ERB file the Ruby + Rails snippets apply instead, and inside {...} or
-- <%= %> in a HEEx/EEx template the Elixir ones, as they did in TextMate.
local M = {}

local rails_scopes = {
  { "/app/models/", "rails_model" },
  { "/app/controllers/", "rails_controller" },
  { "/config/routes", "rails_routes" },
  { "/db/migrate/", "rails_migration" },
  { "/test/fixtures/", "rails_fixtures" },
}

-- template filetype -> language of the code embedded in it
local embedded = { eruby = "ruby", heex = "elixir", eelixir = "elixir" }

local function rails_root(buf)
  local cached = vim.b[buf].snippet_rails_root
  if cached == nil then
    cached = require("config.rails").rails_root(buf) or false
    vim.b[buf].snippet_rails_root = cached
  end
  return cached
end

local function rails_filetypes(buf)
  local fts = {}
  if not rails_root(buf) then return fts end
  local path = vim.api.nvim_buf_get_name(buf)
  for _, scope in ipairs(rails_scopes) do
    if path:find(scope[1], 1, true) then table.insert(fts, scope[2]) end
  end
  if vim.bo[buf].filetype ~= "yaml" then table.insert(fts, "rails") end
  return fts
end

local function in_embedded_code(buf, lang)
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return false end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local tree = parser:language_for_range({ row - 1, col, row - 1, col })
  return tree and tree:lang() == lang
end

--- Snippet filetypes to *load* for a buffer (LuaSnip's load_ft_func).
function M.for_buffer(buf)
  local ft = vim.bo[buf].filetype
  local fts = { ft }
  if ft == "ruby" or ft == "eruby" or ft == "yaml" then vim.list_extend(fts, rails_filetypes(buf)) end
  if embedded[ft] then table.insert(fts, embedded[ft]) end
  return fts
end

--- Snippet filetypes *active* at the cursor (LuaSnip's ft_func).
function M.at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft == "ruby" or ft == "yaml" then
    return vim.list_extend({ ft }, rails_filetypes(buf))
  elseif embedded[ft] then
    local lang = embedded[ft]
    if not in_embedded_code(buf, lang) then return { ft } end
    if lang == "ruby" and rails_root(buf) then return { "ruby", "rails" } end
    return { lang }
  end
  return { ft }
end

return M
