local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.showmode = false -- lualine shows the mode
opt.laststatus = 3 -- one global statusline
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.winborder = "rounded"
opt.splitright = true
opt.splitbelow = true
opt.pumheight = 12

-- Editing: two-space soft tabs (Ruby/Rails convention)
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftround = true

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share the macOS clipboard
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.confirm = true
opt.updatetime = 250
opt.timeoutlen = 400

-- Folding via treesitter, all open by default
opt.foldlevel = 99
opt.foldlevelstart = 99

vim.diagnostic.config({
  severity_sort = true,
  float = { source = "if_many" },
  virtual_text = { spacing = 2, prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
})
