
(fn after [] 
  (let [lualine (require :lualine)]
    (lualine.setup
     {:options {:theme :auto
                :icons_enabled true
                :component_separators {:left "" :right ""}
                :section_separators {:left "" :right ""}}
      :sections {:lualine_a [:mode]
                 :lualine_b [:branch :diff :diagnostics]
                 :lualine_c [:filename]
                 :lualine_x (let [noice (require :noice)]
                               [{1 noice.api.status.message.get_hl
                                 :cond noice.api.status.message.has}
                                {1 noice.api.status.command.get
                                 :cond noice.api.status.command.has}
                                {1 noice.api.status.mode.get
                                 :cond noice.api.status.mode.has}
                                {1 noice.api.status.search.get
                                 :cond noice.api.status.search.has}
                                {1 noice.api.status.ruler.get_hl
                                 :cond noice.api.status.ruler.has}])
                 :lualine_y [:progress]
                 :lualine_z [:location]}})))

{:name :lualine.nvim
 :event :DeferredUIEnter
 :after after}
