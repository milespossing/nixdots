return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "tsx", "typescript", "c_sharp", "scala", "clojure", "fennel" },
      ignore_install = { "org" },
      highlight = { enable = true },
      incremental_selection = { enable = true },
      textobjects = {
        select = { enable = true, lookahead = true },
      },
    })
  end,
}
