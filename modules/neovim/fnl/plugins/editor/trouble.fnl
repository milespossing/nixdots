(fn after []
  (let [trouble (require :trouble)
        key (require :lib.keymap)]
    (trouble.setup {})
    (key.map :n :<leader>xx "<cmd>Trouble diagnostics toggle<cr>")))
    
{:name :trouble.nvim
 :after after}
