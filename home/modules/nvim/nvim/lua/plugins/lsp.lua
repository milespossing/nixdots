return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "saghen/blink.cmp" },
    },
    event = "VeryLazy",
    opts = {
      servers = {
        csharp_ls = {},
        clojure_lsp = {},
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
        rust_analyzer = {},
        ts_ls = {},
        yamlls = {},
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local blink = require("blink-cmp")
      for server, config in pairs(opts.servers) do
        config.capabilities = blink.get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format({ async = true })
        end,
        mode = "n",
        desc = "Format Buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        clojure = { "cljfmt", prepend_args = { "fix" } },
        csharp = { "csharpier" },
        fennel = { "fnlfmt", prepend_args = { "--fix" } },
        lua = { "stylua" },
        nix = { "nixfmt" },
        rust = { "rustfmt", prepend_args = { "--emit", "files" } },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
      formatters = {
        prettier = {
          options = {
            ft_parsers = {
              typescript = "typescript",
              typescriptreact = "typescript",
            },
          },
        },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },
  {
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = {
      debug = true,
    },
  },
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    -- optional: provides snippets for the snippet source
    dependencies = {
      "rafamadriz/friendly-snippets",
      "PaterJason/cmp-conjure",
    },

    -- use a release tag to download pre-built binaries
    version = "*",
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = { preset = "default" },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = false,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        min_keyword_length = function(ctx)
          if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
            return 2
          end
          return 0
        end,
        default = { "lsp", "path", "snippets", "buffer", "conjure" },
        providers = {
          conjure = {
            name = "conjure",
            module = "blink.compat.source",
          },
          -- https://github.com/Saghen/blink.cmp/issues/795
          cmdline = {
            enabled = function()
              return vim.fn.getcmdline():sub(1, 1) ~= "!"
            end,
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
