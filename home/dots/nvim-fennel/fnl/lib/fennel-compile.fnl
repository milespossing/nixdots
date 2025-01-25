(local M {})

(fn M.compile-dots []
  (local tangerine (require :tangerine))
  (vim.cmd ":Fnl (tangerine.api.compile.dir \"~/.nixdots/home/dots/nvim-fennel/fnl\" \"~/.local/share/nvim/tangerine\")")
  nil)

M
