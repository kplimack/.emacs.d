;;; init.el --- Where all the magic begins
;;
;; This file loads Org-mode and then loads the rest of our Emacs initialization from Emacs lisp
;; embedded in literate Org-mode files.

;; Load up Org Mode and (now included) Org Babel for elisp embedded in Org Mode files
(require 'org)
(require 'org-install)
(require 'ob-tangle)
(org-babel-load-file "~/.emacs.d/emacs.org")
