return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    enabled = require('nixCatsUtils').enableForCategory('treesitter'),
    build = require('nixCatsUtils').lazyAdd ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup {}

      -- Install parsers when not managed by nix
      if require('nixCatsUtils').lazyAdd(true, false) then
        require('nvim-treesitter').install { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' }
      end

      -- Enable treesitter-based highlighting and indentation for supported filetypes
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
