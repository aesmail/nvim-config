-- Rails / Bundler tasks, run in a terminal split at the bottom of the screen.
-- Keymaps for these live in lua/plugins/rails.lua (<leader>r...).
local M = {}

local term_win -- the runner window, reused between commands

local function is_rails_app(name, path)
  return name == "Gemfile" and vim.uv.fs_stat(vim.fs.joinpath(path, "config", "application.rb")) ~= nil
end

--- Root of the Rails app for a buffer (nil outside one).
function M.rails_root(buf)
  return vim.fs.root(buf or 0, is_rails_app)
end

--- Rails root, else the nearest Gemfile, else the cwd.
function M.root()
  return M.rails_root(0) or vim.fs.root(0, "Gemfile") or vim.fn.getcwd()
end

local function rails_cmd(root)
  return vim.fn.executable(root .. "/bin/rails") == 1 and "bin/rails" or "bundle exec rails"
end

--- Run a shell command in the runner split.
--- opts.interactive: focus the terminal in insert mode (console); otherwise stay in the current window.
--- opts.on_exit(code, buf): called after the command finishes.
local function run_in_terminal(cmd, opts)
  opts = opts or {}
  local origin = vim.api.nvim_get_current_win()
  if term_win and vim.api.nvim_win_is_valid(term_win) then vim.api.nvim_win_close(term_win, true) end

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
    cwd = opts.cwd or M.root(),
    on_exit = function(_, code)
      -- let the terminal flush its last lines before we read them
      vim.defer_fn(function()
        vim.cmd.checktime() -- reload Gemfile, schema.rb, etc. if they changed
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

function M.run(task, opts)
  local root = M.root()
  return run_in_terminal(rails_cmd(root) .. " " .. task, vim.tbl_extend("force", { cwd = root }, opts or {}))
end

function M.bundle(args)
  run_in_terminal("bundle " .. args, { cwd = vim.fs.root(0, "Gemfile") or vim.fn.getcwd() })
end

function M.console()
  M.run("console", { interactive = true })
end

-- Generators ---------------------------------------------------------------

local generators = {
  migration = { hint = "AddEmailToUsers email:string:index", open = "^db/migrate/" },
  model = { hint = "Post title:string body:text user:references", open = "^app/models/" },
  controller = { hint = "Posts index show", open = "^app/controllers/" },
  scaffold = { hint = "Post title:string body:text", open = "^app/controllers/" },
}

local function created_files(buf, root)
  local files = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local path = line:match("^%s*create%s+(%S+)%s*$")
    if path and vim.fn.filereadable(root .. "/" .. path) == 1 then table.insert(files, path) end
  end
  return files
end

--- Prompt for arguments, run `rails generate <kind> ...`, then open the main generated file.
function M.generate(kind)
  local root = M.rails_root(0)
  if not root then return vim.notify("Not inside a Rails app", vim.log.levels.WARN) end
  local spec = generators[kind] or {}
  local prompt = ("rails generate %s"):format(kind and (kind .. " ") or "")
  if spec.hint then prompt = prompt .. "(e.g. " .. spec.hint .. ") " end

  vim.ui.input({ prompt = prompt }, function(input)
    if not input or vim.trim(input) == "" then return end
    local args = (kind and (kind .. " ") or "") .. input
    M.run("generate " .. args, {
      on_exit = function(code, buf)
        if code ~= 0 then return end
        local files = created_files(buf, root)
        if #files == 0 then return end
        local target = files[1]
        for _, f in ipairs(files) do
          if spec.open and f:match(spec.open) then target = f break end
        end
        if term_win and vim.api.nvim_win_is_valid(term_win) then vim.api.nvim_win_close(term_win, true) end
        vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. target))
        vim.notify("Created:\n  " .. table.concat(files, "\n  "))
      end,
    })
  end)
end

-- Database -----------------------------------------------------------------

function M.rollback()
  vim.ui.input({ prompt = "Roll back how many migrations? ", default = "1" }, function(steps)
    if not steps or not steps:match("^%d+$") then return end
    M.run("db:rollback STEP=" .. steps)
  end)
end

function M.reset()
  local choice = vim.fn.confirm("db:reset drops the database and reloads schema + seeds. Continue?", "&Yes\n&No", 2)
  if choice == 1 then M.run("db:reset") end
end

-- Bundler ------------------------------------------------------------------

--- `bundle add` writes the gem to the Gemfile and installs it.
function M.add_gem()
  vim.ui.input({ prompt = "bundle add (e.g. pagy  or  rspec-rails --group development,test) " }, function(input)
    if not input or vim.trim(input) == "" then return end
    M.bundle("add " .. input)
  end)
end

-- Tests --------------------------------------------------------------------

function M.test_file()
  local file = vim.fn.expand("%:p")
  local root = M.root()
  local rel = vim.fs.relpath(root, file) or file
  if rel:match("_spec%.rb$") then
    run_in_terminal("bundle exec rspec " .. vim.fn.shellescape(rel), { cwd = root })
  elseif rel:match("_test%.rb$") then
    M.run("test " .. vim.fn.shellescape(rel))
  else
    vim.notify("Not a test file. Jump to its test with :A (<leader>ra)", vim.log.levels.WARN)
  end
end

return M
