
return {
    {
      'echasnovski/mini.nvim',
      version = false,
      lazy = false,
      config = function ()
        require('mini.animate').setup()
        require('mini.comment').setup()
        require('mini.diff').setup()
        require('mini.indentscope').setup()
        require('mini.surround').setup()
      end
    },
}
