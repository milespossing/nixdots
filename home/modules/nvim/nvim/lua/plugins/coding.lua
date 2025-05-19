return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel", "racket" }, -- etc
    lazy = true,
    enabled = not vim.g.vscode,
    init = function()
      vim.g["conjure#filetypes"] = {
        "clojure",
        "fennel",
        "racket",
      }
      vim.g["conjure#mapping#doc_word"] = false
      -- Set configuration options here
      -- Uncomment this to get verbose logging to help diagnose internal Conjure issues
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true
    end,

    -- Optional cmp-conjure integration
    dependencies = { "PaterJason/cmp-conjure" },
  },
}
