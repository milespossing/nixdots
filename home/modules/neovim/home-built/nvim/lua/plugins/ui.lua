return {
  {
    "folke/which-key.nvim",
    enabled = not vim.g.vscode,
    event = "VeryLazy",
  },
  {
    "folke/noice.nvim",
    enabled = not vim.g.vscode,
    event = "VeryLazy",
    enabled = vim.g.use_noice,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = false,
      },
    },
  },
  {
    "stevearc/oil.nvim",
    enabled = not vim.g.vscode,
    opts = {},
    dependencies = { "echasnovski/mini.icons" },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>", { desc = "Open parent directory" } },
    },
  },
  -- TODO: Get this customized
  {
    "nvim-lualine/lualine.nvim",
    enabled = not vim.g.vscode,
    config = function()
      require("lualine").setup()
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = not vim.g.vscode,
    version = "*",
    dependencies = { "echasnovski/mini.icons" },
  },
  {
    "folke/trouble.nvim",
    enabled = not vim.g.vscode,
    cmd = { "Trouble" },
    keys = {
      { "<leader>tt", group = "Trouble" },
      { "<leader>ttx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
    },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
  },
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
    enabled = not vim.g.vscode,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
}
