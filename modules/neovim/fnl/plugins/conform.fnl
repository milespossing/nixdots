;; conform.nvim — formatter integration
;; Format on save with per-filetype formatters.

(fn after []
  (let [conform (require :conform)
        km (require :lib.keymap)]
    (conform.setup
      {:formatters_by_ft {:fennel [:fnlfmt]
                          :lua [:stylua]
                          :nix [:nixfmt]
                          :javascript [:prettierd]
                          :typescript [:prettierd]
                          :javascriptreact [:prettierd]
                          :typescriptreact [:prettierd]
                          :json [:prettierd]
                          :yaml [:prettierd]
                          :html [:prettierd]
                          :css [:prettierd]
                          :markdown [:prettierd]}
       :format_on_save {:timeout_ms 500
                        :lsp_format :fallback}})
    (km.map :<leader>cf
            #(conform.format {:async true :lsp_format :fallback})
            {:desc "Format buffer"})))

{:name :conform.nvim
 :event [:BufWritePre]
 :after after}
