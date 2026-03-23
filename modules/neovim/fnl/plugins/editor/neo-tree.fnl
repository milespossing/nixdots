(local opts
  {:window {:mappings {"<C-t>" {1 (fn [state]
                                     (let [node (state.tree:get_node)
                                           path (if (= node.type :directory)
                                                    node.path
                                                    node._parent_id)
                                           cmd (.. "TermNew dir=" path " name=" path)]
                                       (vim.cmd cmd)))
                                :desc "Open in terminal"}}}
   :sources [:filesystem
             :buffers
             :git_status
             :document_symbols]})

(fn after [] (let [neo-tree (require :neo-tree)
                   keymap (require :lib.keymap)]
              (neo-tree.setup opts)
              (keymap.map :n :<leader>ee "<cmd>Neotree toggle<cr>" { :desc "File Explorer"})))
         
{:name :neo-tree.nvim :after after}
