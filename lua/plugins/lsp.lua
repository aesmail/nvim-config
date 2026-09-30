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
        filetypes = { "html", "eruby", "heex" },
        init_options = { provideFormatter = false }, -- htmlbeautifier / mix format handle formatting
      })

      vim.lsp.config("tailwindcss", {
        settings = {
          tailwindCSS = {
            -- Mix's deps/ can hold other packages' Tailwind stylesheets (Swoosh's mailbox
            -- preview); the server would treat them as competing projects and match none.
            files = {
              exclude = { "**/.git/**", "**/node_modules/**", "**/.hg/**", "**/.svn/**", "**/deps/**", "**/_build/**" },
            },
          },
        },
      })

      -- expert: the official Elixir language server (installed with mise).
      -- tailwindcss: class completion/hover in Phoenix (HEEx, ~H) and Rails views; it only
      -- starts in projects that use Tailwind.
      vim.lsp.enable({ "ruby_lsp", "html", "cssls", "expert", "tailwindcss" })

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
