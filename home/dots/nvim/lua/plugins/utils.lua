
return {
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      lazy = false,
      keys = {
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
	{ "<leader>bb", "<cmb>Telescope buffers<cr>", desc = "Find Buffer" },
      },
    },
    -- {
    --   'ggandor/leap.nvim',
    --   lazy = false,
    --   config = function()
	--     require'leap'.create_default_mappings()
    --   end,
    -- },
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
