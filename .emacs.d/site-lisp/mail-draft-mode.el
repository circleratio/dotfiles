;;; package --- Mail Draft Mode
(require 'cl-lib)

(defvar mail-draft-mode-map (make-sparse-keymap))

(define-key mail-draft-mode-map "\C-c\C-c" 'mail-draft-send)

(defvar mail-draft-folder-root (concat (expand-file-name "~") "/Mail"))
(defvar mail-draft-folder-drafts (concat mail-draft-folder-root "/drafts"))
(defvar mail-draft-folder-sent (concat mail-draft-folder-root "/sent"))

(defvar mail-draft-template "To: \nCc: \nBcc: \nSubject: \nAttachment: \n---\n")

(defvar mail-sender-script (concat (expand-file-name "~") "/.emacs.d/scripts/ol_comp.py"))

(defun mail-draft-get-draft-filename()
  (concat
   mail-draft-folder-drafts
   "/"
   (number-to-string
    (+ 1
       (apply 'max
              (cl-loop for elm in (cl-remove-if-not (lambda(s) (string-match "[0-9]+.txt" s))
                                              (cons "0.txt" (directory-files mail-draft-folder-drafts)))
                    collect (string-to-number (replace-regexp-in-string ".txt" "" elm))))))
   ".txt"))

(defun mail-draft-new ()
  "Create a new mail draft and open it."
  (interactive)
  (find-file
   (mail-draft-get-draft-filename))
  (mail-draft-mode)
  (insert mail-draft-template))

(defun mail-draft-send ()
  "Send the draft."
  (interactive)
  (save-buffer)
  (let ((result (call-process "python" nil nil nil mail-sender-script (buffer-file-name))))
    (cond ((eq result 0)
           (message (concat (buffer-file-name) " was successfully sent."))
           (kill-buffer))
          (t (message "Failed to send the draft.")))))

(defun mail-draft-mode ()
  "A major mode for making a mail draft."
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "Mail Draft")
  (setq major-mode 'mail-draft-mode)

  (use-local-map mail-draft-mode-map)
  (run-hooks 'mail-draft-mode-hook))

(provide 'mail-draft-mode)
  
;;; mail-draft-mode.el ends here
