(local helpers (require :plugins.helpers))

{1 :julienvincent/nvim-paredit
 :event :VeryLazy
 :config (lambda []
           (helpers.setup :nvim-paredit))}
