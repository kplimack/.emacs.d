(add-to-list 'auto-mode-alist '("\\.zsh$" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.zshrc" . sh-mode))

(setenv "ESHELL" (expand-file-name "~/bin/eshell"))
