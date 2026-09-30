-- Runs shell commands (Rails tasks, bundler, flutter test, ...) in a terminal split at the
-- bottom of the screen. One runner window at a time; `q` closes it.
local M = {}

local term_win

--- opts.cwd: working directory (default: cwd)
--- opts.interactive: focus the terminal in insert mode (consoles); otherwise stay in the current window
--- opts.on_exit(code, buf): called after the command finishes
function M.run(cmd, opts)
  opts = opts or {}
  local origin = vim.api.nvim_get_current_win()
  M.close()

  vim.cmd("botright 15new")
  term_win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "wipe"
  vim.wo[term_win].number = false
  vim.wo[term_win].relativenumber = false
  vim.wo[term_win].signcolumn = "no"
  vim.wo[term_win].winfixheight = true
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, desc = "Close runner" })

  vim.fn.jobstart(cmd, {
    term = true,
    cwd = opts.cwd,
    on_exit = function(_, code)
      -- let the terminal flush its last lines before anyone reads them
      vim.defer_fn(function()
        vim.cmd.checktime() -- reload files the command changed (Gemfile, schema.rb, ...)
        if code ~= 0 then
          vim.notify(("`%s` failed (exit %d)"):format(cmd, code), vim.log.levels.ERROR)
        end
        if opts.on_exit and vim.api.nvim_buf_is_valid(buf) then opts.on_exit(code, buf) end
      end, 50)
    end,
  })

  if opts.interactive then
    vim.cmd.startinsert()
  elseif vim.api.nvim_win_is_valid(origin) then
    vim.api.nvim_set_current_win(origin)
  end
  return buf
end

function M.close()
  if term_win and vim.api.nvim_win_is_valid(term_win) then vim.api.nvim_win_close(term_win, true) end
  term_win = nil
end

return M
