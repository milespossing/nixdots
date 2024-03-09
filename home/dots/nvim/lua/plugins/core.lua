
return {
    { 'echasnovski/mini.nvim', version = '*' },
    { 'shaunsingh/nord.nvim',
        config = function()
            vim.cmd[[colorscheme nord]]
        end
    },
    { 'nvim-telescope/telescope.nvim' },
    { 'folke/which-key.nvim' },
    { 'folke/trouble.nvim' },
    -- { 'folke/todo-comments.nvim' },
    -- { 'folke/lsp-colors.nvim' },
    -- { 'folke/lsp-trouble' },
}