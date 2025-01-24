(local km (require :lib.keymap))

(local toggle (require :snacks.toggle))
(local conform (require :conform))
(local zellij (require :lib.zellij))

;; Normal Bindings
(km.add-keys {:<leader>b {:group :Buffer
                          :maps {"," [":cmd buffer #<cr>"
                                      {:desc "Previous buffer"}]}}
              :<leader>f {:group :File
                          :maps {:m [(lambda [] (conform.format {:async true}))
                                     {:desc "Format file"}]}}
              :<leader>t {:group :Toggle
                          :maps {:z {:toggle (toggle.zen)}
                                 :d {:toggle (toggle.dim)}
                                 :a {:toggle (toggle.animate)}
                                 :i {:toggle (toggle.indent)}
                                 :n {:group :numbers
                                     :maps {:n {:toggle (toggle.line_number)}
                                            :a {:toggle (toggle.option :number
                                                                       {:name "Absolute Number"})}
                                            :r {:toggle (toggle.option :relativenumber
                                                                       {:name "Relative Number"})}}}
                                 :t {:toggle (toggle.treesitter)}}}
              :<leader>w {:group :Window
                          :maps {:h [zellij.left {:desc "Move window left"}]
                                 :l [zellij.right {:desc "Move window right"}]
                                 :k [zellij.up {:desc "Move window up"}]
                                 :j [zellij.down {:desc "Move window down"}]}}
              :<leader>g {:group :Git
                          :maps {:g [(lambda []
                                       (zellij.run-float-temp :lazygit))
                                     {:desc :lazygit}]}}})

;; TODO: Need to finish up the keymaps

(vim.api.nvim_create_autocmd :LspAttach
                             {:callback (lambda [ev]
                                          (km.add-cmd :gd
                                                      vim.lsp.buf.definition
                                                      {:desc "Find Definition"
                                                       :buffer ev.buf})
                                          (km.add-cmd :grr
                                                      vim.lsp.buf.references
                                                      {:desc "Find References"
                                                       :buffer ev.buf}))})
