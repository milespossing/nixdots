local icons = require 'config.icons'
return {
  {
    'mfussenegger/nvim-dap',
    enabled = require('nixCatsUtils').enableForCategory 'full',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      -- virtual text for the debugger
      {
        'theHamsta/nvim-dap-virtual-text',
        opts = {},
      },
    },
    config = function(_, opts)
      local dap = require 'dap'
      dap.adapters = opts.adapters
      for name, sign in pairs(icons.dap) do
        sign = type(sign) == 'table' and sign or { sign }
        vim.fn.sign_define('Dap' .. name, {
          text = sign[1],
          texthl = sign[2] or 'DiagnosticInfo',
          linehl = sign[3],
          numhl = sign[3],
        })
      end
    end,
    -- stylua: ignore
    keys = {
      { '<leader>db', require('dap').toggle_breakpoint, desc = 'Toggle Breakpoint' },
      { '<leader>dT', function() require('dap').terminate() end, desc = 'Terminate' },
      { '<leader>dC', function() require('dap').run_to_cursor() end },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Toggle REPL' },
      { '<leader>D', function() require('which-key').show { keys = '<leader>dd', loop = true } end, desc = 'Debug Commands' },
      { '<leader>dd', group = 'Debug Commands' },
      { '<leader>ddc', function() require('dap').continue() end, desc = 'Continue' },
      { '<leader>ddi', function() require('dap').step_into() end, desc = 'Step Into' },
      { '<leader>ddo', function() require('dap').step_over() end, desc = 'Step Over' },
      { '<leader>ddO', function() require('dap').step_out() end },
      { '<leader>dw', function() require('dap.ui.widgets').hover() end, desc = 'Widgets' },
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    optional = true,
    dependencies = { 'nvim-neotest/nvim-nio' },
    opts = {},
    config = function(_, opts)
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup(opts)
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open {}
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close {}
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close {}
      end
    end,
    -- stylua: ignore
    keys = {
      { '<leader>du', function() require('dapui').toggle {} end, desc = 'Dap UI' },
      { '<leader>de', function() require('dapui').eval() end, desc = 'Eval', mode = { 'n', 'v' } },
    },
  },
}
