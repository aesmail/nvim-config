return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp", -- needed for TextMate-style regex transformations
    config = function()
      local ls = require("luasnip")
      local filetypes = require("config.snippet_filetypes")
      ls.setup({
        update_events = "TextChanged,TextChangedI", -- update mirrors while typing, like TextMate
        delete_check_events = "TextChanged",
        store_selection_keys = "<Tab>", -- select text, <Tab>, then expand to wrap it ($TM_SELECTED_TEXT)
        ft_func = filetypes.at_cursor,
        load_ft_func = filetypes.for_buffer,
      })
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "L3MON4D3/LuaSnip" },
    opts = {
      snippets = { preset = "luasnip" },
      keymap = {
        preset = "none",
        -- TextMate-style Tab: expand a trigger (menu if it's ambiguous; LSP snippets like
        -- Dart's stless too), else accept the selected completion, else jump to the next
        -- snippet field, else indent.
        ["<Tab>"] = {
          function(cmp)
            if require("config.snippets").expand() then
              cmp.hide()
              return true
            end
          end,
          function(cmp) return require("config.snippets").accept_lsp_snippet(cmp) end,
          function(cmp)
            if cmp.is_menu_visible() and cmp.get_selected_item() then return cmp.accept() end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = true } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        menu = { draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "snippets", "path", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({ check_ts = true })
      npairs.add_rules(require("nvim-autopairs.rules.endwise-ruby"))
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "eruby", "xml" },
    opts = {},
  },
}
