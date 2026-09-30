local group = vim.api.nvim_create_augroup("user_config", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Briefly highlight yanked text",
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Restore cursor to last known position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Equalize splits when the terminal is resized",
  command = "tabdo wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "help", "qf", "checkhealth", "man", "lspinfo" },
  desc = "Close helper windows with q",
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true })
  end,
})

-- Ruby files Neovim doesn't detect by default
vim.filetype.add({
  extension = { jbuilder = "ruby", thor = "ruby" },
  filename = { Guardfile = "ruby", Capfile = "ruby" },
})
