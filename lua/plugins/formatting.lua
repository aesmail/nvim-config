return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = "Format buffer" },
      {
        "<leader>uf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        -- ruby-lsp formats with RuboCop inside a bundle; the rubocop CLI covers loose scripts.
        ruby = { "rubocop", lsp_format = "prefer" },
        eruby = { "htmlbeautifier" },
        html = { "htmlbeautifier" },
        -- Expert formats Elixir inside a Mix project; `mix format` covers loose scripts, and HEEx,
        -- which Expert leaves alone (Phoenix's .formatter.exs plugs in the HEEx formatter).
        elixir = { "mix", lsp_format = "prefer" },
        heex = { "mix" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = function()
        if vim.g.disable_autoformat then return end
        return { timeout_ms = 3000 }
      end,
    },
  },
}
