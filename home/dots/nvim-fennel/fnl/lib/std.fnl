(local cat (require :lib.categories))

(local M {})

;; Functions

(local F {})

(fn F.partial [f ...]
  (local a ...)
  (lambda [...] (f a ...)))

;; Iterators

(fn M.foldl [c i l]
  {:fnl/docstring "Fold an array onto an accumulator using a category"}
  (let [concat c.concat]
    (when (= nil concat) (error "Concat must be defined"))
    (var v i)
    (each [_ a (pairs l)]
      (set v (concat v a)))
    v))

(fn M.reduce [c l]
  (let [identity c.identity]
    (when (= nil identity)
      (error "Identity must be defined"))
    (M.foldl c identity l)))

;; Strings
(local S {})

(fn str-join [s]
  (lambda [a b] (.. a s b)))


(fn S.reduce [sep l]
  (let [c (cat.monoid.new (str-join sep) "")]
    (M.reduce c l)))

(fn S.join [sep ...]
  (S.reduce sep [...]))

(fn S.foldl [sep i l]
  (let [c (cat.monoid.new (str-join sep) i)]
    (M.reduce c l)))

(set M.str S)

;; Tables

(local tbl {})

(set tbl.merge-left (lambda [a b] (vim.tbl_deep_extend :keep a b)))

(set M.tbl tbl)

M
