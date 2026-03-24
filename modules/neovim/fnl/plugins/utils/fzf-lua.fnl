(fn after []
  (let [fzf-lua (require :fzf-lua)]
    (fzf-lua.setup {:files {:previewer :bat}})))

{:name :fzf-lua
 :event :DeferredUIEnter
 :dep_of :trouble.nvim
 :after after}
