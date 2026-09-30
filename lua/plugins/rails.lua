local function rails(fn, ...)
  local args = { ... }
  return function() require("config.rails")[fn](unpack(args)) end
end

return {
  {
    -- :A / :R alternate & related files, gf on partials/models, :Emodel, :Econtroller, :Eview ...
    "tpope/vim-rails",
    lazy = false,
    keys = {
      { "<leader>ra", "<cmd>A<CR>", desc = "Alternate file (:A)" },
      { "<leader>rr", "<cmd>R<CR>", desc = "Related file (:R)" },
      { "<leader>rc", rails("console"), desc = "Rails console" },
      { "<leader>rt", rails("test_file"), desc = "Run tests for this file" },
      { "<leader>rT", rails("run", "test"), desc = "Run all tests" },
      { "<leader>rR", rails("run", "routes"), desc = "Show routes" },

      { "<leader>rgm", rails("generate", "migration"), desc = "Migration" },
      { "<leader>rgM", rails("generate", "model"), desc = "Model" },
      { "<leader>rgc", rails("generate", "controller"), desc = "Controller" },
      { "<leader>rgs", rails("generate", "scaffold"), desc = "Scaffold" },
      { "<leader>rgg", rails("generate"), desc = "Any generator" },

      { "<leader>rdm", rails("run", "db:migrate"), desc = "Migrate" },
      { "<leader>rdr", rails("rollback"), desc = "Rollback" },
      { "<leader>rdR", rails("reset"), desc = "Reset (drop, create, schema, seed)" },
      { "<leader>rds", rails("run", "db:migrate:status"), desc = "Migration status" },
      { "<leader>rdS", rails("run", "db:seed"), desc = "Seed" },

      { "<leader>rba", rails("add_gem"), desc = "Add gem to Gemfile" },
      { "<leader>rbi", rails("bundle", "install"), desc = "bundle install" },
      { "<leader>rbu", rails("bundle", "update --all"), desc = "bundle update --all" },
    },
  },
}
