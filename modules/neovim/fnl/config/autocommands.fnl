
(local km (require :lib.keymap))
(local au (require :lib.auto-cmd))
(local fzf-lua (require :lib.fzf-lua))

;; fzf lsp
(au.group! :lsp-keymaps
               [[:LspAttach]
                {:callback (fn [args]
                             (km.map :gd
                                     #(fzf-lua.lsp-definitions
                                        {:profile :ivy})
                                     {:mode [:n :v]
                                      :buffer args.buf
                                      :silent true
                                      :desc "Lsp Definitions"})
                             (km.map :grr
                                     #(fzf-lua.lsp-references {:profile :ivy})
                                     {:buffer args.buf
                                      :silent true
                                      :desc "Lsp References"})
                             (km.map :grr
                                     #(fzf-lua.lsp-document-symbols)
                                     {:buffer args.buf
                                      :silent true
                                      :desc "Document Symbols"}))}])
