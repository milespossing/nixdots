local wk = require("which-key")

wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>bn", ":set number<cr>", desc = "Set Number" },
  { "<leader>br", ":set relativenumber<cr>", desc = "Set Relative" },
  { "<leader>f", group = "file" },
  { "<leader>g", group = "git" },
  { "<leader>t", group = "toggle" },
  { "<leader>w", group = "window" },
  { "<leader>wh", "<C-w>h", desc = "Move point left" },
  { "<leader>wj", "<C-w>j", desc = "Move point down" },
  { "<leader>wk", "<C-w>k", desc = "Move point up" },
  { "<leader>wl", "<C-w>l", desc = "Move point right" },
  { "<leader>s", group = "search" },
  {
      "<leader>fm",
      function()
        require("conform").format({ async = true })
      end,
      desc = "Format file",
  }
})

