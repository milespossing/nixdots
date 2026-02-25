return {
  {
    'saghen/blink.cmp',
    enabled = require('nixCatsUtils').enableForCategory 'full',
    version = '*',
    event = 'InsertEnter',
    dependencies = {
      'fang2hou/blink-copilot',
    },
    opts = {
      keymap = { preset = 'default' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      completion = {
        documentation = { auto_show = false },
        ghost_text = { enabled = true },
        menu = {
          direction_priority = function()
            local ctx = require('blink.cmp').get_context()
            local item = require('blink.cmp').get_selected_item()
            if ctx == nil or item == nil then
              return { 's', 'n' }
            end

            local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
            local is_multi_line = item_text:find '\n' ~= nil

            -- after showing the menu upwards, we want to maintain that direction
            -- until we re-open the menu, so store the context id in a global variable
            if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
              vim.g.blink_cmp_upwards_ctx_id = ctx.id
              return { 'n', 's' }
            end
            return { 's', 'n' }
          end,
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
          cmdline = {
            enabled = function()
              return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match "^[%%0-9,'<>%-]*!"
            end,
            async = true,
          },
        },
      },
    },
    specs = {
      {
        'catppuccin',
        optional = true,
        opts = {
          integrations = { blink_cmp = true },
        },
      },
      {
        'zbirenbaum/copilot.lua',
        opts = function(_, opts)
          opts.suggestion = { enabled = false }
          opts.panel = { enabled = false }
        end,
        init = function()
          vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuOpen',
            callback = function()
              vim.b.copilot_suggestion_hidden = true
            end,
          })
          vim.api.nvim_create_autocmd('User', {
            pattern = 'BlinkCmpMenuClose',
            callback = function()
              vim.b.copilot_suggestion_hidden = false
            end,
          })
        end,
      },
    },
  },
  {
    'saghen/blink.compat',
    optional = true,
    lazy = true,
  },
}
