local function dap(fn, ...)
  local args = { ... }
  return function() require("dap")[fn](unpack(args)) end
end

-- Elixir: ElixirLS's debug adapter (mise installs it as `elixir-debug-adapter`; Expert has no
-- debugger). Picking a configuration with <leader>dc offers these; Flutter's come from flutter-tools.
local function elixir_configurations()
  local base = {
    type = "mix_task",
    request = "launch",
    projectDir = function() return vim.fs.root(0, "mix.exs") or vim.fn.getcwd() end,
    -- Only modules with breakpoints run in the (slow) interpreter; interpreting the whole app
    -- makes a Phoenix server crawl.
    debugAutoInterpretAllModules = false,
  }
  local function config(extra) return vim.tbl_extend("force", base, extra) end
  return {
    -- phx.server's task returns straight away under the debugger; keep the VM (and server) up
    config({ name = "phx.server", task = "phx.server", exitAfterTaskReturns = false }),
    config({
      name = "mix test (this file)",
      task = "test",
      taskArgs = { "${file}" },
      startApps = true,
      requireFiles = { "test/**/test_helper.exs", "${file}" },
    }),
    config({
      name = "mix test (test at cursor)",
      task = "test",
      taskArgs = { "${file}:${lineNumber}" },
      startApps = true,
      requireFiles = { "test/**/test_helper.exs", "${file}" },
    }),
    config({
      name = "mix test (all)",
      task = "test",
      taskArgs = { "--trace" },
      startApps = true,
      requireFiles = { "test/**/test_helper.exs", "test/**/*_test.exs" },
    }),
  }
end

return {
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
      { "<leader>dl", dap("run_last"), desc = "Run last configuration" },
      { "<leader>dt", dap("terminate"), desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
    },
    config = function()
      local dap = require("dap")
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })

      -- The debug UI opens when execution stops (breakpoint/exception) rather than on every
      -- launch, and closes when the session ends.
      dap.listeners.after.event_stopped.dapui = function() require("dapui").open() end
      dap.listeners.before.event_terminated.dapui = function() require("dapui").close() end
      dap.listeners.before.event_exited.dapui = function() require("dapui").close() end

      dap.adapters.mix_task = {
        type = "executable",
        command = "elixir-debug-adapter",
        args = {},
        -- boots a BEAM VM (and compiles ElixirLS itself on first use); the default is 4s
        options = { initialize_timeout_sec = 60 },
      }
      dap.configurations.elixir = elixir_configurations()
      -- ElixirLS advertises exception-breakpoint filters but rejects setExceptionBreakpoints,
      -- which would raise an error on every launch.
      dap.listeners.after.initialize.elixirls = function(session)
        if session.config.type == "mix_task" then session.capabilities.exceptionBreakpointFilters = nil end
      end
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
  },
}
