return {
  {
    "neovim/nvim-lspconfig",
    enabled = not vim.g.vscode,
    event = "VeryLazy",
    opts = {
      servers = {
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
        rust_analyzer = {},
        ts_ls = {},
        yamlls = {},
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local has_cmp, cmp = pcall(require, "cmp_nvim_lsp")
      local has_blink, blink = pcall(require, "blink.cmp")
      for server, config in pairs(opts.servers) do
        config.capabilities = vim.tbl_deep_extend(
          "force",
          {},
          vim.lsp.protocol.make_client_capabilities(),
          has_cmp and cmp.default_capabilities() or {},
          has_blink and blink.get_lsp_capabilities(config.capabilities) or {}
        )
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
        json = { "fixjson", prepend_args = { "--write " } },
        lua = { "stylua" },
        nix = { "nixfmt" },
        rust = { "rustfmt", prepend_args = { "--emit", "files" } },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
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
        eslint_d = {},
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    enabled = vim.g.use_cmp and not vim.g.vscode,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "onsails/lspkind.nvim",
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      local auto_select = true
      local lspkind = require("lspkind")
      return {
        auto_brackets = {},
        completion = { completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect") },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "conjure" },
          { name = "orgmode" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = {
              menu = 50,
              abbr = 50,
            },
            ellipsis_char = "...",
            show_labelDetails = true,

            before = function(_, vim_item)
              return vim_item
            end,
          }),
        },
        experimental = {
          ghost_text = vim.g.ai_cmp and {
            hl_group = "CmpGhostText",
          } or false,
        },
        sorting = defaults.sorting,
      }
    end,
  },
--   {
--     "hrsh7th/cmp-nvim-lsp",
--     "hrsh7th/cmp-buffer",
--     "hrsh7th/cmp-path",
--   },
  {
    "saghen/blink.compat",
    enabled = vim.g.use_blink and not vim.g.vscode,
    version = "*",
    opts = {
      debug = true,
    },
  },
  {
    "saghen/blink.cmp",
    enabled = vim.g.use_blink and not vim.g.vscode,
    event = "InsertEnter",
    -- optional: provides snippets for the snippet source
    dependencies = {
      "rafamadriz/friendly-snippets",
      "PaterJason/cmp-conjure",
    },

    -- use a release tag to download pre-built binaries
    version = "*",
    opts = {
      keymap = { preset = "default" },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

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
