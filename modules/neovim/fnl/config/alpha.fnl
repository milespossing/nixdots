;; Dashboard (alpha-nvim)
;; Catppuccin-macchiato–friendly startup screen with quick actions.

(local leader :SPC)

(fn text [text ?opts]
  (let [opts (or ?opts {})]
    {:type :text :val text : opts}))

(fn padding [?val]
  (let [val (or ?val 0)]
    {:type :padding : val}))

(fn button [val on-press ?opts]
  {:type :button : val :on_press on-press :opts (or ?opts {})})

(fn menu-button [shortcut txt ?on-press]
  (let [on-press (or ?on-press
                     (let [key (vim.api.nvim_replace_termcodes (.. (-> shortcut
                                                                       (: :gsub
                                                                          "%s"
                                                                          "")
                                                                       (: :gsub
                                                                          leader
                                                                          :<leader>))
                                                                   :<Ignore>)
                                                               true false true)]
                       #(vim.api.nvim_feedkeys key :t false)))]
    (button txt on-press {:position :center
                          : shortcut
                          :cursor 3
                          :width 50
                          :align_shortcut :right
                          :hl_shortcut :Keyword})))

(fn group [val ?opts]
  {:type :group : val :opts (or ?opts {})})

(fn config [layout ?opts]
  {: layout :opts (or ?opts {})})

(let [alpha (require :alpha)
      fzf-lua (require :lib.fzf-lua)]
  (local header (text ["⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
                       "⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣶⠾⠿⠛⠛⠛⠛⠛⠛⠿⠷⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀"
                       "⠀⠀⠀⠀⠀⣠⣴⡿⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣶⣄⠀⠀⠀⠀⠀"
                       "⠀⠀⠀⣠⣾⠟⠉⠀⠀⠀⠀⢿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣄⠀⠀⠀"
                       "⠀⠀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣦⠀⠀"
                       "⠀⣼⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣧⠀"
                       "⢰⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡇"
                       "⣾⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿"
                       "⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⡟⠘⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿"
                       "⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⠟⠀⠀⠘⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿"
                       "⢸⣿⡀⠀⠀⠀⠀⠀⢀⣾⣿⣿⠏⠀⠀⠀⠀⠹⣿⣿⣿⣷⣀⣀⣀⣀⡀⠀⠀⠀⣿⡟"
                       "⠀⢿⣷⡀⠀⠀⠀⢀⣾⣿⣿⠏⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⣼⡿⠁"
                       "⠀⠈⢻⣷⡄⠀⠀⠚⠛⠛⠋⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠛⠛⠛⠛⠀⢀⣼⡿⠁⠀"
                       "⠀⠀⠀⠹⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⠟⠁⠀⠀"
                       "⠀⠀⠀⠀⠈⠛⢿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣿⠟⠁⠀⠀⠀⠀"
                       "⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⣿⣶⣦⣤⣤⣤⣠⣤⣤⣤⣶⣾⠿⠟⠉⠀⠀⠀⠀⠀⠀⠀"
                       "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠛⠛⠛⠛⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"]
                      {:position :center :hl :Type}))
  (local buttons
         (group [(menu-button (string.format "%s f f" leader) :files)
                 (menu-button (string.format "%s f r" leader) :old_files)
                 (menu-button (string.format "%s /" leader) :live_grep)
                 (menu-button (string.format "%s ," leader) :buffers)]))
  (alpha.setup (config [(padding 2) header (padding 3) buttons] {:margin 5})))
