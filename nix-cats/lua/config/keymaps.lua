local catsUtils = require 'nixCatsUtils'
local map = function(mode, lhs, rhs, opts, category)
  if category == nil or catsUtils.enableForCategory(category) then
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Windows
map('n', '<leader>wh', '<C-w>h', { desc = 'Move Window Left' })
map('n', '<leader>wj', '<C-w>j', { desc = 'Move Window Down' })
map('n', '<leader>wk', '<C-w>k', { desc = 'Move Window Up' })
map('n', '<leader>wl', '<C-w>l', { desc = 'Move Window Right' })
map('n', '<leader>w-', '<cmd>split<cr>', { desc = 'Split Horizontal' })
map('n', '<leader>w\\', '<cmd>vsplit<cr>', { desc = 'Split Vertial' })

-- Help
map('n', '<leader>hh', function()
  Snacks.picker.help()
end, { desc = 'Help tags' }, 'editor')
map('n', '<leader>hc', function()
  Snacks.picker.commands()
end, { desc = 'Commands' }, 'editor')
map('n', '<leader>ha', function()
  Snacks.picker.autocmds()
end, { desc = 'Autocommands' }, 'editor')
map('n', '<leader>hk', function()
  Snacks.picker.keymaps()
end, { desc = 'Keymaps' }, 'editor')
map('n', '<leader>uc', function()
  Snacks.picker.colorschemes()
end, { desc = 'Colorscheme' }, 'editor')
map('n', '<leader>us', function()
  Snacks.scratch()
end, { desc = 'Open Scratch' }, 'editor')
map('n', '<leader>uS', function()
  Snacks.scratch.list()
end, { desc = 'List Scratches' }, 'editor')

-- Git
map('n', '<leader>gf', function()
  Snacks.picker.git_files()
end, { desc = 'Git Files' }, 'editor')
map('n', '<leader>gl', function()
  Snacks.picker.git_log_file()
end, { desc = 'Log File' }, 'editor')

-- Folds
-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
map('n', 'zR', require('ufo').openAllFolds)
map('n', 'zM', require('ufo').closeAllFolds)

-- Toggles
if catsUtils.enableForCategory 'editor' then
  Snacks.toggle.line_number():map '<leader>ul'
  Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
  Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
  Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
  Snacks.toggle.dim():map '<leader>uD'
  Snacks.toggle.zen():map '<leader>uz'
  Snacks.toggle.animate():map '<leader>ua'
  require('utils.toggles').auto_format:map '<leader>of'
end

-- Search

map('n', '<leader>s:', function()
  Snacks.picker.command_history()
end, { desc = 'Command History' }, 'editor')
map('n', '<leader>sj', function()
  Snacks.picker.jumps()
end, { desc = 'Jumps' }, 'editor')
map('n', '<leader>s"', function()
  Snacks.picker.registers()
end, { desc = 'Registers' }, 'editor')
map('n', '<leader>sm', function()
  Snacks.picker.marks()
end, { desc = 'Marks' }, 'editor')
map('n', '<leader>sr', function()
  require('grug-far').open()
end, { desc = 'Find and Replace' }, 'editor')
map('n', '<leader>sR', function()
  Snacks.picker.resume()
end, { desc = 'Resume' }, 'editor')

-- Terminal
if catsUtils.enableForCategory 'editor' then
  local term = require 'utils.term'
  vim.keymap.set('n', '<leader>gg', function()
    term.lazygit:toggle()
  end, { desc = 'Lazygit' })
end
