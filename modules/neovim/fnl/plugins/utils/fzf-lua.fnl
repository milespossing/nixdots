(fn after [] (let [keymap (require :lib.keymap)
                    fzf-lua (require :fzf-lua)]
               (keymap.map :n :<leader>ff #(fzf-lua.files) {:desc "Find files"})
               (keymap.map :n "<leader>," #(fzf-lua.buffers) {:desc "Find buffers"})
               (keymap.map :n "<leader>hh" #(fzf-lua.help_tags) {:desc "Find help tags"})
               (keymap.map :n "<leader>hk" #(fzf-lua.keymaps) {:desc "Find keymaps"})))

{:name :fzf-lua
 :after after}
