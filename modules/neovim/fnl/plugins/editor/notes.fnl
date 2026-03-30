(fn after []
  (let [org (require :orgmode)
        km (require :lib.keymap)]
    (km.group :<leader>n :notes)
    (org.setup {:org_agenda_files "~/notes/**/*"
                :org_default_notes_file "~/notes/refile.org"
                :mappings {:disable_all true
                           ;; Global
                           :global {:org_agenda :<leader>na
                                    :org_capture :<leader>nc}
                           ;; Org file buffer-local
                           :org {:org_todo :<localleader>t
                                 :org_todo_prev :<localleader>T
                                 :org_toggle_checkbox :<localleader>x
                                 :org_toggle_heading :<localleader>*
                                 :org_meta_return :<localleader><CR>
                                 :org_insert_heading_respect_content :<localleader>ih
                                 :org_insert_todo_heading_respect_content :<localleader>it
                                 :org_insert_todo_heading :<localleader>iT
                                 :org_move_subtree_up :<localleader>K
                                 :org_move_subtree_down :<localleader>J
                                 ;; Dates
                                 :org_schedule :<localleader>ds
                                 :org_deadline :<localleader>dd
                                 :org_time_stamp :<localleader>dt
                                 :org_time_stamp_inactive :<localleader>di
                                 :org_toggle_timestamp_type :<localleader>d!
                                 :org_change_date :<localleader>dc
                                 ;; Metadata
                                 :org_priority :<localleader>p
                                 :org_set_tags_command :<localleader>q
                                 :org_add_note :<localleader>na
                                 :org_refile :<localleader>r
                                 :org_toggle_archive_tag :<localleader>A
                                 :org_archive_subtree :<localleader>a
                                 :org_export :<localleader>e
                                 ;; Links
                                 :org_open_at_point :<localleader>lo
                                 :org_insert_link :<localleader>li
                                 :org_store_link :<localleader>ls
                                 ;; Clock
                                 :org_clock_in :<localleader>ci
                                 :org_clock_out :<localleader>co
                                 :org_clock_cancel :<localleader>cq
                                 :org_clock_goto :<localleader>cj
                                 :org_set_effort :<localleader>ce
                                 ;; Source blocks
                                 :org_edit_special "<localleader>'"
                                 :org_babel_tangle :<localleader>bt
                                 ;; Navigation (keep vim-like defaults)
                                 :org_next_visible_heading "}"
                                 :org_previous_visible_heading "{"
                                 :org_forward_heading_same_level "]]"
                                 :org_backward_heading_same_level "[["
                                 :org_outline_up_heading "g{}"
                                 :org_cycle :<TAB>
                                 :org_global_cycle :<S-TAB>
                                 ;; Promote/demote (keep defaults)
                                 :org_do_promote "<<"
                                 :org_do_demote ">>"
                                 :org_promote_subtree :<s
                                 :org_demote_subtree :>s
                                 :org_return :<CR>}
                           ;; Text objects
                           :text_objects {:inner_heading :ih
                                          :around_heading :ah
                                          :inner_subtree :ir
                                          :around_subtree :ar}}}))
  (vim.lsp.enable :org))

{:name :orgmode :ft :org : after}
