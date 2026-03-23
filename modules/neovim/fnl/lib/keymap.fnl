(local M {})

(fn M.map [mode lval rval ?opts]
  (vim.keymap.set mode lval rval opts))

M
