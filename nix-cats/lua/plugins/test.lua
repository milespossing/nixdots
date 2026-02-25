return {
  {
    'nvim-neotest/neotest',
    enabled = require('nixCatsUtils').enableForCategory 'test',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function(_, opts)
      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters) do
          local adapter = require(name)
          if type(config) == 'table' and not vim.tbl_isempty(config) then
            if adapter.setup then
              adapter.setup(config)
            elseif adapter.adapter then
              adapter.adapter(config)
              adapter = adapter.adapter
            end
          end
          adapters[#adapters + 1] = adapter
        end
        opts.adapters = adapters
      end
      opts.consumers = opts.consumers or {}
      opts.consumers.trouble = function(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return
          end
          local tree = assert(client:get_position(nil, { adapter = adapter_id }))

          local failed = 0
          for pos_id, result in pairs(results) do
            if result.status == 'failed' and tree:get_key(pos_id) then
              failed = failed + 1
            end
          end
          vim.schedule(function()
            local trouble = require 'trouble'
            if trouble.is_open() then
              trouble.refresh()
              if failed == 0 then
                trouble.close()
              end
            end
          end)
          return {}
        end
      end
      require('neotest').setup(opts)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'neotest-output' },
        callback = function(ev)
          vim.keymap.set('n', 'q', '<CMD>q<CR>', { buffer = ev.buf, silent = true, nowait = true })
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>ts', function() require 'neotest'.summary.toggle() end, desc = 'Test Summary' },
      { '<leader>tt', function() require 'neotest'.run.run(vim.fn.expand("%")) end, desc = 'Run Test (File)' },
      { '<leader>tT', function() require 'neotest'.run.run(vim.uv.cwd()) end, desc = 'Run All Test Files' },
      { '<leader>tr', function() require 'neotest'.run.run() end, desc = 'Run Test (Nearest)' },
      { '<leader>tl', function() require 'neotest'.run.run_last() end, desc = 'Run Last Test' },
      { "<leader>tw", function() require 'neotest'.watch.toggle(vim.fn.expand("%")) end, desc = "Watch File" },
      { '<leader>td', function() require 'neotest'.run.run({strategy='dap'}) end, desc = 'Debug Test' },
      { '<leader>to', function() require 'neotest'.output.open({ enter = true, auto_close = true }) end, desc = "Show output" },
      { '<leader>tO', function() require 'neotest'.output_panel.toggle() end, desc = 'Test Output Panel' },
    },
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = {
      'marilari88/neotest-vitest',
    },
    opts = {
      adapters = {
        ['neotest-vitest'] = {},
      },
    },
  },
}
