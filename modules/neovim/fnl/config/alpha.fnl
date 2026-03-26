;; Dashboard (alpha-nvim)
;; Catppuccin-macchiato–friendly startup screen with quick actions.

(let [alpha (require :alpha)
      dashboard (require :alpha.themes.dashboard)]

  ;; ── Header ──────────────────────────────────────────────
  (set dashboard.section.header.val
       ["                                   "
        "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          "
        "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       "
        "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     "
        "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    "
        "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   "
        "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠂  ⠤⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣧⣤ "
        "   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿  ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧ "
        "   ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡐⠿⣿⣿⣿⣿⣿⠟⠉   ⢀⣿⣿⣿⣿⣿⣿⣿⡿⠃ "
        "   ⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣤⠉⡉⠉⠁   ⢀⡀⣿⣿⣿⣿⣿⡿⠟⣡⣶⣿ "
        "    ⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿ "
        "      ⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⣼⣿⣿⣿⣿⣿ "
        "        ⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁ ⣼⣿⣿⣿⣿⣿⣿ "
        "          ⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⣉⡀   ⣿⣿⣿⣿⣿⣿⣿⣿ "
        "  ⠄⠄⠄⠄⠄⠄⠄⠄ ⠈⠙⢿⣿⣿⣿⣿⣿⣿⡿⠟⢁⣴⣿⣿⣿   ⣿⣿⣿⣿⣿⣿⣿⣿ "
        "            ⠈⠛⠛⠛⠛⠛⣿⣿⣿⣿⣿⡀  ⢹⣿⣿⣿⣿⣿⣿⣿ "
        "                                   "])

  (set dashboard.section.header.opts.hl :AlphaHeader)

  ;; ── Buttons ─────────────────────────────────────────────
  ;; Matches actual keymaps from config/keymaps.fnl & which-key groups
  (set dashboard.section.buttons.val
       [(dashboard.button "f" "  Find file"        :<leader>ff)
        (dashboard.button "r" "  Recent files"     :<leader>fr)
        (dashboard.button "/" "  Grep text"        "<leader>/")
        (dashboard.button "b" "  Buffers"          "<leader>,")
        (dashboard.button "n" "  New file"         :<cmd>ene<cr>)
        (dashboard.button "q" "  Quit"             :<cmd>qa<cr>)])

  ;; ── Footer ──────────────────────────────────────────────
  ;; Show loaded plugin count + Neovim version
  (let [version (vim.version)
        ver-str (string.format "v%d.%d.%d" version.major version.minor version.patch)
        plugins-dir (vim.fn.stdpath :data)
        pack-dir (.. plugins-dir "/site/pack")
        start-count (length (vim.fn.glob (.. pack-dir "/*/start/*") false true))
        opt-count (length (vim.fn.glob (.. pack-dir "/*/opt/*") false true))
        footer (string.format "⚡ %d plugins (%d lazy)  │  Neovim %s" (+ start-count opt-count) opt-count ver-str)]
    (set dashboard.section.footer.val [footer]))

  (set dashboard.section.footer.opts.hl :AlphaFooter)

  ;; ── Highlights ──────────────────────────────────────────
  ;; Tie into catppuccin palette groups for a cohesive look.
  (vim.api.nvim_set_hl 0 :AlphaHeader  {:link :Keyword})
  (vim.api.nvim_set_hl 0 :AlphaFooter  {:link :Comment})
  ;; Style the shortcut keys in buttons
  (vim.api.nvim_set_hl 0 :AlphaShortcut {:link :Type})

  ;; ── Layout ──────────────────────────────────────────────
  (set dashboard.config.layout
       [{:type :padding :val 4}
        dashboard.section.header
        {:type :padding :val 2}
        dashboard.section.buttons
        {:type :padding :val 2}
        dashboard.section.footer])

  (alpha.setup dashboard.config))
