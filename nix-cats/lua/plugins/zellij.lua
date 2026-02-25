return {
  {
    'swaits/zellij-nav.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    opts = {},
    event = 'VeryLazy',
    keys = {
      { '<c-h>', '<cmd>ZellijNavigateLeftTab<cr>', desc = 'Navigate left/tab' },
      { '<c-j>', '<cmd>ZellijNavigateDown<cr>', desc = 'Navigate down' },
      { '<c-k>', '<cmd>ZellijNavigateUp<cr>', desc = 'Navigate up' },
      { '<c-l>', '<cmd>ZellijNavigateRightTab<cr>', desc = 'Navigate right/tab' },
    },
  },
}
