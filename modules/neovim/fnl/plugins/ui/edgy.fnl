
(local help {:ft :help
             :size {:height 20}
             :filter (fn [buf]
                       (= (. (. vim.bo buf) :buftype) :help))})

(local bottom [help])

(local opts {:bottom bottom})

(fn after []
  (let [edgy (require "edgy")]
    (edgy.setup opts)))

{:name :edgy.nvim
 :after after}
