-- Flutter helpers used by the <leader>F keymaps (lua/plugins/flutter.lua).
local M = {}

local function project_root()
  return vim.fs.root(0, "pubspec.yaml") or vim.fn.getcwd()
end

--- Widget refactors from the Dart analysis server at the cursor:
--- wrap with Center/Column/Padding/..., remove this widget, swap with parent/child,
--- move up/down, extract widget, convert to StatefulWidget.
function M.widget_actions()
  vim.lsp.buf.code_action({
    filter = function(action)
      -- the wrap/remove/move/swap/convert assists are refactor.flutter.*; Extract Widget is
      -- only a generic refactor.extract, so match it by title
      return (action.kind or ""):find("flutter", 1, true) ~= nil or action.title == "Extract Widget"
    end,
  })
end

--- `flutter test` for the current test file (or its test counterpart), in the runner split.
function M.test_file()
  local root = project_root()
  local file = vim.fs.relpath(root, vim.fn.expand("%:p")) or vim.fn.expand("%")
  if not file:match("_test%.dart$") then
    local candidate = file:gsub("^lib/", "test/"):gsub("%.dart$", "_test.dart")
    if vim.uv.fs_stat(root .. "/" .. candidate) then
      file = candidate
    else
      return vim.notify("No test file for " .. file, vim.log.levels.WARN)
    end
  end
  require("config.runner").run("flutter test " .. vim.fn.shellescape(file), { cwd = root })
end

function M.test_all()
  require("config.runner").run("flutter test", { cwd = project_root() })
end

return M
