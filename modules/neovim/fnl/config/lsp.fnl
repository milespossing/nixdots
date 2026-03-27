;; LSP configuration

(fn attach-base [_ buf]
  (let [km (require :lib.keymap)
        picker (require :lib.picker)]
    (km.group :<leader>c :Code)
    (km.map :gd #(picker.lsp-definitions) {:desc "Lsp Definitions"})
    (km.map :grr #(picker.lsp-references) {:desc "Lsp References"})
    (km.map :xs #(picker.lsp-document-symbols) {:desc "Document symbols"})
    (km.map :<leader>ca vim.lsp.buf.code_action
            {:desc "Lsp Code Action" :buffer buf})))

(let [blink (require :blink.cmp)
      capabilities (blink.get_lsp_capabilities (vim.lsp.protocol.make_client_capabilities))]
  (vim.lsp.config "*" {: capabilities :on_attach attach-base}))

(vim.lsp.config :luals {:root_markers [:.git :.stylua.toml]})
(vim.lsp.config :fennel-ls {})
(vim.lsp.config :nixd {})
(vim.lsp.config :ts_ls
                {:on_attach (fn [_ buf]
                              (attach-base _ buf)
                              (let [km (require :lib.keymap)]
                                (km.map :<leader>ci
                                        (fn []
                                          (vim.lsp.buf.code_action {:context {:only [:source.addMissingImports.ts
                                                                                     :source.addMissingImports]}
                                                                    :apply true}))
                                        {:desc "Add Missing Imports"})
                                (km.map :<leader>cr
                                        (fn []
                                          (vim.lsp.buf.code_action {:context {:only [:source.organizeImports]}
                                                                    :apply true}))
                                        {:desc "Organize Imports"})))})

(vim.lsp.enable [:luals :fennel-ls :nixd :ts_ls])

;; Default inlay hints
(vim.lsp.inlay_hint.enable true)
