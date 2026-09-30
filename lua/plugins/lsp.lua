return {
  {
    -- Only used for its server definitions (lsp/*.lua); servers are enabled with vim.lsp.enable().
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("ruby_lsp", {
        init_options = {
          formatter = "auto", -- RuboCop when it's in the bundle
          linters = { "rubocop" },
          addonSettings = {
            -- the "run pending migrations?" popup steals focus mid-edit; use <leader>rdm instead
            ["Ruby LSP Rails"] = { enablePendingMigrationsPrompt = false },
          },
        },
      })

      vim.lsp.config("html", {
        filetypes = { "html", "eruby" },
        init_options = { provideFormatter = false }, -- htmlbeautifier formats via conform
      })

      vim.lsp.enable({ "ruby_lsp", "html", "cssls" })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          -- Neovim already maps K (hover), grn (rename), gra (code action), grr (references),
          -- gri (implementation), gO (symbols), [d / ]d (diagnostics). These add the usual ones.
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>cl", "<cmd>checkhealth vim.lsp<CR>", "LSP info")
        end,
      })
    end,
  },
}
