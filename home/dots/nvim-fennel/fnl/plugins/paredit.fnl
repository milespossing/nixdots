(local helpers (require :plugins.helpers))

{1 :julienvincent/nvim-paredit
 :config (lambda []
           (helpers.setup :nvim-paredit))}
