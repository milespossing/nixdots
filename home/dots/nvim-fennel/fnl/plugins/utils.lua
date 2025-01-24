return {
	{
		"ibhagwan/fzf-lua",
        event = "VeryLazy",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
        config = require("config.fzf")
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
}
