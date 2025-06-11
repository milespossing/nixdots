-- bootstrap lazy.nvim, LazyVim and your plugins

require("config.options")
if (not vim.g.vscode) then
    require("config.autocmds")
else
    require("config.vscode")
end
require("config.lazy")

require("config.plugins")

require("config.options")
