(local M {})

(fn M.map [lhs rhs ?opts]
  (let [opts (or ?opts {})
        mode (or (. opts :mode) :n)]
    (set opts.mode nil)
    (vim.keymap.set mode lhs rhs opts)))

(fn M.group [lhs name ?opts]
  (let [opts (or ?opts {})
        wk (require :which-key)]
    (tset opts 1 lhs)
    (set opts.group name)
    (wk.add [opts])))

M
