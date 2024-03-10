
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
}
