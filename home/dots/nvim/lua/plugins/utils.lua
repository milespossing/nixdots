
return {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      lazy = false,
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
	    { "<leader>bb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Find Buffer" },
        { "<leader>,", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Switch Buffer" },
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
      'echasnovski/mini.nvim',
      version = '*',
      lazy = false,
      config = function()
          require('mini.surround').setup()
          require('mini.comment').setup()
      end
    },
}
