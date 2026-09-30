local function flutter(fn)
  return function() require("config.flutter")[fn]() end
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
}
