return {
  {
    "ibhagwan/fzf-lua",
    opts = {},
    keys = {
      {
        "<leader>ff",
        function()
          require("fzf-lua").files()
        end,
      },
      {
        "<leader>bb",
        function()
          require("fzf-lua").buffers()
        end,
      },
      {
        "<leader>bg",
        function()
          require("fzf-lua").grep_curbuf()
        end,
      },
      {
        "<leader>bf",
        function()
          require("fzf-lua").filetypes()
        end,
      },
      {
        "<leader>ss",
        function()
          require("fzf-lua").builtin()
        end,
      },
      {
        "<leader>sG",
        desc = "Grep",
        function()
          require("fzf-lua").grep()
        end,
      },
      {
        "<leader>sg",
        desc = "Live Grep",
        function()
          require("fzf-lua").live_grep()
        end,
      },
      {
        "<leader>sw",
        desc = "Grep word",
        function()
          require("fzf-lua").grep_cword()
        end,
      },
      {
        "<leader>sW",
        desc = "Grep WORD",
        function()
          require("fzf-lua").grep_cWORD()
        end,
      },
      {
        "<leader>hk",
        desc = "Keymaps",
        function()
          require("fzf-lua").keymaps()
        end,
      },
      {
        "<leader>hh",
        desc = "Helptags",
        function()
          require("fzf-lua").helptags()
        end,
      },
      {
        "<leader>:",
        desc = "Commands",
        function()
          require("fzf-lua").commands()
        end,
      },
    },
  },
}
