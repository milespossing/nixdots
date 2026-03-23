-- Leader keys (must be set before any mappings)
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = ''
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.splitbelow = true
vim.opt.splitright = true
