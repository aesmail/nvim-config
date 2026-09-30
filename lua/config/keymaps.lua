-- General keymaps. Plugin-specific keymaps live next to their plugin spec in lua/plugins/.
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Delete other buffers" })

-- Files
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qall<CR>", { desc = "Quit all" })

-- Keep the selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines (like TextMate's ⌃⌘↑/↓)
map("n", "<A-j>", "<cmd>move .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>move .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Terminal: <Esc><Esc> leaves terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Phoenix / Mix (lua/config/phoenix.lua); Rails equivalents live in lua/plugins/rails.lua
local function phx(fn, ...)
  local args = { ... }
  return function() require("config.phoenix")[fn](unpack(args)) end
end
map("n", "<leader>pa", phx("alternate"), { desc = "Alternate file (lib <-> test)" })
map("n", "<leader>pi", phx("iex"), { desc = "IEx (iex -S mix)" })
map("n", "<leader>ps", phx("iex", "phx.server"), { desc = "Server with IEx" })
map("n", "<leader>pR", phx("mix", "phx.routes"), { desc = "Show routes" })
map("n", "<leader>pt", phx("test_file"), { desc = "Test this file" })
map("n", "<leader>pn", phx("test_file", true), { desc = "Test at cursor" })
map("n", "<leader>pT", phx("mix", "test"), { desc = "Run all tests" })
map("n", "<leader>pgm", phx("generate", "migration"), { desc = "Migration" })
map("n", "<leader>pgs", phx("generate", "schema"), { desc = "Schema" })
map("n", "<leader>pgc", phx("generate", "context"), { desc = "Context" })
map("n", "<leader>pgl", phx("generate", "live"), { desc = "LiveView CRUD" })
map("n", "<leader>pgh", phx("generate", "html"), { desc = "HTML CRUD" })
map("n", "<leader>pgj", phx("generate", "json"), { desc = "JSON API" })
map("n", "<leader>pgg", phx("generate"), { desc = "Any mix task" })
map("n", "<leader>pdm", phx("mix", "ecto.migrate"), { desc = "Migrate" })
map("n", "<leader>pdr", phx("rollback"), { desc = "Rollback" })
map("n", "<leader>pdR", phx("reset"), { desc = "Reset (drop, create, migrate, seed)" })
map("n", "<leader>pds", phx("mix", "ecto.migrations"), { desc = "Migration status" })
map("n", "<leader>pdS", phx("mix", "run priv/repo/seeds.exs"), { desc = "Seed" })
map("n", "<leader>pma", phx("add_dep"), { desc = "Add Hex package to mix.exs" })
map("n", "<leader>pmg", phx("mix", "deps.get"), { desc = "deps.get" })
map("n", "<leader>pmu", phx("mix", "deps.update --all"), { desc = "deps.update --all" })
