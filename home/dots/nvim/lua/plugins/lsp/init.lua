
return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    init = function()
      local lspconfig = require("lspconfig")
      lspconfig.nil_ls.setup {}
      lspconfig.lua_ls.setup {}
      lspconfig.vimls.setup  {}
      lspconfig.clojure_lsp.setup {}
    end
  }
}
