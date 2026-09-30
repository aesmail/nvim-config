-- Phoenix / Mix tasks, run in the bottom terminal split (config.runner).
-- Keymaps for these live in lua/plugins/elixir.lua (<leader>p...).
local runner = require("config.runner")
local M = {}

function M.root()
  return vim.fs.root(0, "mix.exs") or vim.fn.getcwd()
end

function M.mix(task, opts)
  return runner.run("mix " .. task, vim.tbl_extend("force", { cwd = M.root() }, opts or {}))
end

function M.iex(args)
  runner.run("iex -S mix" .. (args and (" " .. args) or ""), { cwd = M.root(), interactive = true })
end

-- Generators ---------------------------------------------------------------

-- open: pattern for the file to open afterwards; keep: leave the output up (it lists the
-- routes to add to the router)
local generators = {
  migration = { task = "ecto.gen.migration", hint = "add_email_to_users", open = "^priv/repo/migrations/" },
  schema = { task = "phx.gen.schema", hint = "Accounts.User users name:string email:string:unique", open = "^lib/" },
  context = { task = "phx.gen.context", hint = "Accounts User users name:string", open = "^lib/.*%.ex$" },
  live = { task = "phx.gen.live", hint = "Blog Post posts title:string body:text", open = "/index%.ex$", keep = true },
  html = { task = "phx.gen.html", hint = "Blog Post posts title:string body:text", open = "_controller%.ex$", keep = true },
  json = { task = "phx.gen.json", hint = "Blog Post posts title:string body:text", open = "_controller%.ex$", keep = true },
}

local function created_files(buf, root)
  local files = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local path = line:match("^%* creating (%S+)%s*$")
    if path and vim.fn.filereadable(root .. "/" .. path) == 1 then table.insert(files, path) end
  end
  return files
end

--- Prompt for arguments, run the generator, then open the main generated file.
--- The terminal is focused while it runs: phx.gen.* asks before extending an existing context.
function M.generate(kind)
  local root = vim.fs.root(0, "mix.exs")
  if not root then return vim.notify("Not inside a Mix project", vim.log.levels.WARN) end
  local spec = generators[kind] or {}
  local prompt = "mix " .. (spec.task and (spec.task .. " ") or "")
  if spec.hint then prompt = prompt .. "(e.g. " .. spec.hint .. ") " end

  vim.ui.input({ prompt = prompt }, function(input)
    if not input or vim.trim(input) == "" then return end
    local origin = vim.api.nvim_get_current_win()
    local task = spec.task and (spec.task .. " " .. input) or input
    M.mix(task, {
      interactive = true,
      on_exit = function(code, buf)
        if code ~= 0 then return end
        local files = created_files(buf, root)
        if #files == 0 then return end
        local target = files[1]
        for _, f in ipairs(files) do
          if spec.open and f:match(spec.open) then target = f break end
        end
        if not spec.keep then runner.close() end
        if vim.api.nvim_win_is_valid(origin) then vim.api.nvim_set_current_win(origin) end
        vim.cmd.stopinsert()
        vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. target))
        vim.notify("Created:\n  " .. table.concat(files, "\n  "))
      end,
    })
  end)
end

-- Database (Ecto) ----------------------------------------------------------

function M.rollback()
  vim.ui.input({ prompt = "Roll back how many migrations? ", default = "1" }, function(steps)
    if not steps or not steps:match("^%d+$") then return end
    M.mix("ecto.rollback --step " .. steps)
  end)
end

function M.reset()
  local choice = vim.fn.confirm("ecto.reset drops the database, then migrates and seeds it. Continue?", "&Yes\n&No", 2)
  if choice == 1 then M.mix("ecto.reset") end
end

-- Dependencies -------------------------------------------------------------

--- Adds `{:pkg, "~> x.y"}` (latest from Hex) to the deps in mix.exs, then runs `mix deps.get`.
function M.add_dep()
  local root = vim.fs.root(0, "mix.exs")
  if not root then return vim.notify("Not inside a Mix project", vim.log.levels.WARN) end
  vim.ui.input({ prompt = "Add Hex package: " }, function(pkg)
    pkg = pkg and vim.trim(pkg) or ""
    if pkg == "" then return end
    vim.notify("Looking up " .. pkg .. " on Hex…")
    vim.system({ "mix", "hex.info", pkg }, { cwd = root, text = true }, vim.schedule_wrap(function(res)
      local dep = res.code == 0 and res.stdout:match("Config: (%b{})")
      if not dep then
        return vim.notify("Hex package not found: " .. pkg .. "\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      end
      local mix_exs = root .. "/mix.exs"
      local lines = vim.fn.readfile(mix_exs)
      for i, line in ipairs(lines) do
        if line:match("^%s*defp deps do") then
          for j = i + 1, #lines do
            if lines[j]:match("%[%s*$") then
              local indent = (lines[j + 1] or ""):match("^(%s*)") or "      "
              table.insert(lines, j + 1, indent .. dep .. ",")
              vim.fn.writefile(lines, mix_exs)
              vim.cmd.checktime()
              vim.notify("Added " .. dep .. " to mix.exs")
              return M.mix("deps.get")
            end
          end
        end
      end
      vim.notify("Couldn't find `defp deps do [` in mix.exs; add " .. dep .. " by hand", vim.log.levels.WARN)
    end))
  end)
end

-- Tests & navigation -------------------------------------------------------

--- lib/my_app/foo.ex <-> test/my_app/foo_test.exs
local function alternate_path(rel)
  if rel:match("^test/.*_test%.exs$") then
    return (rel:gsub("^test/", "lib/"):gsub("_test%.exs$", ".ex"))
  elseif rel:match("^lib/.*%.ex$") then
    return (rel:gsub("^lib/", "test/"):gsub("%.ex$", "_test.exs"))
  end
end

function M.alternate()
  local root = M.root()
  local rel = vim.fs.relpath(root, vim.fn.expand("%:p")) or ""
  local alt = alternate_path(rel)
  if not alt then return vim.notify("No alternate file for " .. rel, vim.log.levels.WARN) end
  vim.cmd.edit(vim.fn.fnameescape(root .. "/" .. alt))
end

--- mix test for this file (or its test file); with `line`, just the test at the cursor.
function M.test_file(at_cursor)
  local root = M.root()
  local rel = vim.fs.relpath(root, vim.fn.expand("%:p")) or ""
  if not rel:match("_test%.exs$") then
    local alt = alternate_path(rel)
    if not (alt and vim.uv.fs_stat(root .. "/" .. alt)) then
      return vim.notify("No test file for " .. rel, vim.log.levels.WARN)
    end
    rel, at_cursor = alt, false
  end
  if at_cursor then rel = rel .. ":" .. vim.fn.line(".") end
  M.mix("test " .. vim.fn.shellescape(rel))
end

return M
