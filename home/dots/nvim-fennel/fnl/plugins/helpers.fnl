(local M {})

(fn M.setup [name ...]
  ((. (require name) :setup) ...))

M
