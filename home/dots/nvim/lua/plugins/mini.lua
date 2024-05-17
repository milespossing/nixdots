
return {
    {
      'echasnovski/mini.nvim',
      version = '*',
      lazy = false,
      config = function ()
        require('mini.animate').setup()
        require('mini.surround').setup()
        require('mini.comment').setup()
        require('mini.indentscope').setup()
      end
    },
}
