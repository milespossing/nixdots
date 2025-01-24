{:enabled true
 :sections [{:cmd "chafa ~/.config/wall.jpg --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1"
             :height 17
             :padding 1
             :section :terminal}
            {1 {:gap 1 :padding 1 :section :keys}
             2 {:section :startup}
             :pane 2}]
 :preset {:keys [{:icon "󰈞"
                  :key :f
                  :desc "Find File"
                  :action (lambda [] (local fzf (require :fzf-lua))
                            (fzf.files))}
                 {:icon ""
                  :key :n
                  :desc "New File"
                  :action ":ene | startinsert"}
                 {:icon ""
                  :key :o
                  :desc "Org Capture"
                  :action (lambda [] (local orgmode (require :orgmode))
                            (orgmode.capture))}
                 {:icon ""
                  :key :r
                  :desc "Recent Files"
                  :action (lambda [] (local fzf (require :fzf-lua))
                            (fzf.oldfiles))}
                 {:icon ""
                  :key :s
                  :desc "Find Text"
                  :action (lambda [] (local fzf (require :fzf-lua))
                            (fzf.live_grep))}
                 {:icon ""
                  :key :c
                  :desc :Configure
                  :action (lambda []
                            (local fzf (require :fzf-lua))
                            (fzf.files {:cwd "~/.nixdots"}))}
                 {:icon "" :key :q :desc :Close :action ":qa"}]}}
