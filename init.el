;;; init.el --- Where all the magic begins
;;
;; This file loads Org-mode and then loads the rest of our Emacs initialization from Emacs lisp
;; embedded in literate Org-mode files.


;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;;(package-initialize)

(setq ls-lisp-use-insert-directory-program t)
(setq insert-directory-program "gls")

;; Load up Org Mode and (now included) Org Babel for elisp embedded in Org Mode files
(require 'org)
(require 'org-install)
(require 'ob-tangle)
(org-babel-load-file "~/.emacs.d/emacs.org")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ede-project-directories '("/Users/kplimack/repos/iPotter"))
 '(package-selected-packages
   '(go rainbow-blocks go-errcheck go-stacktracer go-projectile js2-mode nodejs-repl go-snippets go-complete go-autocomplete go-mode rspec-mode nginx-mode impatient-mode flymd terraform-mode apache-mode toml-mode yari yaml-mode ruby-tools ruby-end ruby-block rubocop rainbow-mode rainbow-delimiters php-extras paredit markdown-mode magit json-mode inf-ruby htmlize highlight-parentheses helm-projectile geiser fuzzy exec-path-from-shell ecb cyberpunk-theme color-theme-solarized android-mode ac-slime)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-document-title ((t (:height 1.0))))
 '(org-level-1 ((t (:height 1.0))))
 '(org-level-2 ((t (:height 1.0))))
 '(org-level-3 ((t (:height 1.0)))))
