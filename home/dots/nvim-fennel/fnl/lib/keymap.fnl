(local std (require :lib.std))
(local wk (require :which-key))
(local M {})

(fn M.add-group [prefix name]
  (wk.add {1 prefix :group name}))

(fn M.add-cmd [prefix cmd ?opts]
  (wk.add (std.tbl.merge-left {1 prefix 2 cmd} ?opts)))

(fn add-bindings [prefix group]
  (case group
    {:group ?name : maps} (do
                            (when ?name (M.add-group prefix ?name))
                            (each [p m (pairs maps)]
                              (add-bindings (.. prefix p) m)))
    [cmd ?opts] (M.add-cmd prefix cmd ?opts)
    {: toggle} (toggle:map prefix)))

(fn M.add-keys [bindings]
  (each [p m (pairs bindings)]
    (add-bindings p m)))

M
