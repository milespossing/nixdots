(import-macros {: set! : set+ : g!} :hibiscus.vim)

(g! mapleader " ")
(g! maplocalleader "\\")

(when (os.getenv "WSL")
  (local psh-paste "powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace(\"`r\", \"\"))")
  (g! clipboard {:name :WslClipBoard
                                       :copy {"+" "clip.exe"
                                              "*" "clip.exe"}
                                       :paste {"+" psh-paste
                                               "*" psh-paste}}))
(set! clipboard "unnamed,unnamedplus")
(set! confirm false)

(set! expandtab)
(set! shiftwidth 4)
(set! tabstop 4)

(set! foldmethod :expr)
(set! foldexpr "nvim_treesitter#foldexpr()")
(set! foldlevel 99)
(set! foldlevelstart 99)
(set! foldenable true)
