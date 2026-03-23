;; Helper: build a which-key group spec entry.
;; Defaults mode to [:n :v]. Pass an opts table to merge extra keys
;; like :icon or :expand.
(fn group [lhs name opts]
  (let [t {1 lhs :group name :mode [:n :v]}]
    (when opts
      (each [k v (pairs opts)]
        (tset t k v)))
    t))

(fn after []
  (let [wk (require :which-key)]
    (wk.setup
      {:preset :helix
       :spec [(group :<leader>c :code)
              (group "[" :prev)
              (group "]" :next)
              (group :<leader>a :ai)
              (group :<leader>d :debug)
              (group :<leader>s :search)
              (group :<leader>f "file/find")
              (group :<leader>g :git)
              (group :<leader>gh :hunks)
              (group :<leader>h :help {:icon " "})
              (group :<leader>o :toggle)
              (group :<leader>u :ui)
              (group :<leader>x :diagnostics)
              (group :<leader>w :window
                     {:expand (fn []
                                ((. (require :which-key.extras) :expand :win)))})
              (group :<leader>b :buffer
                     {:expand (fn []
                                ((. (require :which-key.extras) :expand :buf)))})
              {1 :<c-w><space>
               2 (fn []
                   ((. (require :which-key) :show) {:keys :<c-w> :loop true}))
               :desc "Window (hydra)"
               :mode [:n :v]}]})))

{:name :which-key.nvim
 :after after}
