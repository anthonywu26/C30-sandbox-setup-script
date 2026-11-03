;;; -*- lexical-binding: t; -*-

;; Redirect backups and autosaves
(defvar my/emacs-temp-directory
  (expand-file-name "emacs/" temporary-file-directory))
(defvar my/emacs-auto-save-directory
  (expand-file-name "auto-save/" my/emacs-temp-directory))
(defvar my/emacs-backup-directory
  (expand-file-name "backups/" my/emacs-temp-directory))
(make-directory my/emacs-auto-save-directory t)
(make-directory my/emacs-backup-directory t)
(setq auto-save-file-name-transforms
      `((".*" ,my/emacs-auto-save-directory t)))
(setq backup-directory-alist
      `(("." . ,my/emacs-backup-directory)))
(setq backup-by-copying t)
;; Disable lockfiles.
(setq create-lockfiles nil)

;; GUI
;; Tweaks
(setq inhibit-startup-screen t)
(column-number-mode)
;; Line numbers
(dolist (hook '(prog-mode-hook conf-mode-hook text-mode-hook))
  (add-hook hook 'display-line-numbers-mode))
;; Text highlights
(setq show-paren-delay 0)
(show-paren-mode)
(dolist (hook '(conf-mode-hook prog-mode-hook text-mode-hook))
  (add-hook hook (lambda () (setq show-trailing-whitespace t))))
(setq-default indicate-empty-lines t)
(setq-default indicate-buffer-boundaries 'left)
(setq require-final-newline t)
(setq sentence-end-double-space nil)
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)

;; View undo history
;; (use-package vundo
;;  :bind ("C-x u" . vundo))

;; Startup command
(dired (expand-file-name "."))
