(local helpers (require :plugins.helpers))

[{1 :catppuccin/nvim :name :catppuccin :priority 1000}
 {1 :nvim-neo-tree/neo-tree.nvim
  :dependencies [:nvim-lua/plenary.nvim
                 :nvim-tree/nvim-web-devicons
                 :MunifTanjim/nui.nvim]
  :keys [{1 :<leader>e 2 :<cmd>Neotree<cr> :desc :NeoTree}]}
 {1 :akinsho/bufferline.nvim
  :version "*"
  :dependencies [:nvim-tree/nvim-web-devicons]}
 {1 :nvim-lualine/lualine.nvim :config (lambda [] (helpers.setup :lualine {}))}
 {1 :folke/noice.nvim :event :VeryLazy :dependencies [:MunifTanjim/nui.nvim :rcarriga/nvim-notify]}]
