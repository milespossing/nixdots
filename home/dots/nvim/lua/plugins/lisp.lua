-- This is where I'm controlling everything I need for my lisps
return {
    {
        "julienvincent/nvim-paredit",
        config = function()
            require("nvim-paredit").setup()
        end,
    },
}
