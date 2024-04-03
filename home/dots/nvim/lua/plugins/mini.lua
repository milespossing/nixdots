
return {
    {
      'echasnovski/mini.nvim',
      version = '*',
      lazy = false,
      config = function ()
        require('mini.comment').setup()
      end
    },
}
