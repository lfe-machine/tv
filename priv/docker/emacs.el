(setq byte-compile-warnings '(cl-functions))
(require 'cl)
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/")
	     t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/")
             t)
(package-initialize)

;;; Bootstrap
(defvar required-packages '(use-package
                            spacemacs-theme
                            spaceline
                            treemacs
                            org
                            markdown-mode))

(defun packages-installed-p ()
  (loop for p in required-packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(unless (packages-installed-p)
  ;; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ;; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(setq-default indent-tabs-mode nil)

;; LFE mode.
(defvar lfe-dir "/opt/erlang/lfe/emacs")
(setq load-path (cons lfe-dir load-path))
(require 'lfe-start)

;; Window arragement saving
(desktop-save-mode 1)

;; Command history
(savehist-mode 1)

;; Winner mode
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; Theme
(load-theme 'spacemacs-dark t)

(use-package spaceline
  :demand t
  :init
  (setq powerline-default-separator 'arrow-fade)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . gfm-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(setq markdown-fontify-code-blocks-natively t)
(setq markdown-enable-wiki-links t)
