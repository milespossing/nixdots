;;; init.el --- My init file
;;; Commentary:
;;; This is the init file of mp-complete
;;; Code:

(setq package-install-upgrade-built-in t)
(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)
;; Install and configure the 'general' package
(use-package general
  :ensure (:wait t)
  :config
  (general-evil-setup t)

  (general-create-definer mp/leader-key-map
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer mp/ctrl-c-keys
    :prefix "C-c"))
(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)          ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)
(set-face-attribute 'default nil :font "DepartureMono Nerd Font")
(defun set-font-height (height)
  (set-face-attribute 'default nil :height height))
;; (set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;; (add-to-list 'default-frame-alist '(fullscreen . maximized))
(use-package doom-themes
  :config
  (load-theme 'doom-nord t))
(use-package doom-modeline
  :config
  (doom-modeline-mode 1))
(column-number-mode)
(global-display-line-numbers-mode t)
(setq display-line-numbers 'relative)
(use-package dashboard
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-center-content t))
(use-package counsel)
(use-package ivy
  :config
  (ivy-mode 1))
(use-package ivy-rich
  :config
  (ivy-rich-mode 1))
(use-package helpful
  :after counsel
  :config
  (setq counsel-describe-function-function #'helpful-callable)
  (setq counsel-describe-variable-function #'helpful-variable))

(defun current-user ()
  "Get the current username"
  (string-trim (shell-command-to-string "whoami")))

(defun current-hostname ()
  "Get the current host name"
  (string-trim (shell-command-to-string "hostname")))


(defun nixos-rebuild ()
  (interactive)
  (let* ((default-directory "/sudo:root@localhost:/")
         (hostname (current-hostname))
         (path (expand-file-name "~/.nixdots"))
         (command (format "nix-shell -p git --run 'nixos-rebuild switch --flake %s#%s'" path hostname))
         (buffer-name "*NixOS Rebuild Output*"))
    (with-current-buffer (get-buffer-create buffer-name)
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "Running: %s\n\n" command)))
    ;; Ensure command output is redirected properly
    (with-current-buffer buffer-name
      (let ((exit-code (process-file-shell-command command nil t)))
        (if (zerop exit-code)
            (insert "\nCommand completed successfully.\n")
          (insert (format "\nCommand failed with exit code: %d\n" exit-code))))
      (read-only-mode 1))
    (display-buffer buffer-name)))

(defun nix-os-rebuild-tramp-async ()
  "Rebuild NixOS configuration using Tramp with sudo as the current user, asynchronously."
  (interactive)
  (let* ((path (expand-file-name "~/.nixdots"))
         (hostname (current-host-name))
         (buffer-name "*NixOS Rebuild Output*")
         (default-directory (format "/sudo:root@localhost:/")) ;; Use sudo for root permissions locally
         (command (format "export PATH=/run/current-system/sw/bin:$PATH && nixos-rebuild switch --flake %s#%s" path hostname)))
    (with-current-buffer (get-buffer-create buffer-name)
      (read-only-mode -1)
      (erase-buffer)
      (insert (format "Running: %s\n\n" command))
      (read-only-mode 1))
    (start-process-shell-command "nixos-rebuild" buffer-name command)
    (display-buffer buffer-name)))


(mp/leader-key-map
  "hr" '(reload-configuration :which-key "Reload config file"))

(use-package direnv
  :config
  (direnv-mode))

(setq-default tab-width 2)
(setq-default evil-shift-width tab-width)
(setq-default indent-tabs-mode nil)

(use-package evil-nerd-commenter
  :after (evil general)
  :config
  (general-define-key
    :states 'normal
    "gcc" 'evilnc-comment-or-uncomment-lines)
      (general-define-key
        :states '(visual)
        "gc" 'evilnc-comment-or-uncomment-lines))

;; WSL-specific setup
(when (and (eq system-type 'gnu/linux)
           (getenv "WSLENV"))
   ;; WSL clipboard
  (defun copy-selected-text (start end)
    (interactive "r")
      (if (use-region-p)
        (let ((text (buffer-substring-no-properties start end)))
          (shell-command (concat "echo '" text "' | clip.exe"))))))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "C-M-u") 'universal-argument)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :demand t
  :config
  (evil-mode 1)
  (setq evil-buffer-regexps '(("^ \\*load\\*")
    ("^\\*Org Src .*\\*$"))))
  (use-package evil-collection
    :after evil
    :config
    (setq evil-collection-want-unimpaired-p nil)
    (evil-collection-init))
(use-package which-key
  :ensure (:wait t)
  :demand t
  :config
  (which-key-mode))

(mp/leader-key-map
  "f"  '(:ignore t :which-key "file")
  "ff" '(find-file :which-key "file open"))

(mp/leader-key-map
  "b"  '(:ignore t :which-key "buffer")
  "bb" '(counsel-switch-buffer :which-key "buffer switch")
  "bd" '(kill-current-buffer :which-key "buffer delete")
  "br" '(revert-buffer-quick :which-key "revert buffer"))


  (mp/leader-key-map
    "w"  '(:ignore t :which-key "window")
    "wj" '(evil-window-down :which-key "move down")
    "wh" '(evil-window-left :which-key "move left")
    "wl" '(evil-window-right :which-key "move right")
    "wk" '(evil-window-up :which-key "move up")
    "wd" '(evil-window-delete :which-key "delete")
    "ws" '(evil-window-split :which-key "split horizontal")
    "wv" '(evil-window-vsplit :which-key "split vertical"))

(defvar mp/emacs-config-path "~/.nixdots/home/dots/emacs/init.el")

(mp/leader-key-map
  "h" '(:ignore t :which-key "help")
  "hf" '(counsel-describe-function :which-key "describe/function")
  "hv" '(counsel-describe-variable :which-key "describe/variable")
  "hk" '(helpful-key :which-key "describe/key")
  "hm" '(describe-mode :which-key "describe/mode")
  "hM" '(info-display-manual :which-key "display manual")
  "h." '(:ignore t :which-key "dotfiles")
  "h.c" '((lambda () (interactive) (find-file mp/emacs-config-path)) :which-key "open configuration"))

(mp/leader-key-map
  "t" '(:ignore t :which-key "toggle")
  "tw" '(white-space-mode :which-key "toggle whitespace")
  "tt" '(counsel-load-theme :which-key "load theme"))

(mp/leader-key-map
  ;; EXECUTE
  ":"  '(counsel-M-x :which-key "execute"))

(use-package vertico
  :config
  (vertico-mode))

(use-package projectile
  :config
  (projectile-mode +1)
  (setq projectile-project-search-path '("~/org" "~/src"))
  (mp/leader-key-map
    "p" '(:ignore t :which-key "project")
    "pp" '(projectile-switch-project :which-key "switch project")
    "SPC" '(projectile-find-file :which-key "find file")
    "pf" '(projectile-find-file :which-key "find file")))

(defun +elpaca-unload-seq (e)
  (and (featurep 'seq) (unload-feature 'seq t))
  (elpaca--continue-build e))

;; You could embed this code directly in the reicpe, I just abstracted it into a function.
(defun +elpaca-seq-build-steps ()
  (append (butlast (if (file-exists-p (expand-file-name "seq" elpaca-builds-directory))
                       elpaca--pre-built-steps elpaca-build-steps))
          (list '+elpaca-unload-seq 'elpaca--activate-package)))

;; this needs to be here to make sure that the server starts just right.
(server-start)
(setq-default with-editor-emacsclient-executable "emacsclient")

(elpaca `(seq :build ,(+elpaca-seq-build-steps)))
(use-package transient :after seq)
(use-package magit
  :after transient seq
  :config
  (mp/leader-key-map
    "g" '(:ignore t :which-key "git")
    "gg" '(magit-status :which-key "status")))
  
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))
(use-package evil-snipe
  :config
  (evil-snipe-mode +1)
  (evil-snipe-override-mode +1))
(use-package avy
  :config
  (general-define-key
    :states '(normal visual motion)
    "g s SPC" 'avy-goto-char-timer
    "gl" 'avy-goto-line
    "gw" 'avy-goto-word-1-below
    "gW" 'avy-goto-word-1-above))
;(use-package vterm)
(add-hook 'eshell-mode-hook (lambda () (setenv "TERM" "xterm-256color"))) 
(use-package lsp-mode
  :init
  :hook (typescript-ts-mode . lsp)
         (rust-mode . lsp)
         (scala-mode . lsp)
         (clojure-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration)
  :commands lsp)
(use-package lsp-ui :commands lsp-ui-mode)
(use-package flycheck
  :init (global-flycheck-mode))
(use-package company
  :hook (scala-mode . company-mode)
  :config
  (company-mode)
  (setq company-tooltip-align-notations 1))
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package dap-mode
  :config
  ;; Enabling only some features
  (setq dap-auto-configure-features '(sessions locals controls tooltip)))

(mp/leader-key-map
  "X" 'org-capture)
(general-define-key
  :states '(normal visual motion)
  :keymaps 'org-mode-map
  :prefix "SPC m"
  "t" '(:ignore t :which-key "todo")
  "tt" 'org-todo
  "ts" 'org-schedule
  "a" 'org-agenda
  "c" 'org-capture
  "l" 'org-insert-link
  "e" '(:ignore t :which-key "execute")
  "eb" '(org-babel-execute-src-block :which-key "block")
  "eB" '(org-babel-execute-buffer :which-key "buffer")
  "s" '(:ignore t :which-key "subtree")
  "sl" '(org-demote-subtree :which-key "demote")
  "sh" '(org-promote-subtree :which-key "promote")
  "sj" '(org-move-subtree-down :which-key "move down")
  "sk" '(org-move-subtree-up :which-key "move up")
  "sr" '(org-refile :which-key "refile")
  "p" '(:ignore t :which-key "properties")
  "ps" '(org-set-property :which-key "set property"))
(setq org-pretty-entities t)
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))
(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.2))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.15))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.1))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.05))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.0)))))
(setq org-startup-indented t)
(add-hook 'org-src-mode-hook
  (lambda () (electric-indent-local-mode -1)))
(setq org-agenda-files (append '("~/org/inbox.org"
                         ;;"~/org/tickler.org"
                         "~/org/gtd.org"
                         "~/org/home.org")
                         (file-expand-wildcards "~/org/*.project.org")))
(mp/leader-key-map
  "o" '(:ignore t :which-key "org")
  "o a" 'org-agenda)
(setq org-refile-targets '(("~/org/gtd.org" :maxlevel . 3)
                           ("~/org/archive.org" :maxlevel . 1)
                           ("~/org/someday.org" :level . 1)))

(setq org-capture-templates '(("t" "Todo [inbox]" entry
                               (file+headline "~/org/inbox.org" "Tasks")
                               "* TODO %i%?")
                              ("T" "Tickler" entry
                               (file+headline "~/org/tickler.org" "Tickler")
                               "* %i%? \n %U")))
(setq org-todo-keywords '((sequence "TODO(t)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
(require 'org-habit)
(add-to-list 'org-modules 'org-habit t)
(setq org-habit-following-days 3
      org-habit-preceding-days 14
      org-habit-graph-column 55
      org-habit-show-all-today t)
;; (use-package org-caldav)
;;   :config
;;   (setq org-caldav-calendars
;;     '((:calendar-id "personal
(use-package markdown-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  (setq markdown-command "multimarkdown"))
(use-package nix-mode
  :mode "\\.nix\\'")

(use-package paredit
  :config
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode))

(general-define-key
  :states '(normal visual modtion)
  :keymaps 'emacs-lisp-mode-map
  :prefix "SPC m"
  "e" '(:ignore t :which-key "eval")
  "er" '(eval-region :which-key "eval region"))

(use-package clojure-mode
  :config
  (add-hook 'clojure-mode-hook #'paredit-mode)
  (add-to-list 'auto-mode-alist '("\\.edn\\'" . clojure-mode)))

(use-package racket-mode
  :after paredit
  :config
  (add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))
  (add-hook 'racket-mode-hook 'paredit-mode)
  (add-hook 'racket-repl-mode-hook 'paredit-mode)
  (define-key racket-repl-mode-map (kbd "<C-return>") 'racket-repl-submit)
  (define-key racket-repl-mode-map (kbd "<C-up>") 'racket-repl-previous-input)
  (define-key racket-repl-mode-map (kbd "<C-down>") 'racket-repl-next-input)
  (define-key racket-mode-map (kbd "<f5>") 'racket-run)
  (define-key racket-mode-map (kbd "<S-f5>") 'racket-run-and-switch-to-repl))

(use-package cider
  :after paredit
  :config
  (add-hook 'cider-repl-mode-hook #'paredit-mode)
  (define-key cider-repl-mode-map (kbd "<return>") 'cider-repl-newline-and-indent)
  (define-key cider-repl-mode-map (kbd "<C-return>") 'cider-repl-return))
(use-package rust-mode
  :config
  ;; Enable rustfmt on save
  (setq rust-format-on-save t)

  ;; Indentation settings
  (add-hook 'rust-mode-hook
            (lambda () (setq indent-tabs-mode nil)))

  ;; Prettify symbols
  (add-hook 'rust-mode-hook
            (lambda () (prettify-symbols-mode)))
  (general-define-key
    :states '(normal visual modtion)
     :keymaps 'rust-mode-map
     :prefix "SPC m"
     "b" '(:ignore t :which-key "build")
     "bb" '(rust-compile :which-key "compile")
     "br" '(rust-run :which-key "run")
     "bt" '(rust-test :which-key "test")
     "bc" '(rust-check :which-key "check")
     "l" '(rust-run-clippy :which-key "lint")))
(use-package cargo
    :after rust-mode
    :config
    (add-hook 'rust-mode-hook 'cargo-minor-mode))
(use-package tide
  :after (company flycheck)
  :hook ((typescript-ts-mode . tide-setup)
         (tsx-ts-mode . tide-setup)
         (typescript-ts-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))
(use-package purescript-mode)

;; Typst Mode

(use-package typst-ts-mode
  :ensure (:type git :host codeberg :repo "meow_king/typst-ts-mode"
                 :files (:defaults "*.el")))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(warning-suppress-log-types '((comp))))

;;; init.el ends here
