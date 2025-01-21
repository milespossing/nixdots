(local wk (require :which-key))

(local tel-b (require :telescope.builtin))
(local toggle (require :snacks.toggle))
(local conform (require :conform))

(fn format-file []
  (conform.format {:async true}))

(local bindings
       {:<leader>b {:group :Buffer
                    :maps {:b {:cmd tel-b.buffers :desc "Find Buffer"}}
                    "," {:cmd ":cmd buffer #<cr>" :desc "Previous buffer"}}
        :<leader>f {:group :File
                    :maps {:f {:cmd tel-b.find_files :desc "Find File"}
                           :m {:cmd format-file :desc "Format file"}}}
        :<leader>s {:group :Search
                    :maps {:s {:cmd tel-b.live_grep :desc "Live Grep"}}}
        :<leader>t {:group :Toggle
                    :maps {:z {:toggle (toggle.zen)}
                           :d {:toggle (toggle.dim)}
                           :a {:toggle (toggle.animate)}
                           :i {:toggle (toggle.indent)}
                           :n {:group :numbers
                               :maps {:n {:toggle (toggle.line_number)}
                                      :a {:toggle (toggle.option :number
                                                                 {:name "Absolute Number"})}
                                      :r {:toggle (toggle.option :relativenumber
                                                                 {:name "Relative Number"})}}}
                           :t {:toggle (toggle.treesitter)}}}
        :<leader>w {:group :Window
                    :maps {:h {:cmd :<C-w>h :desc "Move window left"}
                           :l {:cmd :<C-w>l :desc "Move window right"}
                           :k {:cmd :<C-w>k :desc "Move window up"}
                           :j {:cmd :<C-w>j :desc "Move window down"}}}})

;; TODO: Need to finish up the keymaps

(fn add-group [prefix name]
  (wk.add {1 prefix :group name}))

(fn add-cmd [prefix cmd desc]
  (wk.add {1 prefix 2 cmd : desc}))

(fn process-group [prefix group]
  (case group
    {:group name : maps} (do
                           (add-group prefix name)
                           (each [p m (pairs maps)]
                             (process-group (.. prefix p) m)))
    {: cmd : desc} (add-cmd prefix cmd desc)
    {: toggle} (toggle:map prefix)))

(each [p m (pairs bindings)]
  (process-group p m))
