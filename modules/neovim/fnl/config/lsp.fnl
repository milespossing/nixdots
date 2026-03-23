;; LSP configuration

(let [blink (require :blink.cmp)
      capabilities (blink.get_lsp_capabilities
                     (vim.lsp.protocol.make_client_capabilities))]
  (vim.lsp.config :* {:capabilities capabilities}))

(vim.lsp.config :luals {:root_markers [:.git :.stylua.toml]})
(vim.lsp.config :fennel-ls {})
(vim.lsp.config :nixd {})

(vim.lsp.enable [:luals :fennel-ls :nixd])

;; Default inlay hints
(vim.lsp.inlay_hint.enable true)

