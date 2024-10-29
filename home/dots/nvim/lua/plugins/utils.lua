
return {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      lazy = false,
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
	    { "<leader>bb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Find Buffer" },
        { "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
        { "<leader>ss", "<cmd> Telescope grep_string<cr>", desc = "grep String" },
      },
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {},
      config = function()
        require('ibl').setup{
		  indent = { char = " " }
	    }
      end
    },
    {
      "voldikss/vim-floaterm",
      keys = {
        { "<leader>tf", "<cmd>FloatermNew<cr>", desc = "New Floaterm" },
        { "<leader>gg", "<cmd>FloatermNew lazygit<cr>", desc = "lazygit" },
      },
    },
    {
      "nvim-neorg/neorg",
      lazy = false,
      version = "*",
      config = true,
    },
}
