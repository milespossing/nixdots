return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, enabled = not vim.g.vscode },
  {
    "xiyaowong/transparent.nvim",
    enabled = not vim.g.vscode,
    lazy = false,
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          vim.cmd.colorscheme("catppuccin")
          local transparent = require("transparent")
          require("snacks.toggle")
            .new({
              id = "transparent",
              name = "Transparent",
              get = function()
                return vim.g.transparent_enabled
              end,
              set = function(v)
                transparent.toggle(v)
              end,
            })
            :map("<leader>uT")
        end,
      })
    end,
  },
}
