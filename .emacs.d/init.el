;; MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/org-contrib") t)
(package-initialize)
(setq warning-minimum-level :error)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(lsp-scheme lsp-latex gforth gforth-mode robe ruby-end haskell-mode geiser go-mode elpy cider lua-mode fennel-mode cargo rust-mode tex-site auctex AUCTeX org-bookmark-heading org-bookmark org-web-tools org-sticky-header helm-org-recent-headings helm-org-rifle org-super-agenda ox-pandoc org-page org-bullets org-protocol-capture org-protocol helm f org-roam org-present emojify selectric-mode treemacs minimap beacon sly consult marginalia vertico magit use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Update package list from MELPA
(unless package-archive-contents
  (package-refresh-contents))

;; Get use package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; Nice minimal auto complete
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; Prioritize recent files in autocomplete
(use-package savehist
  :init
  (savehist-mode))

;; Help Vertico by adding metadata
(use-package marginalia
  :after vertico
  :ensure t
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

;; This is huge... TODO Move to external file.
;; Provide additional completions
(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
  :ensure t
)

;; SLY IDE
(use-package sly
  :ensure t)

;; Magit
(use-package magit
  :ensure t)

;; Beacon
(use-package beacon
  :ensure t)
(beacon-mode 1)

;; Minimap
(use-package minimap
  :ensure t)
(setq minimap-window-location 'right)
(minimap-mode 1)

;; Projectile
(use-package projectile
  :ensure t)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(setq projectile-completion-system 'default)

;; Treemacs
(use-package treemacs
  :ensure t)

;; Selectric
(unless (string-equal system-type "windows-nt")
  (use-package selectric-mode
    :ensure t)
  (selectric-mode 1))

;; Emoji
(use-package emojify
  :ensure t
  :hook (after-init . global-emojify-mode))

;; High Contrast Dark Mode
(load-theme 'modus-vivendi t)

;; Remove Menu Bar
(menu-bar-mode -1)

;; Remove Tool Bar
(tool-bar-mode -1)

;; Remove scroll bars
(scroll-bar-mode -1)

;; Show Line Numbers
;TODO Make this a hook when new windows are created by the user, not the sidemap ;(display-line-numbers-mode 1)
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq visible-bell t)

(use-package s
  :ensure t)

(use-package f
  :ensure t)

(use-package dash
  :ensure t)

(use-package helm
  :ensure t)

(use-package org
  :ensure t)

;; (use-package org-protocol
;;   :ensure t)

;; (use-package org-protocol-capture
;;   :ensure t)

(use-package org-present
  :ensure t)

(use-package org-present
  :ensure t)

(use-package org-roam
  :ensure t)

(use-package org-bullets
  :ensure t)

(use-package org-mouse) ; Built in to org

(use-package org-page
  :ensure t)

(use-package ox-pandoc
  :ensure t)

(use-package org-super-agenda
  :ensure t)

(use-package helm-org-rifle
  :ensure t)

(use-package helm-org-recent-headings
  :ensure t)

(use-package org-sticky-header
  :ensure t)

(use-package org-web-tools
  :ensure t)

;; (use-package org-bookmark
;;   :ensure t)

(use-package org-bookmark-heading
  :ensure t)

(require 'tex-site)
(recentf-mode 1)
(setq history-length 25)
(savehist-mode 1)
(save-place-mode 1)

(use-package rust-mode
  :ensure t)
(setq rust-format-on-save t)
(use-package cargo
  :ensure t)

(use-package lua-mode
  :ensure t)

(use-package fennel-mode
  :ensure t)
(add-to-list 'auto-mode-alist '("\\.fnl\\'" . fennel-mode))
(use-package antifennel) ; Included in fennel-mode package
(add-hook 'lua-mode-hook 'antifennel-mode) ; C-c C-f in lua mode to convert to fennel

(use-package cider
  :ensure t)

(use-package geiser
  :ensure t)

(use-package elpy
  :ensure t
  :hook (after-init . elpy-enable))

(use-package go-mode
  :ensure t)

(use-package ruby-end
  :ensure t) ; run along builtin ruby mode to automatically insert end statements
(use-package robe
  :ensure t)
(add-hook 'ruby-mode-hook 'robe-mode)

(use-package haskell-mode
  :ensure t)

(use-package corfu
  :ensure t)

(use-package lsp-latex
  :ensure t)

(use-package lsp-scheme
  :ensure t)

(autoload 'forth-mode "gforth.el")
(autoload 'forth-block-mode "gforth.el")
(add-to-list 'auto-mode-alist '("\\.fs$" . forth-mode))
