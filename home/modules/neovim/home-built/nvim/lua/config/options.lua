-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.wsl = os.getenv("WSL")
vim.g.windows = package.config:sub(1,1) == '\\'

if os.getenv("WSL") then
    vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
            ['+'] = 'win32yank.exe -i',
            ['*'] = 'win32yank.exe -i',
        },
        paste = {
            ['+'] = 'win32yank.exe -o --lf',
            ['*'] = 'win32yank.exe -o --lf',
        },
        cache_enabled = false,
    }
end

vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.confirm = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Open all folds by default
vim.opt.foldlevelstart = 99 -- Open folds when a file is opened
vim.opt.foldenable = true -- Enable folding

vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'

vim.g.use_ai = true
vim.g.ai_cmp = true
vim.g.use_noice = false
vim.g.use_cmp = true
-- Whether we should be using blink
vim.g.use_blink = false
