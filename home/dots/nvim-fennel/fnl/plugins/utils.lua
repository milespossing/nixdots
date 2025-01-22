return {
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
		config = function()
			require("ibl").setup({
				indent = { char = " " },
			})
		end,
	},
	{
		"voldikss/vim-floaterm",
		keys = {
			-- { "<leader>tf", "<cmd>FloatermNew<cr>", desc = "New Floaterm" },
			-- { "<leader>gg", "<cmd>FloatermNew lazygit<cr>", desc = "lazygit" },
		},
	},
}
