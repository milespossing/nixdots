return {
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = {
      adapters = {
        ['pwa-node'] = {
          type = 'server',
          host = 'localhost',
          port = '${port}',
          executable = {
            command = 'js-debug',
            args = { '${port}' },
          },
        },
      },
    },
  },
}
