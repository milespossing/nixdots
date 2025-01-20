(local helpers (require :plugins.helpers))

{ 1 :echasnovski/mini.nvim
:version false
:lazy false
:config (lambda []
          (helpers.setup :mini.animate)
          (helpers.setup :mini.comment)
          (helpers.setup :mini.diff)
          (helpers.setup :mini.indentscope)
          (helpers.setup :mini.surround))}
