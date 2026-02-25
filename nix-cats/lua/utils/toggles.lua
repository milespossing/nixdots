local toggle = require 'snacks.toggle'

local M = {}

M.auto_format = toggle.new {
  id = 'autoformat_on_save',
  name = 'Autoformat on Save',
  get = function()
    return vim.g.autoformat_on_save
  end,
  set = function(value)
    vim.g.autoformat_on_save = value
  end,
}

return M
