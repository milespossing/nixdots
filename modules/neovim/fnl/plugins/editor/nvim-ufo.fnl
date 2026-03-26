(fn after []
  (let [ufo (require :ufo)]
    (ufo.setup {:provider_selector (fn [] [:treesitter :indent])})))

(let [opts {:provider_selector (fn [] [:treesitter :indent])}]
  {:name :nvim-ufo :event :DeferredUIEnter : after})
