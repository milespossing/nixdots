(local wk (require :which-key))

(local tbl {})

(local tel-b (require :telescope.builtin))
(local toggle (require :snacks.toggle))
(local conform (require :conform))

(fn tbl.merge [l r]
  (vim.tbl_deep_extend :keep l r))

(fn format-file []
  (conform.format {:async true}))

(local bindings
       {:<leader>b {:group :Buffer
                    :maps {:b [tel-b.buffers {:desc "Find Buffer"}]}
                    "," [":cmd buffer #<cr>" {:desc "Previous buffer"}]}
        :<leader>f {:group :File
                    :maps {:f [tel-b.find_files {:desc "Find File"}]
                           :m [format-file {:desc "Format file"}]}}
        :<leader>s {:group :Search
                    :maps {:s [tel-b.live_grep {:desc "Live Grep"}]}}
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
                    :maps {:h [:<C-w>h {:desc "Move window left"}]
                           :l [:<C-w>l {:desc "Move window right"}]
                           :k [:<C-w>k {:desc "Move window up"}]
                           :j [:<C-w>j {:desc "Move window down"}]}}})

;; TODO: Need to finish up the keymaps

(fn add-group [prefix name]
  (wk.add {1 prefix :group name}))

(fn add-cmd [prefix cmd ?opts]
  (wk.add (tbl.merge {1 prefix 2 cmd} ?opts)))

(fn process-group [prefix group]
  (case group
    {:group ?name : maps} (do
                            (when ?name (add-group prefix ?name))
                            (each [p m (pairs maps)]
                              (process-group (.. prefix p) m)))
    [cmd ?opts] (add-cmd prefix cmd ?opts)
    {: toggle} (toggle:map prefix)))

(each [p m (pairs bindings)]
  (process-group p m))

(vim.api.nvim_create_autocmd :LspAttach
                             {:callback (lambda [ev]
                                          (add-cmd :gd vim.lsp.buf.definition
                                                   {:desc "Find Definition"
                                                    :buffer ev.buf})
                                          (add-cmd :grr vim.lsp.buf.references
                                                   {:desc "Find References"
                                                    :buffer ev.buf}))})

; (add-cmd :gd (lambda [] (vim.lsp.buf.definition)) "Find Definition" (lambda [] (vim.lsp.buf_is_attached)))
; (add-cmd :grr (lambda [] (vim.lsp.buf.references)) "Find References" (lambda [] (vim.lsp.buf_is_attached)))
