(local helpers (require :plugins.helpers))

[{1 :nvim-treesitter/nvim-treesitter
  :lazy false
  :run ":TSUpdate"
  :config (lambda []
            (helpers.setup :nvim-treesitter.configs
                           {:ensure_installed [:lua
                                               :tsx
                                               :typescript
                                               :java
                                               :c_sharp
                                               :scala
                                               :clojure
                                               :fennel]
                            :ignore_install [:org]
                            :highlight {:enable true}
                            :incremental_selection {:enable true
                                                    :keymaps {:init_selection :gnn
                                                              :node_incremental :grn
                                                              :scope_incremental :grc
                                                              :node_decremental :grm}}
                            :textobjects {:select {:enable true
                                                   :lookahead true
                                                   :keymaps {:af "@function.outer"
                                                             :if "@function.inner"
                                                             :ac "@class.couter"
                                                             :ic "@class.inner"}}}}))}
 {1 :PaterJason/nvim-treesitter-sexp :ft [:clojure :fennel]}]
