(local M {})

(fn M.map [lhs rhs ?opts]
  (let [opts (or ?opts {})
        mode (or (. opts :mode) :n)]
    (set opts.mode nil)
    (vim.keymap.set mode lhs rhs opts)))

(fn M.hydra [lhs keys]
  (M.map lhs #((let [wk (require :which-key)]
                 (wk.show {: keys :loop true})))))

(fn M.group [lhs name ?opts]
  (let [opts (or ?opts {})
        wk (require :which-key)]
    (tset opts 1 lhs)
    (set opts.group name)
    (wk.add [opts])))

M
