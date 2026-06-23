;; Git integration — gitsigns
;; Provides git gutters, hunk navigation, staging, blame, and diff preview.

(fn on-attach [bufnr]
  (let [gs (require :gitsigns)
        km (require :lib.keymap)]
    ;; Navigation
    (km.map "]h" #(gs.nav_hunk :next) {:buffer bufnr :desc "Next hunk"})
    (km.map "[h" #(gs.nav_hunk :prev) {:buffer bufnr :desc "Previous hunk"})

    ;; Actions
    (km.map :<leader>ghs #(gs.stage_hunk) {:buffer bufnr :desc "Stage hunk"})
    (km.map :<leader>ghr #(gs.reset_hunk) {:buffer bufnr :desc "Reset hunk"})
    (km.map :<leader>ghs
            #(gs.stage_hunk [(vim.fn.line ".") (vim.fn.line "v")])
            {:buffer bufnr :mode :v :desc "Stage hunk (visual)"})
    (km.map :<leader>ghr
            #(gs.reset_hunk [(vim.fn.line ".") (vim.fn.line "v")])
            {:buffer bufnr :mode :v :desc "Reset hunk (visual)"})
    (km.map :<leader>ghS #(gs.stage_buffer) {:buffer bufnr :desc "Stage buffer"})
    (km.map :<leader>ghu #(gs.undo_stage_hunk) {:buffer bufnr :desc "Undo stage hunk"})
    (km.map :<leader>ghR #(gs.reset_buffer) {:buffer bufnr :desc "Reset buffer"})
    (km.map :<leader>ghp #(gs.preview_hunk) {:buffer bufnr :desc "Preview hunk"})
    (km.map :<leader>ghb #(gs.blame_line {:full true}) {:buffer bufnr :desc "Blame line"})
    (km.map :<leader>ghd #(gs.diffthis) {:buffer bufnr :desc "Diff this"})
    (km.map :<leader>ob #(gs.toggle_current_line_blame) {:buffer bufnr :desc "Toggle line blame"})))

(fn after []
  (let [gs (require :gitsigns)]
    (gs.setup {:on_attach on-attach})))

{:name :gitsigns.nvim
 :event :DeferredUIEnter
 :after after}
