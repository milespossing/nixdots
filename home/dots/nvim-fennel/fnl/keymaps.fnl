(local wk (require :which-key))

(local tbl {})

(local fzf (require :fzf-lua))
(local ivy-toggle (. (require :lib.my-fzf) :toggle))
(local toggle (require :snacks.toggle))
(local conform (require :conform))

(fn tbl.merge [l r]
  (vim.tbl_deep_extend :keep l r))

(fn format-file []
  (conform.format {:async true}))

(fn add-group [prefix name]
  (wk.add {1 prefix :group name}))

(fn add-cmd [prefix cmd ?opts]
  (wk.add (tbl.merge {1 prefix 2 cmd} ?opts)))

(fn add-bindings [prefix group]
  (case group
    {:group ?name : maps} (do
                            (when ?name (add-group prefix ?name))
                            (each [p m (pairs maps)]
                              (add-bindings (.. prefix p) m)))
    [cmd ?opts] (add-cmd prefix cmd ?opts)
    {: toggle} (toggle:map prefix)))

(fn add-keys [bindings]
  (each [p m (pairs bindings)]
    (add-bindings p m)))

;; Normal Bindings
(add-keys {:<leader>b {:group :Buffer
                       :maps {:b [fzf.buffers {:desc "Find Buffer"}]
                              :g [fzf.grep_curbuf {:desc "Grep within buffer"}]
                              :f [fzf.file_types {:desc "Set filetype"}]}
                       "," [":cmd buffer #<cr>" {:desc "Previous buffer"}]}
           :<leader>f {:group :File
                       :maps {:f [fzf.files {:desc "Find File"}]
                              :m [format-file {:desc "Format file"}]}}
           :<leader>s {:group :Search
                       :maps {:s [fzf.builtin {:desc "Meta Search"}]
                              :g [fzf.grep {:desc :Grep}]
                              :G [fzf.live_grep {:desc "Live Grep"}]
                              :w [fzf.grep_cword {:desc "Grep word"}]
                              :W [fzf.grep_cWORD {:desc "Grep WORD"}]
                              :l [fzf.blines
                                  {:desc "Search Lines (Current Buffer)"}]
                              :L [fzf.lines
                                  {:desc "Search Lines (Open Buffers)"}]
                              :r [fzf.resume {:desc "Resume previous search"}]}}
           :<leader>h {:group :Help
                       :maps {:c [fzf.commands {:desc "Find Command"}]
                              :t [fzf.helptags {:desc :Helptags}]
                              :r [fzf.registers {:desc :Registers}]
                              :m [fzf.marks {:desc :Marks}]}}
           :<leader>t {:group :Toggle
                       :maps {:z {:toggle (toggle.zen)}
                              :d {:toggle (toggle.dim)}
                              :a {:toggle (toggle.animate)}
                              :i {:toggle (toggle.indent)}
                              :I {:toggle (ivy-toggle)}
                              :n {:group :numbers
                                  :maps {:n {:toggle (toggle.line_number)}
                                         :a {:toggle (toggle.option :number
                                                                    {:name "Absolute Number"})}
                                         :r {:toggle (toggle.option :relativenumber
                                                                    {:name "Relative Number"})}}}
                              :t {:toggle (toggle.treesitter)}}}
           :<leader>w {:group :Window
                       :maps {:h [:<C-w>h {:desc "Move window left"}]
                              :l [:<C-w>l {:desc "Move window right"}]
                              :k [:<C-w>k {:desc "Move window up"}]
                              :j [:<C-w>j {:desc "Move window down"}]}}})

;; Visual
(add-keys {:<leader>s {:group :Search
                       :maps {:g [fzf.grep_visual
                                  {:desc "Grep Visual" :mode :v}]}}})

;; TODO: Need to finish up the keymaps

(vim.api.nvim_create_autocmd :LspAttach
                             {:callback (lambda [ev]
                                          (add-cmd :gd vim.lsp.buf.definition
                                                   {:desc "Find Definition"
                                                    :buffer ev.buf})
                                          (add-cmd :<leader>sd
                                                   fzf.lsp_definitions
                                                   {:desc "Find Definitions"
                                                    :buffer ev.buf})
                                          (add-cmd :<leader>sr
                                                   fzf.lsp_references
                                                   {:desc "Find References"
                                                    :buffer ev.buf})
                                          (add-cmd :grr vim.lsp.buf.references
                                                   {:desc "Find References"
                                                    :buffer ev.buf})
                                          (add-cmd :gri fzf.lsp_incoming_calls
                                                   {:desc "Incoming Calls"
                                                    :buffer ev.buf}))})
