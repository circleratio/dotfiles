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
  (package-initialize)
  (use-package leaf :ensure t)

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf blackout :ensure t)
    :config
    (leaf-keywords-init)))

(leaf leaf-convert
  :doc "Convert many format to leaf format"
  :ensure t)

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf cus-start:
  :custom '(
            ;; overrides default settings
            (ring-bell-function . 'ignore)
            (menu-bar-mode . nil)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil)
            (create-lockfiles . nil)
            (tab-width . 4)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (ring-bell-function . 'ignore)
            (compilation-scroll-output . t)
            (make-backup-files . nil)
            (auto-save-default . nil)
            (history-delete-duplicates . t)
            (next-line-add-newlines . nil)
            (mouse-drag-and-drop-region . t))
  :config
  (defalias 'yes-or-no-p 'y-or-n-p))

(leaf startup
  :custom
  ((inhibit-startup-screen . t)
   (inhibit-startup-message . t)
   ;; (fancy-splash-image . "~/.emacs.d/Mont-Saint-Michel.png")
   (inhibit-startup-echo-area--message . t)
   (initial-scratch-message . "")))

;;
;; Japanese environment
;;
(leaf character-code
  :config
  (set-language-environment "Japanese")
  (prefer-coding-system 'utf-8)
  (set-locale-environment nil)
  (leaf character-code-for-windows
    :if (eq system-type 'windows-nt)
    :config
    (set-terminal-coding-system 'utf-8)
    (set-keyboard-coding-system 'utf-8)
    (set-buffer-file-coding-system 'utf-8)
    (set-default-coding-systems 'utf-8)))

(leaf ime-windows
  :config
  (leaf tr-ime
    :if (eq system-type 'windows-nt)
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

(leaf ime-linux
  :if (eq system-type 'gnu/linux)
  :config
  (leaf mozc
    :ensure t
    :bind (("C-o" . toggle-input-method)))
  (setq default-input-method "japanese-mozc"))

;;
;; behaviors
;;
(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :ensure t
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :ensure t
  :global-minor-mode t)

(leaf consult
  :doc "Consulting completing-read"
  :ensure t
  :hook (completion-list-mode-hook . consult-preview-at-point-mode)
  :defun consult-line
  :preface
  (defun c/consult-line (&optional at-point)
    "Consult-line uses things-at-point if set C-u prefix."
    (interactive "P")
    (if at-point
        (consult-line (thing-at-point 'symbol))
      (consult-line)))
  :custom ((xref-show-xrefs-function . #'consult-xref)
           (xref-show-definitions-function . #'consult-xref)
           (consult-line-start-from-top . t))
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

         (minibuffer-local-map
          :package emacs
          ("C-r" . consult-history))))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :ensure t
  :custom ((affe-highlight-function . 'orderless-highlight-matches)
           (affe-regexp-function . 'orderless-pattern-compiler))
  :bind (("C-M-s r" . affe-grep)
         ("C-M-s f" . affe-find)))

(leaf avy
  :ensure t
  :bind (("C-;" . avy-goto-char-timer)))

(leaf orderless
  :ensure t
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(leaf orderless
  :doc "Completion style for matching regexps in any order"
  :ensure t
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))))))

(leaf embark-consult
  :doc "Consult integration for Embark"
  :ensure t
  :bind ((minibuffer-mode-map
          :package emacs
          ("M-." . embark-dwim)
          ("C-." . embark-act))))

(leaf corfu
  :doc "COmpletion in Region FUnction"
  :ensure t
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil)) ; manual
  :bind ((corfu-map
          ("C-s" . corfu-insert-separator))))

(leaf cape
  :doc "Completion At Point Extensions"
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(leaf *completion ;; extentions ignored on completion
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

(leaf delsel
  :doc "delete selection when you insert something."
  :global-minor-mode delete-selection-mode)

;(leaf windmove
;  :config
;  (windmove-default-keybindings 'meta) ; move to another windowusing with Meta + arrow keys
;  :bind (("<left>" . windmove-left) ; move to another window only arrow keys
;         ("<right>" . windmove-right)
;         ("<up>" . windmove-up)
;         ("<down>" . windmove-down)))

(leaf multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(leaf shell-pop
  :ensure t
  :custom '((shell-pop-shell-type . '("eshell" "*eshell*" (lambda () (eshell)))))
  :bind (("C-c o" . shell-pop)))

(leaf mwim
  :ensure t
  :bind (("C-a" . mwim-beginning-of-code-or-line)
         ("C-e" . mwim-end-of-code-or-line)))

(leaf company
  :ensure t
  :leaf-defer nil
  :blackout company-mode
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("C-i" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-tooltip-limit         . 12)
           (company-idle-delay            . 0)
           (company-minimum-prefix-length . 1)
           (company-transformers          . '(company-sort-by-occurrence))
           (global-company-mode           . t)
           (company-selection-wrap-around . t)))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :global-minor-mode global-auto-revert-mode)

(leaf simple
  :doc "basic editing commands for Emacs"
  :custom ((kill-read-only-ok . t)
           (kill-whole-line . t)
           (eval-expression-print-length . nil)
           (eval-expression-print-level . nil)))

(leaf savehist
  :doc "Save minibuffer history"
  :custom `((savehist-file . ,(locate-user-emacs-file "savehist")))
  :global-minor-mode t)

(leaf recentf
  :defun
  (recentf-save-list recentf-cleanup)
  :preface
  (leaf shut-up
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
  (leaf recentf-ext :ensure t)
  :hook
  ((after-init-hook . recentf-mode)
   (focus-out-hook  . my:recentf-save-list-silence)
   (focus-out-hook  . my:recentf-cleanup-silence))
  :custom
  `((recentf-max-saved-items . 2000)
    (recentf-auto-cleanup    . 'never)
    (recentf-exclude         . '(".recentf"
                                 "^/tmp\\.*"
                                 "^/private\\.*"
                                 "/TAGS$"
                                 "^#\\.*"
                                 "bookmarks"
                                 ))))

(leaf *delete-file-if-no-contents
  :doc "Remove an empty file when saved"
  :preface
  (defun my:delete-file-if-no-contents ()
    (when (and (buffer-file-name (current-buffer))
               (= (point-min) (point-max)))
      (delete-file
       (buffer-file-name (current-buffer)))))
  :hook
  (after-save-hook . my:delete-file-if-no-contents))

(leaf-keys (("C-h" . delete-backward-char)
            ("C-c d" . insert-current-date-time)
            ("C-c e" . eval-region-string)
            ("C-c r" . replace-string)
            ("C-c #" . comment-or-uncomment-region)
            ("C-c ;" . recentf-open-files)
            ("C-c M-r" . replace-regexp)))

;;
;; appearance
;;
(leaf tab-bar-mode
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
  ((tab-bar-close-last-tab-choice  . nil)
   (tab-bar-close-tab-select       . 'left)
   (tab-bar-history-mode           . nil)
   (tab-bar-new-button-show        . nil)
   (tab-bar-tab-name-function      . 'tab-bar-tab-name-truncated)
   (tab-bar-tab-name-truncated-max . 12))
  :config
  (tab-bar-mode +1))
  
(leaf neotree
  :ensure t
  :commands
  (neotree-show neotree-hide neotree-dir neotree-find)
  :custom (neo-theme . 'nerd2)
  :bind (("C-\\" . neotree-toggle)))

(leaf paren
  :doc "highlight matching parens."
  :global-minor-mode show-paren-mode)

(leaf puni
  :doc "Parentheses Universalistic"
  :ensure t
  :global-minor-mode puni-global-mode
  :bind (("C-c i" . puni-mark-list-around-point)
         ("C-c j" . puni-expand-region)
         ("C-)" . puni-slurp-forward)
         ("C-}" . puni-barf-forward)
         ("M-(" . puni-wrap-round)
         ("M-s" . puni-splice)
         ("M-r" . puni-raise)
         ("M-U" . puni-splice-killing-backward)
         ("M-z" . puni-squeeze))
  :config
  (leaf elec-pair
    :doc "Automatic parenthesis pairing"
    :global-minor-mode electric-pair-mode))

(leaf rainbow-mode
  :ensure t
  :hook
  (mhtml-mode-hook . rainbow-mode)
  (css-mode-hook . rainbow-mode))

(leaf vscode-dark-plus-theme
  :ensure t
  :config
  (load-theme 'vscode-dark-plus t))

(if window-system
    (progn (set-frame-parameter nil 'alpha 95)))

;;
;; development support
;;
(leaf eglot
  :doc "The Emacs Client for LSP servers"
  :hook ((clojure-mode-hook . eglot-ensure))
  :custom ((eldoc-echo-area-use-multiline-p . nil)
           (eglot-connect-timeout . 600)))

(leaf eglot-booster
  :when (executable-find "emacs-lsp-booster")
  :vc ( :url "https://github.com/jdtsmith/eglot-booster")
  :global-minor-mode t)

(leaf markdown-preview-mode
  :custom ((markdown-command . "pandoc")
	   (markdown-use-pandoc-style-yaml-metadata . t)
           (markdown-preview-stylesheets . '("github-markdown.css")))
  :config
  (provide 'markdown-config))

(leaf autoinsert
  :require t
  :doc "Insert templates into new files"
  :tag "builtin"
  :hook
  (find-file-hooks . auto-insert)
  :custom
  (auto-insert-directory . "~/.emacs.d/auto-insert/")
  :config
  (setq auto-insert-alist
        (append '(("\\.py" . "template.py")
                  ("\\.sh" . "template.sh")) auto-insert-alist)))

(leaf *grep-mode
  :custom ((grep-command . "grep -nH ")))

(leaf flymake
  :ensure t
  :init
  (leaf flymake-python-pyflakes :ensure t)
  (leaf flymake-cursor :ensure t)
  (leaf flymake-easy :ensure t)
  :hook (python-mode-hook . flymake-python-pyflakes-load))

(leaf yasnippet
  :ensure t
  :init (yas-global-mode t))

(leaf company-jedi
  :ensure t
  :custom '((jedi:complete-on-dot . t)
            (jedi:use-shortcuts . t))
  :hook
  (python-mode-hook . jedi:setup)
  :config
  (add-to-list 'company-backends 'company-jedi))

(leaf powershell :ensure t)
(leaf markdown-mode :ensure t)

(leaf gptel
  :ensure t
  :config
  :defvar ((gptel-model)
           (gptel-backend))
  ;; Gemini
  :setq ((gptel-model quote gemini-2.5-flash))
  :config
  (setq gptel-backend (gptel-make-gemini "Gemini"
                        :key (getenv "API_KEY_GEMINI")
                        :stream t))
  ;; Perplexity
  ;; :setq ((gptel-model quote sonar))
  ;; :config
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
