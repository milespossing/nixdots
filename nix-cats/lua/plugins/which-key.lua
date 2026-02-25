return {
  {
    'folke/which-key.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    event = 'VeryLazy', -- Sets the loading event to 'VimEnter'
    opts_extend = { 'spec' },
    opts = {
      preset = 'helix',
      spec = {
        {
          mode = { 'n', 'v' },
          { '<leader>c', group = 'code' },
          { '[', group = 'prev' },
          { ']', group = 'next' },
          { '<leader>a', group = 'ai' },
          { '<leader>d', group = 'debug' },
          { '<leader>s', group = 'search' },
          { '<leader>f', group = 'file/find' },
          { '<leader>g', group = 'git' },
          { '<leader>gh', group = 'hunks' },
          { '<leader>h', group = 'help', icon = ' ' },
          { '<leader>n', group = 'notes', icon = ' ' },
          { '<leader>o', group = 'toggle' },
          { '<leader>u', group = 'ui' },
          { '<leader>x', group = 'diagnostics' },
          {
            '<leader>w',
            group = 'window',
            expand = function()
              return require('which-key.extras').expand.win()
            end,
          },
          {
            '<leader>b',
            group = 'buffer',
            expand = function()
              return require('which-key.extras').expand.buf()
            end,
          },
          {
            '<c-w><space>',
            function()
              require('which-key').show { keys = '<c-w>', loop = true }
            end,
            desc = 'Window (hydra)',
          },
        },
      },
    },
  },
}
