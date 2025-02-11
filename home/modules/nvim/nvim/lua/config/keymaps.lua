-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Snacks = require("snacks")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.line_number():map("<leader>ul")

local wk = require("which-key")

wk.add({
  { "<leader>f", group = "file", icon = "" },
  { "<leader>w", group = "window", icon = "" },
  { "<leader>b", group = "buffer", icon = "" },
  { "<leader>t", group = "tools", icon = "󱁤" },
  { "<leader>o", group = "org", icon = "" },
  { "[", group = "prev" },
  { "]", group = "next" },
  { "z", group = "fold" },
  { "g", group = "goto" },
  { "<leader>wh", "<C-w>h", desc = "Window Left" },
  { "<leader>wj", "<C-w>j", desc = "Window Down" },
  { "<leader>wl", "<C-w>l", desc = "Window Right" },
  { "<leader>wk", "<C-w>k", desc = "Window Up" },
  { "<leader>h", group = "help" },
})
