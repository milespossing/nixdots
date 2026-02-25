return {
  {
    'mason-org/mason.nvim',
    enabled = not require('nixCatsUtils').isNixCats,
    opts = {},
  },
}
