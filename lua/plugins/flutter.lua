local function flutter(fn)
  return function() require("config.flutter")[fn]() end
end

local function dap(fn, ...)
  local args = { ... }
  return function() require("dap")[fn](unpack(args)) end
end

return {
  {
    -- Dart LSP (dartls), run/hot reload/hot restart, devices & emulators, dev log, outline,
    -- DevTools, closing labels, widget guides. Saving a .dart file hot-reloads the running app;
    -- saving pubspec.yaml runs `flutter pub get`.
    "nvim-flutter/flutter-tools.nvim",
    lazy = false, -- recommended by the plugin; it sets itself up per Dart buffer
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    keys = {
      { "<leader>Fr", "<cmd>FlutterRun<CR>", desc = "Run (debug session)" },
      { "<leader>Fd", "<cmd>FlutterDevices<CR>", desc = "Pick device and run" },
      { "<leader>Fe", "<cmd>FlutterEmulators<CR>", desc = "Start emulator / simulator" },
      { "<leader>Fh", "<cmd>FlutterReload<CR>", desc = "Hot reload" },
      { "<leader>FR", "<cmd>FlutterRestart<CR>", desc = "Hot restart" },
      { "<leader>Fq", "<cmd>FlutterQuit<CR>", desc = "Quit app" },
      { "<leader>Fw", flutter("widget_actions"), mode = { "n", "v" }, desc = "Widget actions (wrap/remove/extract)" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", desc = "Widget outline" },
      { "<leader>Fl", "<cmd>FlutterLogToggle<CR>", desc = "Toggle dev log" },
      { "<leader>FL", "<cmd>FlutterLogClear<CR>", desc = "Clear dev log" },
      { "<leader>Ft", flutter("test_file"), desc = "Test this file" },
      { "<leader>FT", flutter("test_all"), desc = "Test all" },
      { "<leader>Fp", "<cmd>FlutterPubGet<CR>", desc = "pub get" },
      { "<leader>FP", "<cmd>FlutterPubUpgrade<CR>", desc = "pub upgrade" },
      { "<leader>Fv", "<cmd>FlutterDevTools<CR><cmd>FlutterOpenDevTools<CR>", desc = "Open DevTools" },
      { "<leader>Fn", "<cmd>FlutterRename<CR>", desc = "Rename (and file + imports)" },
      { "<leader>Fs", "<cmd>FlutterSuper<CR>", desc = "Go to super" },
      { "<leader>Fc", "<cmd>FlutterCommands<CR>", desc = "All Flutter commands" },
    },
    opts = {
      ui = { border = "rounded" },
      decorations = { statusline = { device = true } },
      debugger = { enabled = true }, -- :FlutterRun goes through nvim-dap, so breakpoints just work
      widget_guides = { enabled = true },
      closing_tags = { prefix = "// " },
      dev_log = { open_cmd = "botright 15split", focus_on_open = false },
      outline = { open_cmd = "botright 40vnew" },
      lsp = {
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          enableSnippets = true, -- stless, stful, stanim, ...
          renameFilesWithClasses = "prompt",
          updateImportsOnRename = true,
        },
      },
    },
  },

  -- Debugging (used by Flutter; works for any nvim-dap adapter)
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<leader>db", dap("toggle_breakpoint"), desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dc", dap("continue"), desc = "Continue / start" },
      { "<leader>do", dap("step_over"), desc = "Step over" },
      { "<leader>di", dap("step_into"), desc = "Step into" },
      { "<leader>dO", dap("step_out"), desc = "Step out" },
      { "<leader>dr", dap("run_to_cursor"), desc = "Run to cursor" },
      { "<leader>dt", dap("terminate"), desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
    },
    config = function()
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })

      -- The debug UI opens when execution stops (breakpoint/exception) rather than on every
      -- :FlutterRun, and closes when the session ends.
      local listeners = require("dap").listeners
      listeners.after.event_stopped.dapui = function() require("dapui").open() end
      listeners.before.event_terminated.dapui = function() require("dapui").close() end
      listeners.before.event_exited.dapui = function() require("dapui").close() end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
  },
}
