return {
  {
    "nvim-neotest/neotest",
    enabled = function()
      LazyVim.has_extra("testing.core")
    end,
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
      },
    },
  },
}
