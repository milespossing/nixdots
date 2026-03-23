;; Keymaps

(let [keymap (require :lib.keymap)]
  (keymap.map :n :<C-h> :<C-w>h)
  (keymap.map :n :<C-l> :<C-w>l)
  (keymap.map :n :<C-j> :<C-w>j)
  (keymap.map :n :<C-k> :<C-w>k))
  
