return {
  {
    'yetone/avante.nvim',
    enabled = require('nixCatsUtils').enableForCategory('full'),
    event = 'VeryLazy',
    dependencies = {
      'zbirenbaum/copilot.lua',
    },
    version = false,
    opts = {
      provider = 'copilot',
      providers = {
        openai = {
          endpoint = 'https://api.openai.com/v1',
          model = 'o3-mini',
          api_key_name = 'cmd:bat $AVANTE_OPENAI_PATH',
        },
        ['openai-5-mini'] = {
          __inherited_from = 'openai',
          endpoint = 'https://api.openai.com/v1',
          model = 'gpt-5-mini',
          extra_request_body = {
            temperature = 1,
          },
        },
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    optional = true,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
    init = function()
      require('copilot.api').status = require 'copilot.status'
    end,
  },
  {
    'saghen/blink.cmp',
    enabled = require('nixCatsUtils').enableForCategory('full'),
    dependencies = {
      'Kaiser-Yang/blink-cmp-avante',
    },
    opts = {
      sources = {
        default = { 'avante' },
        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
          },
        },
      },
    },
  },
}
