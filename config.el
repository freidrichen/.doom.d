;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Magnus Sandén"
      user-mail-address "thefreid@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Fira Code" :size 15 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "Cantarell" :size 15))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Documents/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;;; -- My own stuff --

(map! :leader
      :desc "Which function mode" "t W" 'which-function-mode
      :desc "Search current project" "/" '+default/search-project)

(after! magit
  (map! :leader
        :desc "File history" "g h" 'magit-log-buffer-file
        (:prefix-map ("g m" . "Merge conflict resolution")
         :desc "Keep current" "." 'smerge-keep-current
         :desc "Keep mine" "m" 'smerge-keep-mine
         :desc "Keep other" "o" 'smerge-keep-other
         :desc "Keep all" "a" 'smerge-keep-all
         :desc "Next conflict" "n" 'smerge-next
         :desc "Previous conflict" "p" 'smerge-prev)))

(after! flycheck
  (map! :leader
        :desc "Previous error" "c p" 'flycheck-previous-error
        :desc "Next error" "c n" 'flycheck-next-error))

(after! (flycheck python)
  (setq-default flycheck-disabled-checkers '(python-pylint python-mypy)))

(after! evil
  (map! :n "Q" 'evil-fill-and-move)

  ;; Movements in evil-mode should be by symbol, not by word
  ;; TODO: Doesn't work so well in xml
  (defalias 'forward-evil-word 'forward-evil-symbol))

;; Customize TODO states in org-mode
(after! org
  (setq! org-todo-keywords
         '((sequence "TODO(t)" "NEXT(n)" "PROG(p)" "INTR(i)" "|" "DONE(d)" "WAIT(w)")))

  (setq! org-capture-templates
      '(("w" "Work task" entry (file+headline "work.org" "Inbox")
         "* TODO %?\n  %i\n")
        ("p" "Private entry" entry (file+headline "private.org" "Inbox")
         "* %?\n  %i\n")))

  ;; Exclude archive files
  ;; (setq! org-agenda-files
  ;;     (f-files org-directory
  ;;              (lambda (file) (not (s-matches? "-archive" file)))))

  ;; Show the daily agenda by default.
  (setq! org-agenda-span 'day)

  ;; Hide tasks that are scheduled in the future.
  (setq! org-agenda-todo-ignore-scheduled 'future)

  ;; Hide the deadline prewarning prior to scheduled date.
  (setq! org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled)

  ;; Customized view for the daily workflow.
  (setq! org-agenda-custom-commands
      '(("w" "Work agenda / TODOs"
         ((agenda "" nil)
          (todo "INTR" nil)
          (todo "PROG" nil)
          (todo "NEXT" nil))
         ((org-agenda-files
           '("~/Documents/org/work.org"))))
        ("p" "Private agenda / TODOs"
         ((agenda "" nil)
          (todo "INTR" nil)
          (todo "PROG" nil)
          (todo "NEXT" nil))
         ((org-agenda-files
           '("~/Documents/org/private.org"))))
        ))
)

;; Hide pyenv's default modeline string
(after! pyenv-mode
  (setq! pyenv-mode-mode-line-format ""))

;; Customize modeline
(after! doom-modeline
  ;; Change the angry red color of modified buffer indicator (not needed with +light)
  (custom-set-faces!
    '(doom-modeline-buffer-modified :foreground "orange"))

  ;; Only show non-default buffer encodings
  ;; Credit: https://tecosaur.github.io/emacs-config/config.html#theme-modeline
  (defun doom-modeline-conditional-buffer-encoding ()
    "We expect the encoding to be LF UTF-8, so only show the modeline when this is not the case"
    (setq-local doom-modeline-buffer-encoding
                (unless (or (eq buffer-file-coding-system 'utf-8-unix)
                            (eq buffer-file-coding-system 'utf-8)))))
  (add-hook! 'after-change-major-mode-hook #'doom-modeline-conditional-buffer-encoding)

  ;; Hide major modes in the main modeline (the major mode icon is enough)
  (doom-modeline-def-modeline 'main  ; Used in normal buffers
    '(bar workspace-name window-number modals matches buffer-info remote-host buffer-position parrot selection-info)
    '(misc-info battery irc mu4e gnus github debug minor-modes input-method buffer-encoding process vcs checker))
  (doom-modeline-def-modeline 'vcs  ; Used in magit buffers
    '(bar window-number modals matches buffer-info buffer-position parrot selection-info)
    '(misc-info battery irc mu4e gnus github debug minor-modes buffer-encoding process))

  ;; Show icon for major mode
  (setq! doom-modeline-major-mode-icon t)
)

;; Don't warn me about narrowing buffers
(put 'narrow-to-region 'disabled nil)


;;; -- End my own stuff --


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#FFFBEA" "#ff6c6b" "#98be65" "#ECBE7B" "#51afef" "#c678dd" "#46D9FF" "#bbc2cf"])
 '(custom-safe-themes
   (quote
    ("76bfa9318742342233d8b0b42e824130b3a50dcc732866ff8e47366aed69de11" "e2acbf379aa541e07373395b977a99c878c30f20c3761aac23e9223345526bcc" "9efb2d10bfb38fe7cd4586afb3e644d082cbcdb7435f3d1e8dd9413cbe5e61fc" "2f1518e906a8b60fac943d02ad415f1d8b3933a5a7f75e307e6e9a26ef5bf570" "0cb1b0ea66b145ad9b9e34c850ea8e842c4c4c83abe04e37455a1ef4cc5b8791" default)))
 '(fci-rule-color "#5B6268")
 '(jdee-db-active-breakpoint-face-colors (cons "#1B2229" "#51afef"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#1B2229" "#98be65"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#1B2229" "#3f444a"))
 '(objed-cursor-color "#ff6c6b")
 '(pdf-view-midnight-colors (cons "#bbc2cf" "#282c34"))
 '(rustic-ansi-faces
   ["#282c34" "#ff6c6b" "#98be65" "#ECBE7B" "#51afef" "#c678dd" "#46D9FF" "#bbc2cf"])
 '(size-indication-mode nil)
 '(vc-annotate-background "#282c34")
 '(vc-annotate-color-map
   (list
    (cons 20 "#98be65")
    (cons 40 "#b4be6c")
    (cons 60 "#d0be73")
    (cons 80 "#ECBE7B")
    (cons 100 "#e6ab6a")
    (cons 120 "#e09859")
    (cons 140 "#da8548")
    (cons 160 "#d38079")
    (cons 180 "#cc7cab")
    (cons 200 "#c678dd")
    (cons 220 "#d974b7")
    (cons 240 "#ec7091")
    (cons 260 "#ff6c6b")
    (cons 280 "#cf6162")
    (cons 300 "#9f585a")
    (cons 320 "#6f4e52")
    (cons 340 "#5B6268")
    (cons 360 "#5B6268")))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doom-modeline-buffer-modified ((t (:foreground "orange")))))
