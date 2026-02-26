return {
  {
    'swaits/zellij-nav.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    opts = {},
    event = 'VeryLazy',
    keys = {
      { '<c-w>z', group = 'Zellij', enabled = vim.env.ZELLIJ },
      { '<c-h>', '<cmd>ZellijNavigateLeftTab<cr>', desc = 'Navigate left/tab' },
      { '<c-j>', '<cmd>ZellijNavigateDown<cr>', desc = 'Navigate down' },
      { '<c-k>', '<cmd>ZellijNavigateUp<cr>', desc = 'Navigate up' },
      { '<c-l>', '<cmd>ZellijNavigateRightTab<cr>', desc = 'Navigate right/tab' },
    },
    init = function()
      if not vim.env.ZELLIJ then
        return
      end
      local zj = function(args)
        vim.fn.system { 'zellij', 'action', unpack(args) }
      end

      -- Panes
      vim.keymap.set('n', '<A-n>', function()
        zj { 'new-pane', '--direction', 'down' }
      end, { desc = 'Zellij: new pane down' })
      vim.keymap.set('n', '<A-N>', function()
        zj { 'new-pane', '--direction', 'right' }
      end, { desc = 'Zellij: new pane right' })
      vim.keymap.set('n', '<A-f>', function()
        zj { 'toggle-floating-panes' }
      end, { desc = 'Zellij: toggle floating pane' })

      -- Resize panes
      vim.keymap.set('n', '<C-w>Z', function()
        require('which-key').show { keys = '<C-w>z', loop = true }
      end, { desc = 'Zellij: Window (hydra)' })
      vim.keymap.set('n', '<C-w>zh', function()
        zj { 'resize', 'increase', 'left' }
      end, { desc = 'Zellij: resize pane left' })
      vim.keymap.set('n', '<C-w>zH', function()
        zj { 'resize', 'decrease', 'left' }
      end, { desc = 'Zellij: resize pane left' })
      vim.keymap.set('n', '<C-w>zl', function()
        zj { 'resize', 'increase', 'right' }
      end, { desc = 'Zellij: resize pane right' })
      vim.keymap.set('n', '<C-w>zL', function()
        zj { 'resize', 'decrease', 'right' }
      end, { desc = 'Zellij: resize pane right' })
      vim.keymap.set('n', '<C-w>zj', function()
        zj { 'resize', 'increase', 'down' }
      end, { desc = 'Zellij: resize pane down' })
      vim.keymap.set('n', '<C-w>zJ', function()
        zj { 'resize', 'decrease', 'down' }
      end, { desc = 'Zellij: resize pane down' })
      vim.keymap.set('n', '<C-w>zk', function()
        zj { 'resize', 'increase', 'up' }
      end, { desc = 'Zellij: resize pane up' })
      vim.keymap.set('n', '<C-w>zK', function()
        zj { 'resize', 'decrease', 'up' }
      end, { desc = 'Zellij: resize pane up' })
    end,
  },
}
