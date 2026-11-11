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
(setq column-number-mode t)
;; Line numbers
(dolist (hook '(prog-mode-hook conf-mode-hook text-mode-hook))
  (add-hook hook 'display-line-numbers-mode))
;; Text highlights
(require 'whitespace)
(setq whitespace-style '(face empty lines-tail trailing))
(global-whitespace-mode t)
(setq require-final-newline t)
(setq sentence-end-double-space nil)
(setq-default c-default-style "bsd"
              c-basic-offset 8
              tab-width 8
              indent-tabs-mode t)
(add-hook 'c-mode-common-hook
          (lambda ()
            (setq-local c-basic-offset 8
                        tab-width 8
                        indent-tabs-mode t)))

;; Copy Paste Keybinds
(cua-mode t)

;; Startup command
(dired (expand-file-name "."))
