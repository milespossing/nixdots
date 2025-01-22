(local helpers (require :plugins.helpers))

{1 :echasnovski/mini.nvim
 :version false
 :lazy false
 :config (lambda []
           (helpers.setup :mini.comment)
           (helpers.setup :mini.diff)
           (helpers.setup :mini.indentscope)
           (helpers.setup :mini.surround)
           (helpers.setup :mini.pairs)
           (helpers.setup :mini.ai))}
