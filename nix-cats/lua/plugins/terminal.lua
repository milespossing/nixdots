return {
  {
    'akinsho/toggleterm.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    version = '*',
    opts = {
      open_mapping = [[<c-t>]],
      hide_numbers = true,
      shell = vim.o.shell,
    },
  },
}
