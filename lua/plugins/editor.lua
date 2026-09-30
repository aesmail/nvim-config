local function find_in(dir, title)
  return function()
    local root = require("config.rails").root()
    require("telescope.builtin").find_files({ cwd = root .. "/" .. dir, prompt_title = title })
  end
end

return {
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    init = function()
      -- Route vim.ui.select (snippet menus, code actions) through Telescope, loading it on first use.
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "telescope.nvim" } })
        return vim.ui.select(...)
      end
    end,
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep project" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles only_cwd=true<CR>", desc = "Recent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Symbols in file" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Symbols in project" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>f.", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
      { "<leader>fm", find_in("app/models", "Models"), desc = "Rails models" },
      { "<leader>fc", find_in("app/controllers", "Controllers"), desc = "Rails controllers" },
      { "<leader>fv", find_in("app/views", "Views"), desc = "Rails views" },
      { "<leader>fM", find_in("db/migrate", "Migrations"), desc = "Rails migrations" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = "  ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
          file_ignore_patterns = { "^.git/", "^node_modules/", "^tmp/", "^log/", "^vendor/bundle/", "^public/assets/" },
        },
        pickers = {
          find_files = { hidden = true },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_cursor({ layout_config = { height = 12 } }) },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<CR>", desc = "File explorer" },
      { "<leader>E", "<cmd>Neotree float reveal<CR>", desc = "File explorer (float)" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = true, never_show = { ".DS_Store", ".git" } },
      },
      window = { width = 32 },
    },
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous git hunk")
        map({ "n", "v" }, "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", "Stage/unstage hunk")
        map({ "n", "v" }, "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.blame, "Blame file")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map({ "o", "x" }, "ih", "<cmd>Gitsigns select_hunk<CR>", "Inner hunk")
      end,
    },
  },
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitLog" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Lazygit" },
      { "<leader>gl", "<cmd>LazyGitLog<CR>", desc = "Lazygit log" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", desc = "Lazygit (current file's repo)" },
    },
  },

  -- Keymap hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>r", group = "rails" },
        { "<leader>rb", group = "bundle" },
        { "<leader>rd", group = "database" },
        { "<leader>rg", group = "generate" },
        { "<leader>u", group = "toggle" },
        { "gr", group = "lsp" },
        { "[", group = "previous" },
        { "]", group = "next" },
      },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "sunburst",
        globalstatus = true,
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = {
          {
            function() return " Rails" end,
            cond = function() return vim.b.rails_root ~= nil end,
            color = { fg = "#E28964" },
          },
          {
            function()
              local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
              return #names > 0 and (" " .. table.concat(names, ", ")) or ""
            end,
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "neo-tree", "lazy" },
    },
  },
}
