return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        {
          cmd = "chafa ~/.config/nvim/night.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
          height = 17,
          padding = 1,
          section = "terminal",
        },
        { { gap = 1, padding = 1, section = "keys" }, { section = "startup" }, pane = 2 },
      },
      preset = {
        keys = {
          {
            icon = "󰈞 ",
            key = "f",
            desc = "Find File",
            action = function()
              require("fzf-lua").files()
            end,
          },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = " ",
            key = "o",
            desc = "Org Capture",
            action = function()
              require("orgmode").action("capture.prompt")
            end,
          },
          {
            icon = " ",
            key = "r",
            desc = "Recent Files",
            action = function()
              require("fzf-lua").oldfiles()
            end,
          },
          {
            icon = " ",
            key = "s",
            desc = "Find Text",
            action = function()
              require("fzf-lua").live_grep()
            end,
          },
          {
            icon = " ",
            key = "c",
            desc = "Configure",
            action = function()
              require("fzf-lua").files({ cwd = "~/.nixdots" })
            end,
          },
          { icon = "", key = "q", desc = "Close", action = ":qa" },
        },
      },
    },
    dim = { enabled = true },
    git = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    layout = { enabled = true },
    notifier = { enabled = true },
    notify = { enabled = true },
    picker = { enabled = true },
    quickfile = { enabled = true },
    scratch = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    terminal = { enabled = true },
    toggle = { enabled = true, map = vim.keymap.set, ["which-key"] = true },
    util = { enabled = true },
    win = { enabled = true },
    zen = { enabled = true },
  },
}
