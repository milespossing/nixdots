;; Keymaps

;; Nav
(let [keymap (require :lib.keymap)
      plugin-utils (require :lib.plugin-utils)]
  (if vim.env.ZELLIJ
      (let [zj (require :lib.zellij)]
        (keymap.group :<c-w>z :Zellij)
        (keymap.map :<c-h> :<cmd>ZellijNavigateLeftTab<cr>
                    {:desc "Navigate left"})
        (keymap.map :<c-l> :<cmd>ZellijNavigateRightTab<cr>
                    {:desc "Navigate right"})
        (keymap.map :<c-j> :<cmd>ZellijNavigateDown<cr> {:desc "Navigate down"})
        (keymap.map :<c-k> :<cmd>ZellijNavigateUp<cr> {:desc "Navigate up"}) ; tabs
        (keymap.map :<c-w>zt #(zj.new-tab) {:desc "New zellij tab"}) ; panes
        (keymap.map :<a-n> #(zj.new-pane))
        (keymap.map :<c-w>zp #(zj.new-pane) {:desc "New pane"}) ; pane sizing
        (keymap.map :<c-w>zh #(zj.increase :left) {:desc "Increase pane left"})
        (keymap.map :<c-w>zH #(zj.decrease :left) {:desc "Decrease pane left"})
        (keymap.map :<c-w>zj #(zj.increase :down) {:desc "Increase pane down"})
        (keymap.map :<c-w>zJ #(zj.decrease :down) {:desc "Decrease pane down"})
        (keymap.map :<c-w>zl #(zj.increase :right)
                    {:desc "Increase pane right"})
        (keymap.map :<c-w>zL #(zj.decrease :right)
                    {:desc "Decrease pane right"})
        (keymap.map :<c-w>zk #(zj.increase :up) {:desc "Increase pane up"})
        (keymap.map :<c-w>zK #(zj.decrease :up) {:desc "Decrease pane up"})
        ;; misc.
        (keymap.map :<a-g> #(zj.run.lazygit))
        (keymap.map :<leader>gg #(zj.run.lazygit) {:desc :Lazygit}))
      (do
        (keymap.map :<C-h> :<C-w>h {:desc "Navigate left"})
        (keymap.map :<C-l> :<C-w>l {:desc "Navigate right"})
        (keymap.map :<C-j> :<C-w>j {:desc "Navigate down"})
        (keymap.map :<C-k> :<C-w>k {:desc "Navigate up"})))
  (keymap.map :s #(plugin-utils.flash.jump) {:desc :Flash :mode [:n :x :o]})
  (keymap.map :S #(plugin-utils.flash.treesitter)
              {:desc "Flash Treesitter" :mode [:n :x :o]})
  (let [fzf-lua (require :lib.fzf-lua)]
    (keymap.map :<leader>ff #(fzf-lua.files) {:desc "Find files"})
    (keymap.map :<leader>fr #(fzf-lua.oldfiles) {:desc "Recent Files"})
    (keymap.map "<leader>," #(fzf-lua.buffers) {:desc "Find buffers"})
    (keymap.map :<leader>hh #(fzf-lua.help-tags) {:desc "Find help tags"})
    (keymap.map :<leader>hk #(fzf-lua.keymaps) {:desc "Find keymaps"})
    (keymap.map :<leader>hc #(fzf-lua.colorschemes) {:desc :Colorschemes})
    (keymap.map :<leader>/ #(fzf-lua.grep))
    (keymap.map :<leader>/ #(fzf-lua.grep-visual)
                {:mode :v :desc "Grep selection"})
    (keymap.map :<leader>sR #(fzf-lua.resume) {:desc "Resume Search"})
    (keymap.map :<leader>sj #(fzf-lua.jumps) {:desc "Search jumps"})
    (keymap.map :<leader>sm #(fzf-lua.marks) {:desc "Search Marks"})
    (keymap.map :<leader>sh #(fzf-lua.search_history) {:desc "Search history"})
    (keymap.map :<leader>sz #(fzf-lua.undotree) {:desc :Undotree})))
