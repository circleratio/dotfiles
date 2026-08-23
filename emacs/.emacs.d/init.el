;;
;; init.el
;; -*- coding: utf-8; lexical-binding: t -*-

;; kick out proxy settings to remove dependency on an environment
(let ((proxy-settings "~/.emacs.d/url-proxy-services.el"))
  (if (file-exists-p proxy-settings)
      (load-file proxy-settings)))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")))
  ;; Workaround for a Windows-only bug where package.el passes a
  ;; drive-letter path (e.g. "c:/...") as gpg's --homedir, and the
  ;; MSYS2-built gpg misreads it as relative, concatenating it onto
  ;; its own bin directory. Converting to Unix-style ("/c/...") avoids
  ;; the misparse. See https://dev.gnupg.org/T7112
  (when (eq system-type 'windows-nt)
    (let ((dir (expand-file-name "elpa/gnupg" user-emacs-directory)))
      (when (string-match "\\`\\([a-zA-Z]\\):" dir)
        (setq package-gnupghome-dir
              (concat "/" (downcase (match-string 1 dir))
                      (substring dir (match-end 0)))))))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package)
  ;; :custom defaults to applying values via a synthetic "use-package" custom
  ;; theme (`enable-theme'), which mishandles defcustoms with side-effecting
  ;; :set functions (e.g. menu-bar-mode/tool-bar-mode/scroll-bar-mode),
  ;; raising errors such as "Wrong type argument: listp, t".  Use plain
  ;; `customize-set-variable' instead, matching leaf's original behavior.
  (setq use-package-use-theme nil)
  ;; Emacs < 30 does not ship :vc support in use-package; add it via vc-use-package.
  (unless (memq :vc use-package-keywords)
    (unless (package-installed-p 'vc-use-package)
      (package-install 'vc-use-package))
    (require 'vc-use-package)))

(use-package blackout :ensure t)

(use-package cus-edit
  ;; tools for customizing Emacs and Lisp packages
  :custom (custom-file (locate-user-emacs-file "custom.el")))

(use-package cus-start
  :custom
  (;; overrides default settings
   (ring-bell-function 'ignore)
   (menu-bar-mode nil)
   (tool-bar-mode nil)
   (scroll-bar-mode nil)
   (indent-tabs-mode nil)
   (create-lockfiles nil)
   (tab-width 4)
   (history-length 1000)
   (history-delete-duplicates t)
   (bidi-display-reordering nil)
   (ring-bell-function 'ignore)
   (compilation-scroll-output t)
   (make-backup-files nil)
   (auto-save-default nil)
   (history-delete-duplicates t)
   (next-line-add-newlines nil)
   (mouse-drag-and-drop-region t))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p))

(use-package startup
  :no-require t
  :custom
  ((inhibit-startup-screen t)
   (inhibit-startup-message t)
   ;; (fancy-splash-image . "~/.emacs.d/Mont-Saint-Michel.png")
   (inhibit-startup-echo-area--message t)
   (initial-scratch-message "")))

;;
;; Japanese environment
;;
(use-package character-code
  :no-require t
  :config
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-locale-environment nil)
  (use-package character-code-for-windows
    :no-require t
    :if (eq system-type 'windows-nt)
    :config
    (set-terminal-coding-system 'utf-8)
    (set-keyboard-coding-system 'utf-8)
    (set-buffer-file-coding-system 'utf-8)
    (set-default-coding-systems 'utf-8)))

(use-package ime-windows
  :no-require t
  :if (eq system-type 'windows-nt)
  :config
  (use-package tr-ime
    ;; NOTE: :ensure ignores this block's own :if (use-package processes
    ;; :ensure before :if), so the Windows guard lives on the outer
    ;; `ime-windows' block instead, which is safe to nest inside.
    :ensure t
    :init
    (setq default-input-method "W32-IME")
    (setq-default w32-ime-mode-line-state-indicator "[--]")
    (setq w32-ime-mode-line-state-indicator-list '("[--]" "[あ]" "[--]"))
    (tr-ime-standard-install)
    (w32-ime-initialize)
    (wrap-function-to-control-ime 'universal-argument t nil)
    (wrap-function-to-control-ime 'read-string nil nil)
    (wrap-function-to-control-ime 'read-char nil nil)
    ;;(wrap-function-to-control-ime 'read-from-minibuffer nil nil)
    (wrap-function-to-control-ime 'y-or-n-p nil nil)
    (wrap-function-to-control-ime 'yes-or-no-p nil nil)
    (wrap-function-to-control-ime 'map-y-or-n-p nil nil)
    (wrap-function-to-control-ime 'register-read-with-preview nil nil)
    ;; stateless control of IME
    (defun off-input-method ()
      (interactive)
      (deactivate-input-method))
    (defun on-input-method ()
      (interactive)
      (activate-input-method default-input-method))
    :bind (("C-o" . toggle-input-method)
           ("<f5>" . on-input-method)
           ("<f6>" . off-input-method))))

(use-package ime-linux
  :no-require t
  :if (eq system-type 'gnu/linux)
  :config
  (use-package mozc
    :ensure t
    :bind (("C-o" . toggle-input-method)))
  (setq default-input-method "japanese-mozc"))

(use-package migemo
  ;; Japanese incremental search through romanized text
  :ensure t
  :demand t
  :custom
  ((migemo-command "cmigemo")
   (migemo-options '("-q" "--emacs"))
   (migemo-user-dictionary nil)
   (migemo-regex-dictionary nil)
   (migemo-coding-system 'utf-8-unix))
  :config
  (setq migemo-dictionary
        (cond ((eq system-type 'windows-nt)
               (concat (file-name-directory (executable-find "cmigemo")) "dict/utf-8/migemo-dict"))
              ((eq system-type 'gnu/linux)  "/usr/share/cmigemo/utf-8/migemo-dict")))
  (migemo-init))

;;
;; behaviors
;;
(use-package vertico
  ;; VERTical Interactive COmpletion
  :ensure t
  :demand t
  :config
  (vertico-mode 1))

(use-package marginalia
  ;; Enrich existing commands with completion annotations
  :ensure t
  :demand t
  :config
  (marginalia-mode 1))

(use-package consult
  ;; Consulting completing-read
  :ensure t
  :hook (completion-list-mode-hook . consult-preview-at-point-mode)
  :functions consult-line
  :preface
  (defun c/consult-line (&optional at-point)
    "Consult-line uses things-at-point if set C-u prefix."
    (interactive "P")
    (if at-point
        (consult-line (thing-at-point 'symbol))
      (consult-line)))
  :custom ((xref-show-xrefs-function #'consult-xref)
           (xref-show-definitions-function #'consult-xref)
           (consult-line-start-from-top t))
  :bind (;; C-c bindings (mode-specific-map)
         ([remap switch-to-buffer] . consult-buffer) ; C-x b
         ([remap project-switch-to-buffer] . consult-project-buffer) ; C-x p b

         ;; M-g bindings (goto-map)
         ([remap goto-line] . consult-goto-line)    ; M-g g
         ([remap imenu] . consult-imenu)            ; M-g i
         ("M-g f" . consult-flymake)

         ;; C-M-s bindings
         ("C-s" . c/consult-line)       ; isearch-forward
         ("C-M-s" . nil)                ; isearch-forward-regexp
         ("C-M-s s" . isearch-forward)
         ("C-M-s C-s" . isearch-forward-regexp)
         ("C-M-s r" . consult-ripgrep)

         :map minibuffer-local-map
         ("C-r" . consult-history)))

(use-package affe
  ;; Asynchronous Fuzzy Finder for Emacs
  :ensure t
  :custom ((affe-highlight-function 'orderless-highlight-matches)
           (affe-regexp-function 'orderless-pattern-compiler))
  :bind (("C-M-s r" . affe-grep)
         ("C-M-s f" . affe-find)))

(use-package avy
  :ensure t
  :bind (("C-;" . avy-goto-char-timer)))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package orderless
  ;; Completion style for matching regexps in any order
  :ensure t
  :custom ((completion-styles '(orderless))
           (completion-category-defaults nil)
           (completion-category-overrides '((file (styles partial-completion))))))

(use-package embark-consult
  ;; Consult integration for Embark
  :ensure t
  :bind (:map minibuffer-mode-map
         ("M-." . embark-dwim)
         ("C-." . embark-act)))

(use-package corfu
  ;; COmpletion in Region FUnction
  :ensure t
  :demand t
  :custom ((corfu-auto t)
           (corfu-auto-delay 0)
           (corfu-auto-prefix 1)
           (corfu-popupinfo-delay nil)) ; manual
  :bind (:map corfu-map
         ("C-s" . corfu-insert-separator))
  :config
  (global-corfu-mode 1)
  (corfu-popupinfo-mode 1))

(use-package cape
  ;; Completion At Point Extensions
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package *completion ;; extentions ignored on completion
  :no-require t
  :init
  (cl-loop for ext in
           '(;; TeX
             ".aux"
             ".dvi"
             ".nav"
             ".out"
             ".snm"
             ".toc"
             ".vrb"
             )
           do (add-to-list 'completion-ignored-extensions ext)))

(use-package delsel
  ;; delete selection when you insert something.
  :demand t
  :config
  (delete-selection-mode 1))

;(use-package windmove
;  :config
;  (windmove-default-keybindings 'meta) ; move to another windowusing with Meta + arrow keys
;  :bind (("<left>" . windmove-left) ; move to another window only arrow keys
;         ("<right>" . windmove-right)
;         ("<up>" . windmove-up)
;         ("<down>" . windmove-down)))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package shell-pop
  :ensure t
  :custom (shell-pop-shell-type '("eshell" "*eshell*" (lambda () (eshell))))
  :bind (("C-c o" . shell-pop)))

(use-package mwim
  :ensure t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
         ("C-e" . mwim-end-of-code-or-line)))

(use-package company
  :ensure t
  :demand t
  :blackout company-mode
  :bind (:map company-active-map
         ("M-n" . nil)
         ("M-p" . nil)
         ("C-s" . company-filter-candidates)
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("C-i" . company-complete-selection)
         :map company-search-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous))
  :custom ((company-tooltip-limit         12)
           (company-idle-delay            0)
           (company-minimum-prefix-length 1)
           (company-transformers          '(company-sort-by-occurrence))
           (global-company-mode           t)
           (company-selection-wrap-around t)))

(use-package autorevert
  ;; revert buffers when files on disk change
  :demand t
  :config
  (global-auto-revert-mode 1))

(use-package simple
  ;; basic editing commands for Emacs
  :custom ((kill-read-only-ok t)
           (kill-whole-line t)
           (eval-expression-print-length nil)
           (eval-expression-print-level nil)))

(use-package savehist
  ;; Save minibuffer history
  :demand t
  :custom (savehist-file (locate-user-emacs-file "savehist"))
  :config
  (savehist-mode 1))

(use-package recentf
  :functions (recentf-save-list recentf-cleanup)
  :preface
  (use-package shut-up
    :ensure t
    :init
    (defvar shut-up-ignore t))
  ;;
  (defun my:recentf-save-list-silence ()
    "Shut up"
    (interactive)
    (let ((message-log-max nil))
      (shut-up (recentf-save-list)))
    (message ""))
  ;;
  (defun my:recentf-cleanup-silence ()
    "Shut up"
    (interactive)
    (let ((message-log-max nil))
      (shut-up (recentf-cleanup)))
    (message ""))
  ;;
  :init
  (use-package recentf-ext :ensure t)
  :hook
  ((after-init-hook . recentf-mode)
   (focus-out-hook  . my:recentf-save-list-silence)
   (focus-out-hook  . my:recentf-cleanup-silence))
  :custom
  ((recentf-max-saved-items 2000)
   (recentf-auto-cleanup    'never)
   (recentf-exclude         '(".recentf"
                               "^/tmp\\.*"
                               "^/private\\.*"
                               "/TAGS$"
                               "^#\\.*"
                               "bookmarks"
                               ))))

(use-package *delete-file-if-no-contents
  ;; Remove an empty file when saved
  :no-require t
  :preface
  (defun my:delete-file-if-no-contents ()
    (when (and (buffer-file-name (current-buffer))
               (= (point-min) (point-max)))
      (delete-file
       (buffer-file-name (current-buffer)))))
  :hook
  (after-save-hook . my:delete-file-if-no-contents))

(bind-keys ("C-h" . delete-backward-char)
           ("C-c b" . describe-bindings)
           ("C-c d" . insert-current-date-time)
           ("C-c e" . eval-region-string)
           ("C-c r" . replace-string)
           ("C-c #" . comment-or-uncomment-region)
           ("C-c ;" . recentf-open-files)
           ("C-c M-r" . replace-regexp)
           ("M-s" . isearch-forward))

;;
;; appearance
;;
(use-package tab-bar
  :init
  (defvar my:ctrl-z-map (make-sparse-keymap)
    "A keymap to use C-z as prefix.")
  (defalias 'my:ctrl-z-prefix my:ctrl-z-map)
  (define-key global-map    (kbd "C-z") 'my:ctrl-z-prefix)
  (define-key my:ctrl-z-map (kbd "c")   'tab-new)
  (define-key my:ctrl-z-map (kbd "C-c") 'tab-new)
  (define-key my:ctrl-z-map (kbd "k")   'tab-close)
  (define-key my:ctrl-z-map (kbd "C-k") 'tab-close)
  (define-key my:ctrl-z-map (kbd "n")   'tab-next)
  (define-key my:ctrl-z-map (kbd "C-n") 'tab-next)
  (define-key my:ctrl-z-map (kbd "p")   'tab-previous)
  (define-key my:ctrl-z-map (kbd "C-p") 'tab-previous)
  :custom
  ((tab-bar-close-last-tab-choice  nil)
   (tab-bar-close-tab-select       'left)
   (tab-bar-history-mode           nil)
   (tab-bar-new-button-show        nil)
   (tab-bar-tab-name-function      'tab-bar-tab-name-truncated)
   (tab-bar-tab-name-truncated-max 12))
  :config
  (tab-bar-mode +1))

(use-package neotree
  :ensure t
  :commands
  (neotree-show neotree-hide neotree-dir neotree-find)
  :custom (neo-theme 'nerd2)
  :bind (("C-\\" . neotree-toggle)))

(use-package paren
  ;; highlight matching parens.
  :demand t
  :config
  (show-paren-mode 1))

(use-package puni
  ;; Parentheses Universalistic
  :ensure t
  :demand t
  :bind (("C-c i" . puni-mark-list-around-point)
         ("C-c j" . puni-expand-region)
         ("C-)" . puni-slurp-forward)
         ("C-}" . puni-barf-forward)
         ("M-(" . puni-wrap-round)
         ;;("M-s" . puni-splice)
         ("M-r" . puni-raise)
         ("M-U" . puni-splice-killing-backward)
         ("M-z" . puni-squeeze))
  :config
  (puni-global-mode 1)
  (use-package elec-pair
    ;; Automatic parenthesis pairing
    :demand t
    :config
    (electric-pair-mode 1)))

(use-package rainbow-mode
  :ensure t
  :hook
  ((mhtml-mode-hook . rainbow-mode)
   (css-mode-hook . rainbow-mode)))

(use-package vscode-dark-plus-theme
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t))

(if window-system
    (progn (set-frame-parameter nil 'alpha 95)))

;;
;; development support
;;
(use-package eglot
  ;; The Emacs Client for LSP servers
  :hook ((clojure-mode-hook . eglot-ensure))
  :custom ((eldoc-echo-area-use-multiline-p nil)
           (eglot-connect-timeout 600)))

(use-package eglot-booster
  :when (executable-find "emacs-lsp-booster")
  :vc ( :url "https://github.com/jdtsmith/eglot-booster")
  :demand t
  :config
  (eglot-booster-mode 1))

(use-package markdown-preview-mode
  :no-require t
  :custom ((markdown-command "pandoc")
	   (markdown-use-pandoc-style-yaml-metadata t)
           (markdown-preview-stylesheets '("github-markdown.css")))
  :config
  (provide 'markdown-config))

(use-package autoinsert
  :demand t
  ;; Insert templates into new files
  :hook
  (find-file-hooks . auto-insert)
  :custom
  (auto-insert-directory "~/.emacs.d/auto-insert/")
  :config
  (setq auto-insert-alist
        (append '(("\\.py" . "template.py")
                  ("\\.sh" . "template.sh")) auto-insert-alist)))

(use-package *grep-mode
  :no-require t
  :custom (grep-command "grep -nH "))

(use-package flymake
  :ensure t
  :init
  (use-package flymake-python-pyflakes :ensure t)
  (use-package flymake-cursor :ensure t)
  (use-package flymake-easy :ensure t)
  :hook (python-mode-hook . flymake-python-pyflakes-load))

(use-package yasnippet
  :ensure t
  :init (yas-global-mode t))

(use-package company-jedi
  :ensure t
  :custom ((jedi:complete-on-dot t)
           (jedi:use-shortcuts t))
  :hook
  (python-mode-hook . jedi:setup)
  :config
  (add-to-list 'company-backends 'company-jedi))

(use-package powershell :ensure t)
(use-package markdown-mode
  :ensure t
  :bind (:map markdown-mode-map
         ("C-c C-i" . markdown-follow-thing-at-point)))

(use-package gptel
  :ensure t
  :defines (gptel-model gptel-backend)
  ;; Gemini
  :init
  (setq gptel-model 'gemini-2.5-flash)
  :config
  (setq gptel-backend (gptel-make-gemini "Gemini"
                        :key (getenv "API_KEY_GEMINI")
                        :stream t))
  ;; Perplexity
  ;; (setq gptel-model 'sonar)
  ;; (setq gptel-backend (gptel-make-perplexity "Perplexity"
  ;;                      :key (getenv "API_KEY_PERPLEXITY")
  ;;                      :stream t))
  )

(provide 'init)

;;
;; Settings depending on OS and window systems
;;

;; [Windows] chnage character encoding of arguments given to subprocesses to cp932
(require 'cl-lib)
(if (eq system-type 'windows-nt)
    (cl-loop for (func args-pos) in '((call-process        4)
                                      (call-process-region 6)
                                      (start-process       3))
             do (eval `(advice-add ',func
                                   :around (lambda (orig-fun &rest args)
                                             (setf (nthcdr ,args-pos args)
                                                   (mapcar (lambda (arg)
                                                             (if (multibyte-string-p arg)
                                                                 (encode-coding-string arg 'cp932)
                                                               arg))
                                                           (nthcdr ,args-pos args)))
                                             (apply orig-fun args))
                                   '((depth . 99))))))

(defun explorer-invoke()
  "Invoke Explorer on Windows systems"
  (interactive)
  (if (eq system-type 'windows-nt)
      (shell-command "explorer ."))
  (message "This OS is %s. This function works on on Windows " system-type))

(defvar current-date-time-format "%Y-%m-%d %H:%M:%S"
  "Format of date to insert with `insert-current-date-time' func. See help of `format-time-string' for possible replacements")

(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-date-time-format (current-time)))
  (insert "\n"))

(defun eval-region-string (beg end)
  "Evaluate the S-expression written as a string in the region and insert the result."
  (interactive "r")
  (let ((region-string (buffer-substring-no-properties beg end))
        (evaluated-result nil))
    (condition-case err
        (progn
          (let ((s-exp (read region-string)))
            (setq evaluated-result (eval s-exp))))
      (error (message "Error evaluating S-expression: %s" err)
             (setq evaluated-result region-string)))
    (delete-region beg end)
    (insert (format "%s" evaluated-result))))

(setq search-engine-alist
      '(("Google" . "https://www.google.com/search?q=")
        ("Weblio" . "https://www.weblio.jp/content/")))

(defun search-region (beginning end)
  "Search the contents of the region using a search engine."
  (interactive "r")
  (let* ((options (mapcar #'car search-engine-alist))
         (prompt "Select a seach engine: ")
         (choice (completing-read prompt options nil t))
         (search-term (buffer-substring beginning end))
         (url (concat (cdr (assoc choice search-engine-alist)) (url-hexify-string search-term))))
    (browse-url url)))

;; exec chmod +x when a file begins with '#!'
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;;
;; Personal customization
;;
(add-to-list 'load-path "~/.emacs.d/site-lisp")

(require 'dnd)
(defun dnd-open-local-file (uri action)
  (let ((f (dnd-get-local-file-name uri t)))
    (cond
     ((eq major-mode 'markdown-mode)
      (insert (concat "[](" f ")")))
     (t (find-file f)))))

(let ((personal-settings "~/.emacs.d/site-lisp/personal.el"))
  (if (file-exists-p personal-settings)
      (load-file personal-settings)))

(setq default-frame-alist
     (append (list
             '(font . "UDEV Gothic JPDOC-16"))
             default-frame-alist))

(setq initial-frame-alist
     (append (list
              '(width . 80)
              '(height . 30)
              '(top . 4)
              '(left . 1))))

(cd "~")

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
