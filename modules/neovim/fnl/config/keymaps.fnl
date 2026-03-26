;; Keymaps

;; Nav
(let [km (require :lib.keymap)
      plugin-utils (require :lib.plugin-utils)]
  (if vim.env.ZELLIJ
      (let [zj (require :lib.zellij)]
        (km.group :<c-w>z :Zellij)
        (km.map :<c-h> :<cmd>ZellijNavigateLeftTab<cr> {:desc "Navigate left"})
        (km.map :<c-l> :<cmd>ZellijNavigateRightTab<cr>
                {:desc "Navigate right"})
        (km.map :<c-j> :<cmd>ZellijNavigateDown<cr> {:desc "Navigate down"})
        (km.map :<c-k> :<cmd>ZellijNavigateUp<cr> {:desc "Navigate up"}) ; tabs
        (km.map :<c-w>zt #(zj.new-tab) {:desc "New zellij tab"}) ; panes
        (km.map :<a-n> #(zj.new-pane))
        (km.map :<c-w>zp #(zj.new-pane) {:desc "New pane"}) ; pane sizing
        (km.map :<c-w>zh #(zj.increase :left) {:desc "Increase pane left"})
        (km.map :<c-w>zH #(zj.decrease :left) {:desc "Decrease pane left"})
        (km.map :<c-w>zj #(zj.increase :down) {:desc "Increase pane down"})
        (km.map :<c-w>zJ #(zj.decrease :down) {:desc "Decrease pane down"})
        (km.map :<c-w>zl #(zj.increase :right) {:desc "Increase pane right"})
        (km.map :<c-w>zL #(zj.decrease :right) {:desc "Decrease pane right"})
        (km.map :<c-w>zk #(zj.increase :up) {:desc "Increase pane up"})
        (km.map :<c-w>zK #(zj.decrease :up) {:desc "Decrease pane up"})
        ;; misc.
        (km.map :<a-g> #(zj.run.lazygit))
        (km.map :<leader>gg #(zj.run.lazygit) {:desc :Lazygit}))
      (do
        (km.map :<C-h> :<C-w>h {:desc "Navigate left"})
        (km.map :<C-l> :<C-w>l {:desc "Navigate right"})
        (km.map :<C-j> :<C-w>j {:desc "Navigate down"})
        (km.map :<C-k> :<C-w>k {:desc "Navigate up"})))
  (km.map :s #(plugin-utils.flash.jump) {:desc :Flash :mode [:n :x :o]})
  (km.map :S #(plugin-utils.flash.treesitter)
          {:desc "Flash Treesitter" :mode [:n :x :o]})
  (let [fzf-lua (require :lib.fzf-lua)]
    (km.map :<leader>ff #(fzf-lua.files) {:desc "Find files"})
    (km.map :<leader>fr #(fzf-lua.oldfiles) {:desc "Recent Files"})
    (km.map "<leader>," #(fzf-lua.buffers) {:desc "Find buffers"})
    (km.map :<leader>hh #(fzf-lua.help-tags) {:desc "Find help tags"})
    (km.map :<leader>hk #(fzf-lua.keymaps) {:desc "Find keymaps"})
    (km.map :<leader>hc #(fzf-lua.colorschemes) {:desc :Colorschemes})
    (km.map :<leader>/ #(fzf-lua.live-grep))
    (km.map :<leader>/ #(fzf-lua.grep-visual) {:mode :v :desc "Grep selection"})
    (km.map :<leader>sR #(fzf-lua.resume) {:desc "Resume Search"})
    (km.map :<leader>sj #(fzf-lua.jumps) {:desc "Search jumps"})
    (km.map :<leader>sm #(fzf-lua.marks) {:desc "Search Marks"})
    (km.map :<leader>sh #(fzf-lua.search_history) {:desc "Search history"})
    (km.map :<leader>sz #(fzf-lua.undotree) {:desc :Undotree}))
  (km.map :gs "<Plug>(nvim-surround-normal)" {:desc :Surround})
  (km.map :gss "<Plug>(nvim-surround-normal-cur)" {:desc "Surround Current"})
  (km.map :gsS "<Plug>(nvim-surround-normal-line)" {:desc "Surround Line"})
  (km.map :gsa "<Plug>(nvim-surround-visual)" {:mode :x :desc :Surround})
  (km.map :gsA "<Plug>(nvim-surround-visual-line)"
          {:mode :x :desc "Surround Line"})
  (km.map :gsd "<Plug>(nvim-surround-delete)" {:desc "Delete Surround"})
  (km.map :gsr "<Plug>(nvim-surround-change)" {:desc "Change Surround"})
  (km.map :gsR "<Plug>(nvim-surround-change-line)"
          {:desc "Change Surround - New Line"})
  (km.map :<c-g>s "<Plug>(nvim-surround-insert)" {:desc :Surround}))
