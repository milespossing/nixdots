return {
  {
    'nvim-neorg/neorg',
    lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    version = '*', -- Pin Neorg to the latest stable release
    enabled = require('nixCatsUtils').enableForCategory 'full',
    opts = {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/neorg',
            },
            default_workspace = 'notes',
          },
        },
        ['core.keybinds'] = {
          config = {
            default_keybinds = false,
          },
        },
        ['core.syntax'] = {},
      },
    },
    keys = {
      { '<leader>nn', '<Plug>(neorg.dirman.new-note)', desc = 'new note' },
    },
  },
}
