return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    enabled = require('nixCatsUtils').enableForCategory('treesitter'),
    build = require('nixCatsUtils').lazyAdd ':TSUpdate',
    opts = {
      -- NOTE: nixCats: use lazyAdd to only set these 2 options if nix wasnt involved.
      -- because nix already ensured they were installed.
      ensure_installed = require('nixCatsUtils').lazyAdd { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      auto_install = require('nixCatsUtils').lazyAdd(true, false),

      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
}
