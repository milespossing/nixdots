(local toggle (require :snacks.toggle))
(local fzf (require :fzf-lua))

(local opts {})
(var is-ivy false)

(fn toggle-ivy []
  (toggle.new {:id :fzf-ivy
               :name "Fzf Ivy"
               :get (lambda [] is-ivy)
               :set (lambda [s]
                      (set is-ivy s)
                      (if s
                          (fzf.setup [:ivy])
                          (fzf.setup [:default])))}))

{: opts :toggle toggle-ivy}
