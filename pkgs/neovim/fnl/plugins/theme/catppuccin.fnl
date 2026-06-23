{:name :catppuccin-nvim
 :colorscheme [:catppuccin
               :catppuccin-macchiato
               :catppuccin-frappe
               :catppuccin-latte
               :catppuccin-mocha]
 :after (fn [] (let [C (require :catppuccin)]
                 (C.setup {:integrations {:lualine true}})))}
