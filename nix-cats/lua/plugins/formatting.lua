return {
  {
    'stevearc/conform.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    lazy = false,
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_fallback = true, timeout_ms = 1000 }
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function()
        if vim.g.autoformat_on_save then
          return {
            lsp_format = 'fallback',
            timeout_ms = 500,
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        typescript = { 'eslint_d', 'prettierd' },
        typescriptreact = { 'eslint_d', 'prettierd' },
        json = { 'prettierd' },
        markdown = { 'prettierd', 'markdownlint-cli2' },
        ['markdown.mdx'] = { 'prettierd', 'markdownlint-cli2' },
        yaml = { 'yamlfmt' },
      },
    },
    init = function()
      vim.g.autoformat_on_save = true
    end,
  },
}
