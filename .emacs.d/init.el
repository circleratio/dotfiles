;;; init.el --- init.el  -*- lexical-binding: t; -*-

;; kick out proxy settings to remove dependency on an environment 
(let ((proxy-settings "~/.emacs.d/url-proxy-services.el"))
  (if (file-exists-p proxy-settings)
      (load-file proxy-settings)))

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)
    :config
    (leaf-keywords-init)))

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

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
            ;; settings not in the default
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

;; Japanese environment
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

;; behaviors
(leaf consult
  :ensure t
  :bind (("C-s" . consult-line)))

(leaf vertico
  :url "https://github.com/minad/vertico"
  :ensure t
  :init
  (vertico-mode))

(leaf orderless
  :ensure t
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

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

;; remove an empty file when saved
(leaf *delete-file-if-no-contents
  :preface
  (defun my:delete-file-if-no-contents ()
    (when (and (buffer-file-name (current-buffer))
               (= (point-min) (point-max)))
      (delete-file
       (buffer-file-name (current-buffer)))))
  :hook
  (after-save-hook . my:delete-file-if-no-contents))

(leaf-keys (("C-h" . delete-backward-char)
            ("C-c ;" . recentf-open-files)
            ("C-c r" . replace-string)
            ("C-c M-r" . replace-regexp)))

;; appearance
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
  :tag "builtin"
  :custom ((show-paren-delay . 0.1))
  :global-minor-mode show-paren-mode)

(leaf smartparens
  :disabled t
  :ensure t
  :blackout t
  :defun (sp-pair)
  :hook (after-init-hook . smartparens-global-mode)
  :config
  (require 'smartparens-config)
  (sp-pair "=" "=" :actions '(wrap))
  (sp-pair "+" "+" :actions '(wrap))
  (sp-pair "<" ">" :actions '(wrap))
  (sp-pair "$" "$" :actions '(wrap)))

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

;; development
(leaf markdown-preview-mode
  :custom ((markdown-command . "pandoc")
	   (markdown-use-pandoc-style-yaml-metadata . t)
           (markdown-preview-stylesheets . '("github-markdown.css")))
  :config
  (provide 'markdown-config))

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
      
;; [Windows] launch explorer
(defun explorer-invoke()
  "Invoke Explorer on Windows systems"
  (interactive)
  (if (eq system-type 'windows-nt)
      (shell-command "explorer ."))
  (message "This OS is %s. This function works on on Windows " system-type))

;; Insert current date and time into the current buffer
(defvar current-date-time-format "%Y-%m-%d %H:%M:%S"
  "Format of date to insert with `insert-current-date-time' func. See help of `format-time-string' for possible replacements")

(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-date-time-format (current-time)))
  (insert "\n"))

(global-set-key "\C-cd" 'insert-current-date-time)

;; exec chmod +x when a file begins with '#!'
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; Personal customization
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
               '(height . 31)
               '(top . 4)
               '(left . 1))))
(cd "~")

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
