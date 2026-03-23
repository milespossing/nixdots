(let [alpha (require :alpha)]
  (local startify (require :alpha.themes.startify))
  (set startify.file_icons.provider "devicons")
  (alpha.setup startify.config))
