return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml' },
  settings = {
    yaml = {
      format = { enable = true },
      completion = { enable = true },
      validate = { enable = true },
    },
  },
}
