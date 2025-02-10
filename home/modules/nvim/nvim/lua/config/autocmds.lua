-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.keymaps")
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
    end, { buffer = buf, desc = "Go to definition" })
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
    end, { buffer = buf })
    vim.keymap.set("n", "grr", function()
      vim.lsp.buf.references()
    end, { buffer = buf })
    vim.keymap.set("n", "grn", function()
      vim.lsp.buf.rename()
    end, { buffer = buf })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"typescript", "javascript"},
    command = "set shiftwidth=2 tabstop=2",
});
