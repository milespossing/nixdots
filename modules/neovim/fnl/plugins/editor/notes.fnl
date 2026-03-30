(fn after []
  (let [org (require :orgmode)]
    (org.setup {:org_agenda_files "~/notes/**/*"
                :org_default_notes_file "~/notes/refile.org"}))
  (vim.lsp.enable :org))

{:name :orgmode :ft :org : after}
