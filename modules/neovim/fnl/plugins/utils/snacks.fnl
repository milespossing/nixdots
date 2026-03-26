(local opts {:input {} :notify {} :notifier {} :bufdelete {}})

(fn after []
  (let [snacks (require :snacks)]
    (snacks.setup opts)))

{:name :snacks.nvim : after :lazy false}
