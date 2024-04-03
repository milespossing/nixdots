
local wk = require("which-key")

wk.register({
  f = { name = "file" },
  b = { name = "buffer" },
  w = {
    name = "window",
    h = { "<C-w>h", "Move point left" },
    j = { "<C-w>j", "Move point down" },
    l = { "<C-w>l", "Move point right" },
    k = { "<C-w>k", "Move point up" },
  },
}, { prefix = "<leader>" })

