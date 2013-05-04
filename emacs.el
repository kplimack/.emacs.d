
(defvar jp:base-dir (file-name-directory load-file-name)
  "The root dir of the Emacs distribution.")

(defvar jp:personal-dir (expand-file-name "personal" jp:base-dir)
  "This directory houses all of the personal configuration.")

(defvar jp:savefile-dir (expand-file-name "savefile" jp:personal-dir)
  "This folder stores all the automatically generated save/history-files.")

(setq user-full-name "Jake Plimack")
(setq user-mail-address "jake@jakeplimack.com")
(setq user-homepage "http://jakeplimack.com")

(load "server")
(unless (server-running-p) (server-start))

(require 'package)

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages
  '(
    ;; editing
    auto-complete
    popup
    fuzzy

    ;; themes
    cyberpunk-theme
    color-theme-solarized

    ;; org
    htmlize

    ;; git stuff
    magit

    ;; general lisp
    paredit
    rainbow-delimiters
    rainbow-mode
    slime
    highlight-parentheses
    ac-slime

    ;; scheme
    geiser

    ;; clojure
    clojure-mode
    nrepl
    ac-nrepl

    ;; project and files
    helm
    helm-projectile

    ;; eshell
    exec-path-from-shell

    ;; modes
    markdown-mode
    yaml-mode
    json-mode

    ;; ruby
    ruby-block
    ruby-end
    ruby-tools
    inf-ruby
    yari)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(setq initial-scratch-message "")

(setq inhibit-startup-screen t)

(electric-pair-mode t)

(tooltip-mode -1)

(show-paren-mode 1)

(set-default 'indent-tabs-mode nil)
(set-default 'indicate-empty-lines t)

;; nice scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;; mode line settings
(line-number-mode t)
(column-number-mode t)
(size-indication-mode t)

;; enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

(random t) ;; Seed the random-number generator

;; show-paren-mode: subtle highlighting of matching parens (global-mode)
(show-paren-mode +1)
(setq show-paren-style 'parenthesis)

;; make a shell script executable automatically on save
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

; save cursor position within files
(require 'saveplace)
(setq save-place-file (expand-file-name "saveplace" jp:savefile-dir))
(setq-default save-place t)

; save minibuffer history across sessions
(setq savehist-file (expand-file-name "savehist" jp:savefile-dir))
(savehist-mode 1)

;; Don't clutter with files~, #file#, backup, etc
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)
(setq make-backup-files nil)
(setq auto-save-default nil)

(setq recentf-save-file (expand-file-name "recentf" jp:savefile-dir))
(setq bookmark-default-file (expand-file-name "bookmarks" jp:savefile-dir))
(setq smex-save-file (expand-file-name "smex-items" jp:savefile-dir))

;; sane defaults
(prefer-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)

; pick up changes to files on disk automatically (ie, after git pull)
(global-auto-revert-mode 1)

; wrap lines in a tasteful way
(global-visual-line-mode 1)

(require 'browse-url)

(defun jp:back-window ()
  (interactive)
  (other-window -1))

(defun jp:insert-date ()
  "Insert a time-stamp according to locale's date and time format."
  (interactive)
  (insert (format-time-string "%c" (current-time))))

(defun jp:google ()
  "Googles a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (url-hexify-string (if mark-active
         (buffer-substring (region-beginning) (region-end))
       (read-string "Google: "))))))

(defun jp:pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(add-hook 'prog-mode-hook 'jp:pretty-lambdas)

(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;; Move lines
;; - from http://www.emacswiki.org/emacs/MoveLine

(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

;; Align Equal Signs
;; corrected form from:
;;   http://stackoverflow.com/questions/3633120/emacs-hotkey-to-align-equal-signs
(defun align-equal-signs (begin end)
  "Align region to equal signs"
  (interactive "r")
  (align-regexp begin end "\\(\\s-*\\)=" 1 1 ))

;;; Stefan Monnier <foo at acm.org>. It is the opposite of
;;; fill-paragraph. Takes a multi-line paragraph and makes
;;; it into a single line of text.
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))

(dolist (command '(yank yank-pop))
  (eval `(defadvice ,command (after indent-region activate)
           (and (not current-prefix-arg)
                (member major-mode '(emacs-lisp-mode lisp-mode
                                                     clojure-mode    scheme-mode
                                                     haskell-mode    ruby-mode
                                                     rspec-mode      python-mode
                                                     c-mode          c++-mode
                                                     objc-mode       latex-mode
                                                     plain-tex-mode))
                (let ((mark-even-if-inactive transient-mark-mode))
                  (indent-region (region-beginning) (region-end) nil))))))

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(setq ring-bell-function 'ignore)

;; no fringe (small bars on the left side of the screen)
(if (fboundp 'fringe-mode)
    (fringe-mode 0))

;; no menu bar
(menu-bar-mode -1)

;; the blinking cursor is nothing, but an annoyance
(blink-cursor-mode -1)

;; directory for extra themes
(add-to-list 'custom-theme-load-path (expand-file-name "themes" jp:personal-dir))

;; load our default theme
(load-theme 'naquadah t)

(custom-set-faces
 '(org-level-1 ((t (:height 1.0))))
 '(org-level-2 ((t (:height 1.0))))
 '(org-level-3 ((t (:height 1.0))))
 '(org-document-title ((t (:height 1.0)))))

;; nop no visual bell
(setq visible-bell nil)
(setq whitespace-style '(face trailing tabs))

;; set default position
;; (setq my-frame-width 130)
;; (setq my-frame-height 52)
;; (setq my-frame-top 45)
;; (setq my-frame-left 150)

;; (set-frame-position (selected-frame) my-frame-left my-frame-top)
;; (set-frame-size (selected-frame) my-frame-width my-frame-height)

;; set default font
(setq my-font-family "Source Code Pro")
(setq my-font-height 115)

(set-face-attribute 'default nil :height my-font-height)
(set-face-attribute 'default nil :family my-font-family)

;; more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
      '((:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b"))))

;; Diminish modeline clutter
;;(require 'diminish)

;; general emacs stuff
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "C-c .") 'browse-url)

;; general development
(global-set-key (kbd "M-r") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c t") 'whitespace-toggle-options)
(global-set-key (kbd "C-x g") 'magit-status)

;; clojure stuff
(global-set-key (kbd "C-c C-j") 'nrepl-jack-in)

;; resize windows
(global-set-key (kbd "C-c =") 'enlarge-window)
(global-set-key (kbd "C-c -") 'shrink-window)
(global-set-key (kbd "C-c +") 'enlarge-window-horizontally)
(global-set-key (kbd "C-c _") 'shrink-window-horizontally)

;; switch between dictionaries for aspell
(global-set-key (kbd "C-c C-f") 'jp:aspell-french)
(global-set-key (kbd "C-c C-e") 'jp:aspell-english)

;; split
(global-set-key (kbd "C-c C-t") 'jp:split-window-vertically-for-eshell)

;; google it
(global-set-key (kbd "C-c C-g") 'jp:google)

;; Start eshell or switch to it if it's active.
(global-set-key (kbd "C-x m") 'eshell)

;; Start a new eshell even if one is active.
(global-set-key (kbd "C-x M") (lambda () (interactive) (eshell t)))

;; Completion that uses many different methods to find options.
(global-set-key (kbd "M-/") 'hippie-expand)

;; Font size
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

;; Window switching. (C-x o goes to the next window)
(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two

;; M-S-6 is awkward
(global-set-key (kbd "C-c q") 'join-line)

;; eval the buffer
(global-set-key (kbd "C-c v") 'eval-buffer)

;; ELPA FIXME broken!
(global-set-key (kbd "C-c p") 'package-list-packages)

(global-set-key (kbd "C-c H") 'jp:helm-project)
(global-set-key (kbd "C-c h") 'helm-mini)

;; org
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-ca" 'org-agenda)

;; helm
(global-set-key (kbd "C-x C-f") 'helm-find-files)

;; movement
(global-set-key (kbd "C-x O") 'jp:back-window)

(global-set-key (kbd "M-j") (lambda () (interactive) (join-line -1)))

(require 'popup)
(require 'fuzzy)
(require 'auto-complete)
(require 'auto-complete-config)

(ac-config-default)
(ac-flyspell-workaround)

;; the default dictionary is good enough for now
;;(add-to-list 'ac-dictionary-directories (concat (live-pack-lib-dir) "auto-complete/dict"))
(setq ac-comphist-file (concat jp:savefile-dir "/" "ac-comphist.dat"))

(global-auto-complete-mode t)
(setq ac-auto-show-menu t)
(setq ac-dwim t)
(setq ac-use-menu-map t)
(setq ac-quick-help-delay 1)
(setq ac-quick-help-height 60)
(setq ac-disable-inline t)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-auto-start 2)
(setq ac-candidate-menu-min 0)

(set-default 'ac-sources
             '(ac-source-dictionary
               ac-source-words-in-buffer
               ac-source-words-in-same-mode-buffers
               ac-source-semantic
               ac-source-yasnippet))

;; Exclude very large buffers from dabbrev
(defun jp:dabbrev-friend-buffer (other-buffer)
  (< (buffer-size other-buffer) (* 1 1024 1024)))

(setq dabbrev-friend-buffer-function 'jp:dabbrev-friend-buffer)

(dolist
    (mode '(clojure-mode lisp-mode python-mode perl-mode cperl-mode haml-mode sass-mode sh-mode geiser-mode))
  (add-to-list 'ac-modes mode))

;;;;Key triggers
(define-key ac-completing-map (kbd "C-M-n") 'ac-next)
(define-key ac-completing-map (kbd "C-M-p") 'ac-previous)
(define-key ac-completing-map "\t" 'ac-complete)
(define-key ac-completing-map (kbd "M-RET") 'ac-help)
(define-key ac-completing-map "\r" 'nil)

(setq epg-gpg-program "/usr/local/bin/gpg")

(load-library "~/.password.el.gpg")

;; clean up obsolete buffers automatically
(require 'midnight)
(require 'uniquify)

(setq uniquify-buffer-name-style 'reverse)
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

(autoload 'ibuffer "ibuffer" "List buffers." t)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("dired" (mode . dired-mode))
               ("perl" (mode . cperl-mode))
               ("python" (mode . python-mode))
               ("clojure" (mode . clojure-mode))
               ("ruby" (mode . ruby-mode))
               ("org" (mode . org-mode))
               ("irc" (mode . rcirc-mode))
               ("magit" (name . "\*magit"))
               ("emacs" (or
                         (mode . emacs-lisp-mode)
                         (name . "\*eshell")
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))))))

(add-hook 'ibuffer-mode-hook
          '(lambda ()
             (ibuffer-auto-mode 1)
             (ibuffer-switch-to-saved-filter-groups "default")))

(setq ibuffer-show-empty-filter-groups nil)

(require 'em-smart)

;; smart display
(setq eshell-where-to-jump 'begin)
(setq eshell-review-quick-commands nil)
(setq eshell-smart-space-goes-to-end t)

(exec-path-from-shell-initialize)

(setq eshell-directory-name (expand-file-name "./" (expand-file-name "eshell" jp:savefile-dir)))

(setq eshell-last-dir-ring-file-name
      (concat eshell-directory-name "lastdir"))
(setq eshell-ask-to-save-last-dir 'always)

(setq eshell-history-file-name
      (concat eshell-directory-name "history"))

(setq eshell-aliases-file (expand-file-name "eshell.alias" jp:personal-dir ))

(require 'cl)
(defun jp:shorten-dir (dir)
  "Shorten a directory, (almost) like fish does it."
  (let ((scount (1- (count ?/ dir))))
    (dotimes (i scount)
      (string-match "\\(/\\.?.\\)[^/]+" dir)
      (setq dir (replace-match "\\1" nil nil dir))))
  dir)

(setq eshell-prompt-function
      (lambda ()
        (concat
         (jp:shorten-dir (eshell/pwd))
         " > ")))

(setq eshell-cmpl-cycle-completions nil
      eshell-save-history-on-exit t
      eshell-buffer-shorthand t
      eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'")

(eval-after-load 'esh-opt
  '(progn
     (require 'em-prompt)
     (require 'em-term)
     (require 'em-cmpl)
     (electric-pair-mode -1)
     (setenv "LANG" "en_US.UTF-8")
     (setenv "PAGER" "cat")
     (add-hook 'eshell-mode-hook ;; for some reason this needs to be a hook
               '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-bol)))
     (setq eshell-cmpl-cycle-completions nil)

     ;; TODO: submit these via M-x report-emacs-bug
     (add-to-list 'eshell-visual-commands "ssh")
     (add-to-list 'eshell-visual-commands "tail")
     (add-to-list 'eshell-command-completions-alist
                  '("gunzip" "gz\\'"))
     (add-to-list 'eshell-command-completions-alist
                  '("tar" "\\(\\.tar|\\.tgz\\|\\.tar\\.gz\\)\\'"))))

;;;###autoload
(defun eshell/cds ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory "src")))

;;;###autoload
(defun eshell/cds ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory "src")))

;;;###autoload
(defun eshell/cdl ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory "lib")))

;;;###autoload
(defun eshell/cdg ()
  "Change directory to the project's root."
  (eshell/cd (locate-dominating-file default-directory ".git")))

;; these two haven't made it upstream yet
;;;###autoload
(when (not (functionp 'eshell/find))
  (defun eshell/find (dir &rest opts)
    (find-dired dir (mapconcat (lambda (arg)
                                 (if (get-text-property 0 'escaped arg)
                                     (concat "\"" arg "\"")
                                   arg))
                               opts " "))))

;;;###autoload
(when (not (functionp 'eshell/rgrep))
  (defun eshell/rgrep (&rest args)
    "Use Emacs grep facility instead of calling external grep."
    (eshell-grep "rgrep" args t)))

;;;###autoload
(defun eshell/extract (file)
  (let ((command (some (lambda (x)
                         (if (string-match-p (car x) file)
                             (cadr x)))
                       '((".*\.tar.bz2" "tar xjf")
                         (".*\.tar.gz" "tar xzf")
                         (".*\.bz2" "bunzip2")
                         (".*\.rar" "unrar x")
                         (".*\.gz" "gunzip")
                         (".*\.tar" "tar xf")
                         (".*\.tbz2" "tar xjf")
                         (".*\.tgz" "tar xzf")
                         (".*\.zip" "unzip")
                         (".*\.Z" "uncompress")
                         (".*" "echo 'Could not extract the file:'")))))
    (eshell-command-result (concat command " " file))))

(defface jp:eshell-error-prompt-face
  '((((class color) (background dark)) (:foreground "red" :bold t))
    (((class color) (background light)) (:foreground "red" :bold t)))
  "Face for nonzero prompt results"
  :group 'eshell-prompt)

(add-hook 'eshell-after-prompt-hook
          (defun jp:eshell-exit-code-prompt-face ()
            (when (and eshell-last-command-status
                       (not (zerop eshell-last-command-status)))
              (let ((inhibit-read-only t))
                (add-text-properties
                 (save-excursion (beginning-of-line) (point)) (point-max)
                 '(face jp:eshell-error-prompt-face))))))

(defun jp:eshell-in-dir (&optional prompt)
  "Change the directory of an existing eshell to the directory of the file in
  the current buffer or launch a new eshell if one isn't running.  If the
  current buffer does not have a file (e.g., a *scratch* buffer) launch or raise
  eshell, as appropriate.  Given a prefix arg, prompt for the destination
  directory."
  (interactive "P")
  (let* ((name (buffer-file-name))
         (dir (cond (prompt (read-directory-name "Directory: " nil nil t))
                    (name (file-name-directory name))
                    (t nil)))
         (buffers (delq nil (mapcar (lambda (buf)
                                      (with-current-buffer buf
                                        (when (eq 'eshell-mode major-mode)
                                          (buffer-name))))
                                    (buffer-list))))
         (buffer (cond ((eq 1 (length buffers)) (first buffers))
                       ((< 1 (length buffers)) (ido-completing-read
                                                "Eshell buffer: " buffers nil t
                                                nil nil (first buffers)))
                       (t (eshell)))))
    (with-current-buffer buffer
      (when dir
        (eshell/cd (list dir))
        (eshell-send-input))
      (end-of-buffer)
      (pop-to-buffer buffer))))

(require 'htmlize)
;; various preferences
(setq org-modules (quote (org-habit))
      org-directory "~/Desktop/Dropbox/Personal/" ;; everything is stored in Dropbox
      org-default-notes-file (concat org-directory "/refile.org")
      org-startup-indented t
      org-hide-leading-stars t
      org-oddeven-levels-only t
      org-tags-column 65
      org-use-fast-todo-selection t
      org-completion-use-ido t
      org-log-done 'note
      org-log-into-drawer t
      org-cycle-separator-lines 0
      org-agenda-window-setup 'current-window
      org-agenda-span 2
      org-agenda-include-diary t
      org-agenda-show-log t
      org-agenda-start-on-weekday nil
      org-export-htmlize-output-type 'css
      org-agenda-log-mode-items (quote (closed state))
      org-habit-show-habits t)

(setq org-agenda-files (list "~/Desktop/Dropbox/Personal/organizer.org"
                             "~/Desktop/Dropbox/Personal/projects.org"
                             "~/Desktop/Dropbox/Personal/ihr.org"
                             "~/Desktop/Dropbox/Personal/journal.org"
                             "~/Desktop/Dropbox/Personal/talks.org"))

;; refile behavior
(setq org-refile-targets '((org-agenda-files :maxlevel . 5) (nil :maxlevel . 5)))
(setq org-refile-use-outline-path 'file)
(setq org-refile-allow-creating-parent-nodes (quote confirm))
(setq org-outline-path-complete-in-steps t)

(setq org-todo-keywords
 '((sequence "TODO(t)" "STARTED(s!)" "|" "DONE(d!/!)")
   (sequence "WAITING(w@/!)" "SOMEDAY(S!)" "OPEN(O@)" "|" "CANCELLED(c@/!)")))

(setq org-todo-state-tags-triggers
      '(("CANCELLED" ("CANCELLED" . t))
        ("WAITING" ("WAITING" . t) ("NEXT"))
        ("SOMEDAY" ("WAITING" . t))
        (done ("NEXT") ("WAITING"))
        ("TODO" ("WAITING") ("CANCELLED") ("NEXT"))
        ("STARTED" ("WAITING"))
        ("DONE" ("WAITING") ("CANCELLED") ("NEXT"))))

;; Tags with fast selection keys
(setq org-tag-alist '(("ADMIN" . ?a)
                      ("HOME" . ?h)
                      ("MAIL" . ?m)
                      ("TODO" . ?t)
                      ("COMPUTER" . ?u)
                      ("JOURNAL" . ?j)
                      ("DIET" . ?d)
                      ("ERRANDS" . ?e)
                      ("CODING" . ?c)
                      ("RESEARCH" . ?r)
                      ("OFFICE" . ?o)
                      ("BUGFIX" . ?b)
                      ("CONFIG" . ?n)))

(setq org-global-properties
      '(("Effort_ALL". "0:05 0:15 0:30 1:00 2:00 3:00 4:00")))

(setq org-capture-templates
      '(("t" "Tasks" entry
         (file+headline "~/Desktop/Dropbox/Personal/organizer.org" "Tasks")
         "* TODO %^{Task} %^g
%?
:PROPERTIES:
:Effort: %^{effort|1:00|0:05|0:15|0:30|2:00|4:00}
:END:")
        ("b" "IHR task" entry
         (file+headline "~/Desktop/Dropbox/Personal/ihr.org" "Tasks")
         "* TODO %^{Task} %^g
%?
:PROPERTIES:
:Effort: %^{effort|1:00|0:05|0:15|0:30|2:00|4:00}
:END:")
        ("d" "Done task" entry
         (file+headline "~/Desktop/Dropbox/Personal/organizer.org" "Tasks")
         "* DONE %^{Task} %^g
SCHEDULED: %^t
%?")
        ("r" "Refile" entry
         (file "~/Desktop/Dropbox/Personal/refile.org")
         "* TODO %^{Name} %^g
%?")
        ("c" "Culture" entry
         (file+headline "~/Desktop/Dropbox/Personal/organizer.org" "Culture")
         "* TODO %^{Name} %^g
%?")
        ("q" "Quick task" entry
         (file+headline "~/Desktop/Dropbox/Personal/organizer.org" "Tasks")
         "* TODO %^{Task} %^g"
         :immediate-finish t)
        ("T" "Note from talks/lectures" entry
          (file+datetree "~/Desktop/Dropbox/Personal/talks.org")
          "* %^{Name} %T
%?")
        ("N" "IHR: Note" entry
          (file+datetree "~/Desktop/Dropbox/Personal/ihr.org")
          "* %^{Name} %T
%?")
         ("j" "Journal" entry
          (file+datetree "~/Desktop/Dropbox/Personal/journal.org")
          "* %^{Name} %T :DIARY:
%?"
          :clock-in :clock-resume)))

;; custom agenda views
(setq org-agenda-custom-commands
      '(("s" "Started Tasks" todo "STARTED"
         ((org-agenda-todo-ignore-scheduled nil)
          (org-agenda-todo-ignore-deadlines nil)
          (org-agenda-todo-ignore-with-date nil)))

        ("w" "Tasks waiting on something" tags "WAITING/!"
         ((org-use-tag-inheritance nil)))

        ("r" "Refile New Notes and Tasks" tags "LEVEL=1+REFILE"
         ((org-agenda-todo-ignore-with-date nil)
          (org-agenda-todo-ignore-deadlines nil)
          (org-agenda-todo-ignore-scheduled nil)))

        ("N" "Notes" tags "NOTE" nil)
        ("n" "Next" tags "NEXT-WAITING-CANCELLED/!" nil)
        ("p" "Projects" tags-todo "LEVEL=2-NEXT-WAITING-CANCELLED/!-DONE" nil)
        ("A" "Tasks to be Archived" tags "LEVEL=2/DONE|CANCELLED" nil)

        ("h" "Habits" tags "STYLE=\"habit\""
         ((org-agenda-todo-ignore-with-date nil)
          (org-agenda-todo-ignore-scheduled nil)
          (org-agenda-todo-ignore-deadlines nil)))))

(setq org-habit-graph-column 80)
(setq org-habit-show-habits-only-for-today nil)
(setq org-habit-following-days 3)
(setq org-habit-preceding-days 3)

;; prevents creating blank lines before headings but allows list items to adapt to existing blank lines around the items:
(setq org-blank-before-new-entry (quote ((heading) (plain-list-item . auto))))

;; encryption
(require 'org-crypt)
(setq org-tags-exclude-from-inheritance (quote ("crypt")))
(setq org-crypt-key "93A80B459A93BEED")
(org-crypt-use-before-save-magic)

;; babel
(require 'ob)
(require 'ob-tangle)
(require 'ob-clojure)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (scheme     . t)
   (sh         . t)
   (clojure    . t)))

(defun org-babel-execute:scheme (body params)
  (let* ((tangle (cdr (assoc :tangle params)))
         (script-file
          (if (string-equal tangle "no")
              (org-babel-temp-file "org-babel-" ".rkt")
            tangle)))
    (with-temp-file script-file
      (insert body))
    (let* ((pn (org-babel-process-file-name script-file))
           (cmd (format "racket -u %s" pn)))
      (message cmd)
      (shell-command-to-string cmd))))

(declare-function nrepl-send-string-sync "ext:nrepl" (code &optional ns))

(defun org-babel-execute:clojure (body params)
  "Execute a block of Clojure code with Babel."
  (require 'nrepl)
  (with-temp-buffer
    (insert (org-babel-expand-body:clojure body params))
    ((lambda (result)
       (let ((result-params (cdr (assoc :result-params params))))
         (if (or (member "scalar" result-params)
                 (member "verbatim" result-params))
             result
           (condition-case nil (org-babel-script-escape result)
             (error result)))))
     (plist-get (nrepl-send-string-sync
                 (buffer-substring-no-properties (point-min) (point-max))
                 (cdr (assoc :package params)))
                :value))))

(defun jp:aspell-french ()
  (interactive)
  (ispell-change-dictionary "french"))

(defun jp:aspell-english ()
  (interactive)
  (ispell-change-dictionary "english"))

(setq ispell-program-name "aspell" ; use aspell instead of ispell
      ispell-extra-args '("--sug-mode=ultra"))

(autoload 'flyspell-mode "flyspell" "On-the-fly spelling checker." t)

(add-hook 'message-mode-hook 'flyspell-mode)
(add-hook 'text-mode-hook 'flyspell-mode)

(add-to-list 'auto-mode-alist '("\\.txt$" . text-mode))

(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mkd$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

(add-to-list 'auto-mode-alist '("\\.rst$" . rst-mode))

(defun jp:rst-mode-hook ()
  (auto-fill-mode t))

(add-hook 'rst-mode-hook 'jp:rst-mode-hook)

(require 'projectile)
(require 'helm-misc)
(require 'helm-projectile)

(setq projectile-cache-file (expand-file-name  "projectile.cache" jp:savefile-dir))

(projectile-global-mode t)

(setq projectile-globally-ignored-files
      (append projectile-globally-ignored-files
              '(
                ;; python
                "pyc")))

(defun jp:helm-project ()
  "Preconfigured `helm'."
  (interactive)
  (condition-case nil
    (if (projectile-project-root)
        ;; add project files and buffers when in project
        (helm-other-buffer '(helm-c-source-projectile-files-list
                             helm-c-source-projectile-buffers-list
                             helm-c-source-buffers-list
                             helm-c-source-recentf
                             helm-c-source-buffer-not-found)
                           "*helm prelude*")
      ;; otherwise fallback to helm-mini
      (helm-mini))
    ;; fall back to helm mini if an error occurs (usually in projectile-project-root)
    (error (helm-mini))))

(defun jp:magit-log-edit-mode-hook ()
  (setq fill-column 72)
  (auto-fill-mode t))

(add-hook 'magit-log-edit-mode-hook 'jp:magit-log-edit-mode-hook)

(require 'which-func)
(which-function-mode 1)

(defun jp:add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(defun jp:prog-mode-defaults ()
  "Default coding hook, useful with any programming language."
  (whitespace-mode +1)
  (define-key global-map (kbd "RET") 'newline-and-indent)
  (setq-default tab-width 4) ;; default indentation
  (setq require-final-newline 't) ;; newline at EOF
  (jp:add-watchwords))

(setq jp:prog-mode-hook 'jp:prog-mode-defaults)

(add-hook 'prog-mode-hook (lambda () (run-hooks 'jp:prog-mode-hook)))

(add-to-list 'auto-mode-alist '("\\.el*" . emacs-lisp-mode))

(defun jp:emacs-lisp-mode-defaults ()
  (run-hooks 'jp:lisp-coding-hook)
  (turn-on-eldoc-mode)
  (rainbow-mode +1))

(setq jp:emacs-lisp-mode-hook 'jp:emacs-lisp-mode-defaults)

(add-hook 'emacs-lisp-mode-hook (lambda () (run-hooks 'jp:emacs-lisp-mode-hook)))

(eval-after-load 'clojure-mode
  '(progn
     (defun jp:clojure-mode-defaults ()
       (subword-mode +1)
       (turn-on-eldoc-mode)
       (run-hooks 'jp:lisp-coding-hook))

     (setq jp:clojure-mode-hook 'jp:clojure-mode-defaults)

     (add-hook 'clojure-mode-hook (lambda ()
                                    (run-hooks 'jp:clojure-mode-hook)))))

(eval-after-load 'nrepl
  '(progn
     (add-hook 'nrepl-interaction-mode-hook 'nrepl-turn-on-eldoc-mode)

     (defun jp:nrepl-mode-defaults ()
       (subword-mode +1)
       (run-hooks 'jp:interactive-lisp-coding-hook))

     (setq jp:nrepl-mode-hook 'jp:nrepl-mode-defaults)

     (add-hook 'nrepl-mode-hook (lambda ()
                                  (run-hooks 'jp:nrepl-mode-hook)))))

(setq nrepl-popup-stacktraces nil)

(require 'ac-nrepl )
(add-hook 'nrepl-mode-hook 'ac-nrepl-setup)
(add-hook 'nrepl-interaction-mode-hook 'ac-nrepl-setup)

(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'nrepl-mode))

;;; Monkey Patch nREPL with better behaviour:

;;; Region discovery fix
(defun nrepl-region-for-expression-at-point ()
  "Return the start and end position of defun at point."
  (when (and (live-paredit-top-level-p)
             (save-excursion
               (ignore-errors (forward-char))
               (live-paredit-top-level-p)))
    (error "Not in a form"))

  (save-excursion
    (save-match-data
      (ignore-errors (live-paredit-forward-down))
      (paredit-forward-up)
      (while (ignore-errors (paredit-forward-up) t))
      (let ((end (point)))
        (backward-sexp)
        (list (point) end)))))

;;; Windows M-. navigation fix
(defun nrepl-jump-to-def (var)
  "Jump to the definition of the var at point."
  (let ((form (format "((clojure.core/juxt
                         (comp (fn [s] (if (clojure.core/re-find #\"[Ww]indows\" (System/getProperty \"os.name\"))
                                           (.replace s \"file:/\" \"file:\")
                                           s))
                               clojure.core/str
                               clojure.java.io/resource :file)
                         (comp clojure.core/str clojure.java.io/file :file) :line)
                        (clojure.core/meta (clojure.core/resolve '%s)))"
                      var)))
    (nrepl-send-string form
                       (nrepl-jump-to-def-handler (current-buffer))
                       (nrepl-current-ns)
                       (nrepl-current-tooling-session))))

(add-to-list 'auto-mode-alist '("\\.cljs?$" . clojure-mode))
(add-to-list 'same-window-buffer-names "*nrepl*")

(when (file-exists-p (expand-file-name "~/Projects/extlib/quicklisp/slime-helper.el"))
  (load (expand-file-name "~/Projects/extlib/quicklisp/slime-helper.el")))

(setq slime-default-lisp 'ccl)
(setq slime-lisp-implementations
      '((ccl ("/usr/local/bin/ccl64") :coding-system utf-8-unix)))

(setq slime-autodoc-use-multiline-p t)

(slime-setup '(slime-repl slime-banner))

(add-hook 'lisp-mode-hook (lambda () (run-hooks 'jp:lisp-coding-hook)))
(add-hook 'slime-repl-mode-hook (lambda () (run-hooks 'jp:interactive-lisp-coding-hook)))

;; start slime automatically when we open a lisp file
(defun jp:start-slime ()
  (unless (slime-connected-p)
    (save-excursion (slime))))

(add-hook 'slime-mode-hook 'jp:start-slime)

(add-to-list 'auto-mode-alist '("\\.cl$" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.lisp$" . lisp-mode))

(require 'ac-slime)
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)

(add-to-list 'ac-modes 'slime-repl-mode)

;; a great lisp coding hook
(defun jp:lisp-coding-defaults ()
  (paredit-mode +1)
  (rainbow-delimiters-mode +1))

(setq jp:lisp-coding-hook 'jp:lisp-coding-defaults)

;; interactive modes don't need whitespace checks
(defun jp:interactive-lisp-coding-defaults ()
  (paredit-mode +1)
  (rainbow-delimiters-mode +1)
  (whitespace-mode -1))

(setq jp:interactive-lisp-coding-hook 'jp:interactive-lisp-coding-defaults)

(defalias 'perl-mode 'cperl-mode)

(eval-after-load 'cperl-mode
  '(progn
     (define-key cperl-mode-map (kbd "RET") 'reindent-then-newline-and-indent)))

(global-set-key (kbd "C-h P") 'perldoc)

(setq
 cperl-tab-always-indent t
 cperl-indent-left-aligned-comments t
 cperl-auto-newline nil
 cperl-close-paren-offset -4
 cperl-indent-level 4
 cperl-indent-parens-as-block t
 cperl-continued-statement-offset 4
 cperl-indent-subs-specially nil
 cperl-invalid-face nil)

(add-to-list 'auto-mode-alist '("\\.pl$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pm$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.pod$p" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.psgi$" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.t$" . cperl-mode))
(add-to-list 'auto-mode-alist '("Makefile\\.PL$" . cperl-mode))

(defun jp:python-mode-defaults ()
  (run-hooks 'jp:prog-mode-hook))

(setq jp:python-mode-hook 'jp:python-mode-defaults)

(add-hook 'python-mode-hook (lambda ()
                              (run-hooks 'jp:python-mode-hook)))

;; correct indentation
(defadvice jp:python-calculate-indentation (around outdent-closing-brackets)
  "Handle lines beginning with a closing bracket and indent them so that
  they line up with the line containing the corresponding opening bracket."
  (save-excursion
    (beginning-of-line)
    (let ((syntax (syntax-ppss)))
      (if (and (not (eq 'string (syntax-ppss-context syntax)))
               (python-continuation-line-p)
               (cadr syntax)
               (skip-syntax-forward "-")
               (looking-at "\\s)"))
          (progn
            (forward-char 1)
            (ignore-errors (backward-sexp))
            (setq ad-return-value (current-indentation)))
        ad-do-it))))

(ad-activate 'jp:python-calculate-indentation)

(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))

(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.thor\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Berksfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.graph$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.knife$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Berksfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Cheffile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Collanderfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Kitchenfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Procfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rantfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Thorfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))

(add-hook 'ruby-mode-hook 'esk-paredit-nonlisp)


(eval-after-load 'ruby-mode
  '(progn
     (defun jp:ruby-mode-defaults ()
       (inf-ruby-setup-keybindings)
       ;; turn off the annoying input echo in irb
       (setq comint-process-echoes t)
       ;;(ruby-block-mode t)
       (ruby-end-mode +1)
       (ruby-tools-mode +1)
       (global-font-lock-mode t)
       (font-lock-mode 1)

       ;; CamelCase aware editing operations
       (subword-mode +1))

     (setq jp:ruby-mode-hook 'jp:ruby-mode-defaults)

     (add-hook 'ruby-mode-hook (lambda ()
                                 (run-hooks 'jp:ruby-mode-hook)))))

(add-to-list 'auto-mode-alist '("\\.scm\\'" . scheme-mode))
(add-to-list 'auto-mode-alist '("\\.rkt\\'" . scheme-mode))

(setq geiser-active-implementations '(racket))

(defun jp:scheme-coding-defaults ()
  (paredit-mode +1)
  (rainbow-delimiters-mode +1))

(setq jp:scheme-coding-hook 'jp:scheme-coding-defaults)

(add-hook 'scheme-mode-hook (lambda () (run-hooks 'jp:scheme-coding-hook)))

(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . json-mode))

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
