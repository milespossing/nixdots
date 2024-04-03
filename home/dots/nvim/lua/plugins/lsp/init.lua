
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-nvim-lsp" },
    },
    lazy = false,
    init = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      lspconfig.nil_ls.setup {
        capabilities = capabilities
      }
      lspconfig.lua_ls.setup {
        settings = {
	  Lua = {
	    runtime = {
	      version = 'LuaJIT'
	    },
	    diagnostics = {
	      globals = {
	        'vim',
	      }
	    },
	    workspace = {
	      library = vim.api.nvim_get_runtime_file("", true)
	    }
	  }
	},
        capabilities = capabilities
      }
      lspconfig.vimls.setup  {}
      lspconfig.clojure_lsp.setup {}
    end
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "hrsh7th/cmp-vsnip",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
      }
    },
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        completion = {
	  completeopt = "menu,emuone,noinsert",
	},
	mapping = cmp.mapping.preset.insert({
	  ["<C-Space>"] = cmp.mapping.complete(),
	  ["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
	  { name = "nvim_lsp" },
	  { name = "path" },
	}, {
	  { name = "buffer" },
        }),
	sorting = defaults.sorting,
      }
    end,
    config = function (_, opts)
      for _, source in ipairs(opts.sources) do
	source.group_index = source.group_index or 1
      end
      require'cmp'.setup(opts)
    end
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
	config = function()
	  require("luasnip.loaders.from_vscode").lazy_load()
	end,
      },
      {
        "nvim-cmp",
	dependencies = {
	  "saadparwaiz1/cmp_luasnip",
	},
	opts = function(_, opts)
	  opts.snippet = {
	    expand = function(args)
	      require("luasnip").lsp_expand(args.body)
	    end,
	  }
	  table.insert(opts.sources, { name = "luasnip" })
	end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },
}
