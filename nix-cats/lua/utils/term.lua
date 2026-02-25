-- Terminal macros

local M = {}

local Terminal = require('toggleterm.terminal').Terminal
M.lazygit = Terminal:new {
  cmd = 'lazygit',
  hidden = true,
  dir = 'git_dir',
  direction = 'float',
  float_opts = {
    border = 'double',
  },
  on_open = function(term)
    vim.cmd 'startinsert!'
    vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<cr>', { noremap = true, silent = true })
  end,
  on_close = function(term)
    vim.cmd 'stopinsert'
  end,
}

return M
