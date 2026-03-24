(fn after []
  (let [trouble (require :trouble)
        key (require :lib.keymap)]
    (trouble.setup {:modes {:lsp {:win {:position :right}}}})
    (key.map :<leader>xx "<cmd>Trouble diagnostics toggle<cr>")
    (let [config (require "fzf-lua.config")
          actions (. (require "trouble.sources.fzf") :actions)]
      (tset config.defaults.actions.files "ctrl-t" actions.open))))

{:name :trouble.nvim
 :event :DeferredUIEnter
 :after after}
