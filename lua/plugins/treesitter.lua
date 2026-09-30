local parsers = {
  -- the stack
  "ruby", "embedded_template", "html", "css", "javascript", "yaml", "json", "sql",
  -- everything else you'll touch in a Rails repo
  "bash", "dockerfile", "toml", "diff", "gitcommit", "git_rebase", "gitignore",
  "lua", "luadoc", "vim", "vimdoc", "query", "markdown", "markdown_inline", "regex",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang or not pcall(vim.treesitter.start, args.buf, lang) then return end
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          -- vim-ruby's indent script reads legacy syntax groups, which treesitter turns off
          -- (everything would indent to column 0). ERB/HTML keep Neovim's own indent scripts.
          if args.match == "ruby" then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
