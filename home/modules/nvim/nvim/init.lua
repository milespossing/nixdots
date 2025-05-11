-- bootstrap lazy.nvim, LazyVim and your plugins

require("config.options")
require("config.autocmds")
require("config.lazy")

if vim.g.vscode then
else
require("config.plugins")
vim.cmd.colorscheme("catppuccin")
end

require("config.options")
