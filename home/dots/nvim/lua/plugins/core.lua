
return {
    {
      'echasnovski/mini.nvim',
      version = '*',
      lazy = false,
    },
    {
      'shaunsingh/nord.nvim',
      config = function()
          vim.cmd[[colorscheme nord]]
      end,
      lazy = false,
    },
    { 'folke/which-key.nvim' },
    { 'folke/trouble.nvim' },
}
