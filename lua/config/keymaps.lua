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
