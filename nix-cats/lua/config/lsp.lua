local capabilities = vim.lsp.protocol.make_client_capabilities()

local capabilities_final = require('blink.cmp').get_lsp_capabilities(capabilities)

vim.lsp.config('*', {
  capabilities = capabilities_final,
  root_markers = { '.git' },
})

vim.lsp.config('ts_ls', {
  capabilities = capabilities_final,
  on_attach = function(_, bufnr)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end
    local map_action = function(mode, lhs, actions, desc)
      map(mode, lhs, function()
        vim.lsp.buf.code_action {
          context = {
            only = actions,
          },
          apply = true,
        }
      end, desc)
    end
    map('n', '<leader>ca', function()
      vim.lsp.buf.code_action()
    end, 'Lsp Code [A]ction')
    map_action('n', '<leader>cA', { 'source.fixAll' }, 'Fix [A]ll')
    map_action('n', '<leader>ci', { 'source.addMissingImports.ts', 'source.addMissingImports' }, 'Add Missing [I]mports')
    map_action('n', '<leader>cr', { 'source.organizeImports' }, 'O[r]ganize Imports')
  end,
})
vim.lsp.config('luals', {
  capabilities = capabilities_final,
})
vim.lsp.config('nixd', {
  capabilities = capabilities_final,
})
vim.lsp.config('jsonls', {
  capabilities = capabilities_final,
})

vim.lsp.config('tinymist', {
  capabilities = capabilities_final,
})

vim.lsp.config('clojure-lsp', {
  capabilities = capabilities_final,
})

vim.lsp.config('marksman', {
  capabilities = capabilities_final,
})

vim.lsp.config('yaml-language-server', {
  capabilities = capabilities_final,
})

vim.lsp.enable {
  'ts_ls',
  'luals',
  'marksman',
  'nixd',
  'jsonls',
  'tinymist',
  'clojure-lsp',
  'yaml-language-server',
}

-- Default inlay hints
vim.lsp.inlay_hint.enable(true)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-keymaps', { clear = true }),
  callback = function(args)
    local toggle = require 'snacks.toggle'
    local opts = { buffer = args.buf, silent = true }
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', opts, { desc = desc }))
    end
    map({ 'n', 'v' }, 'gd', Snacks.picker.lsp_definitions, 'Lsp Definitions')
    map({ 'n', 'v' }, 'gD', Snacks.picker.lsp_declarations, 'Lsp Definitions')
    map('n', 'grr', Snacks.picker.lsp_references, 'Lsp References')
    map('n', '<leader>ss', Snacks.picker.lsp_symbols, 'Lsp Symbols')
    map('n', '<leader>sS', Snacks.picker.lsp_workspace_symbols, 'Lsp Workspace Symbols')
    toggle.inlay_hints():map '<leader>ch'
  end,
})
