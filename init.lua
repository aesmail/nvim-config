-- Leader keys must be set before any plugin (or mapping) is loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")

vim.cmd.colorscheme("sunburst")

require("config.lazy")
