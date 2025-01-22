
(local M {})

(local fzf (require :fzf-lua))

(fn M.files [?path]
  (if ?path
      (fzf.files { :cwd ?path })
      (fzf.files)))

(fn M.buffers []
  (fzf.buffers))

(fn M.grep []
  (fzf.grep))

(fn M.buil)

M
