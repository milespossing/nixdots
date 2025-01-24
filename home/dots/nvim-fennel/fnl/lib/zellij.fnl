(local std (require :lib.std))

(local M {})

(local nvim-directions {:left :h :up :k :right :l :down :j})

(fn zellij-run [flags ...]
  (let [cmd1 (std.str.foldl " " "zellij run" flags)
        cmd2 (std.str.reduce " " [...])
        cmd (std.str.join " -- " cmd1 cmd2)]
    (print cmd)
    (vim.fn.system cmd)))

(fn zellij-action [...]
  (let [cmd (std.str.foldl " " "zellij action" [...])]
    (vim.fn.system cmd)
    nil))

(fn nav [dir]
  (let [cur_winnr (vim.fn.winnr)]
    (vim.api.nvim_command (.. "wincmd " (. nvim-directions dir)))
    (let [new_winnr (vim.fn.winnr)]
      (when (= cur_winnr new_winnr)
        (zellij-action :move-focus-or-tab dir)))))

(fn M.toggle-float-term []
  (zellij-action :toggle-floating-panes))

(fn M.run-float-temp [...]
  (zellij-run [:-f :-c] ...))

(fn M.up []
  (nav :up))

(fn M.down []
  (nav :down))

(fn M.left []
  (nav :left))

(fn M.right []
  (nav :right))

M
