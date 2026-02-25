return {
  -- TODO: We want to add a bit more to this
  {
    'nvim-lualine/lualine.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'encoding', 'fileformat', 'filetype', 'lsp_status' },
        lualine_y = { 'progress', 'location' },
        lualine_z = { { 'datetime', style = '%H:%M' } },
      },
      inactive_sections = {},
    },
  },
  {
    'folke/noice.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'editor',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      routes = {
        {
          filter = { event = 'notify', find = 'DEBUG:' },
          view = 'mini',
          opts = { replace = true },
        },
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },

      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
      },
    },
  },
  {
    'folke/snacks.nvim',
    enabled = require('nixCatsUtils').enableForCategory 'full',
    opts = {
      dashboard = {
        enabled = true,
      },
    },
  },
  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = {
      bottom = {
        {
          ft = 'toggleterm',
          size = { height = 0.4 },
          -- exclude floating windows
          filter = function(buf, win)
            return vim.api.nvim_win_get_config(win).relative == ''
          end,
        },
        {
          ft = 'help',
          size = { height = 20 },
          filter = function(buf)
            return vim.bo[buf].buftype == 'help'
          end,
        },
        {
          title = 'Test Output',
          ft = 'neotest-output-panel',
          size = { height = 0.4 },
        },
        'trouble',
        {
          title = 'Debug Repl',
          ft = 'dap-repl',
          size = { height = 0.3 },
        },
        {
          title = 'Debug Console',
          ft = 'dapui_console',
          size = { height = 0.3 },
        },
      },
      left = {
        {
          title = 'File Explorer',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'filesystem'
          end,
          size = { height = 0.5, width = 50 },
        },
        {
          title = 'Neo-Tree Buffers',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'buffers'
          end,
        },
        {
          title = 'Neo-Tree Git Status',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'git_status'
          end,
        },
        {
          title = 'Neo-Tree Document Symbols',
          ft = 'neo-tree',
          filter = function(buf)
            return vim.b[buf].neo_tree_source == 'document_symbols'
          end,
        },
      },
      right = {
        {
          title = 'Test Summary',
          ft = 'neotest-summary',
          size = { width = 50 },
        },
      },
      animate = {
        enabled = true,
      },
      wo = {
        winbar = true,
      },
      icons = {
        closed = ' ',
        open = ' ',
      },
    },
  },
}
