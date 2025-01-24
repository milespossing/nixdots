
(lambda []
(local toggle (require :snacks.toggle))
(local fzf (require :fzf-lua))

(local opts {})
(var is-ivy false)

(fn toggle-ivy []
  (toggle.new {:id :fzf-ivy
               :name "Fzf Ivy"
               :get (lambda [] is-ivy)
               :set (lambda [s]
                      (set is-ivy s)
                      (if s
                          (fzf.setup [:ivy])
                          (fzf.setup [:default])))}))
  (local km (require :lib.keymap))
  (km.add-keys {:<leader>b {:group :Buffer
                            :maps {:b [(lambda [] (fzf.buffers))
                                       {:desc "Find Buffer"}]
                                   :g [(lambda [] (fzf.grep_curbuf))
                                       {:desc "Grep within buffer"}]
                                   :f [(lambda [] (fzf.filetypes))
                                       {:desc "Set filetype"}]}}
                :<leader>f {:group :File
                            :maps {:f [(lambda [] (fzf.files))
                                       {:desc "Find File"}]}}
                :<leader>s {:group :Search
                            :maps {:s [(lambda [] (fzf.builtin))
                                       {:desc "Meta Search"}]
                                   :g [(lambda [] (fzf.grep)) {:desc :Grep}]
                                   :G [(lambda [] (fzf.live_grep))
                                       {:desc "Live Grep"}]
                                   :w [(lambda [] (fzf.grep_cword))
                                       {:desc "Grep word"}]
                                   :W [(lambda [] (fzf.grep_cWORD))
                                       {:desc "Grep WORD"}]
                                   :l [(lambda [] (fzf.blines))
                                       {:desc "Search Lines (Current Buffer)"}]
                                   :L [(lambda [] (fzf.lines))
                                       {:desc "Search Lines (Open Buffers)"}]
                                   :r [(lambda [] (fzf.resume))
                                       {:desc "Resume previous search"}]}}
                :<leader>h {:group :Help
                            :maps {:c [(lambda [] (fzf.commands))
                                       {:desc "Find Command"}]
                                   :t [(lambda [] (fzf.helptags))
                                       {:desc :Helptags}]
                                   :r [(lambda [] (fzf.registers))
                                       {:desc :Registers}]
                                   :m [(lambda [] (fzf.marks)) {:desc :Marks}]}}
                :<leader>tI {:toggle (toggle-ivy)}})
  (vim.api.nvim_create_autocmd :LspAttach
                               {:callback (lambda [ev]
                                            (km.add-cmd :<leader>sd
                                                        (lambda []
                                                          (fzf.lsp_definitions))
                                                        {:desc "Find Definitions"
                                                         :buffer ev.buf})
                                            (km.add-cmd :<leader>sr
                                                        (lambda []
                                                          (fzf.lsp_references))
                                                        {:desc "Find References"
                                                         :buffer ev.buf})
                                            (km.add-cmd :gri
                                                        (lambda []
                                                          (fzf.lsp_incoming_calls))
                                                        {:desc "Incoming Calls"
                                                         :buffer ev.buf}))})
  ;; Visual
  (km.add-keys {:<leader>s {:group :Search
                            :maps {:g [(lambda [] (fzf.grep_visual))
                                       {:desc "Grep Visual" :mode :v}]}}}))
