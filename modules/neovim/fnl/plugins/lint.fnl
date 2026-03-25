;; nvim-lint — asynchronous linter integration

(local au (require :lib.auto-cmd))

(fn after []
  (let [lint (require :lint)]
    ;; Configure linters per filetype
    (set lint.linters_by_ft
         {:nix [:statix :deadnix]
          :javascript [:eslint_d]
          :typescript [:eslint_d]
          :javascriptreact [:eslint_d]
          :typescriptreact [:eslint_d]})

    ;; Lint on save, insert leave, and buffer enter
    (au.group! :nvim-lint-autocmds
               [[:BufWritePost :BufReadPost :InsertLeave]
                {:callback #(lint.try_lint)}])))

{:name :nvim-lint
 :event [:BufWritePost :BufReadPost]
 :after after}
