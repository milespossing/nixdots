(setq package-install-upgrade-built-in t)
(require 'org)
(org-babel-load-file
 (expand-file-name "configuration.org" user-emacs-directory))
