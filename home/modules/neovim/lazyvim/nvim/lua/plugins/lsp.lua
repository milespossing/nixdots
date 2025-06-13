return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = {
      csharp_ls = {},
      clojure_lsp = {},
      eslint = {},
      fennel_ls = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = {
                "vim",
              },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      },
      nil_ls = {},
      -- rust_analyzer = {},
      ts_ls = {},
      yamlls = {},
    }
  end,
}
