;; Treesitter configuration
;; Incremental selection via treesitter node hierarchy + highlighting/indent

(local au (require :lib.auto-cmd))
(local keymap (require :lib.keymap))

;; -- Incremental selection state --

(var node-stack [])

(fn select-node [node]
  (let [(sr sc er ec) (node:range)]
    (vim.fn.setpos "'<" [0 (+ sr 1) (+ sc 1) 0])
    (vim.fn.setpos "'>" [0 (+ er 1) ec 0])
    (vim.cmd "normal! gv")))

(fn init-selection []
  (let [node (vim.treesitter.get_node)]
    (when node
      (set node-stack [node])
      (select-node node))))

(fn node-incremental []
  (if (= (length node-stack) 0)
      (init-selection)
      (let [current (. node-stack (length node-stack))
            parent (current:parent)]
        (when parent
          (table.insert node-stack parent)
          (select-node parent)))))

(fn node-decremental []
  (when (> (length node-stack) 1)
    (table.remove node-stack)
    (select-node (. node-stack (length node-stack)))))

;; Reset stack when leaving visual mode
(au.on! [:ModeChanged] {:pattern "[vV\x16]*:*"
                         :callback #(when (not (: (vim.fn.mode) :match "[vV\x16]"))
                                      (set node-stack []))})

(fn after []
  (let [ts (require :nvim-treesitter)]
    (ts.setup {}))

  ;; Enable treesitter highlighting and indentation for supported filetypes
  (au.on! [:FileType]
          {:callback (fn [args]
                       (when (pcall vim.treesitter.start args.buf)
                         (set (. vim.bo args.buf :indentexpr)
                              "v:lua.require'nvim-treesitter'.indentexpr()")))}))

(fn before []
  ;; Incremental selection keymaps
  (keymap.map :n :<C-space> init-selection {:desc "Incremental selection"})
  (keymap.map :x :<C-space> node-incremental {:desc "Expand selection"})
  (keymap.map :x :<bs> node-decremental {:desc "Shrink selection"}))

{:name :nvim-treesitter
 :event :DeferredUIEnter
 :after after
 :before before}
