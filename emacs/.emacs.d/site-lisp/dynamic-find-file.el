;;; dynamic-find-file.el --- Open files from a placeholder template -*- lexical-binding: t; -*-

;; Author: circl
;; Version: 0.2.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: files, convenience

;;; Commentary:

;; This package expands `{namespace:name}' placeholders inside a template
;; path string and opens the resulting path with `find-file'.
;;
;; Two namespaces are supported:
;;   - `datetime': ISO-8601 date/time components, e.g. `{datetime:YYYY}'.
;;   - `emacs':    the value of an Emacs variable, e.g. `{emacs:user-login-name}'.
;;
;; TRAMP paths (e.g. "/sshx:user@host:/path/...") are supported
;; transparently, since only the "{namespace:name}" placeholders are
;; rewritten; the rest of the string, including any TRAMP prefix, is
;; passed to `find-file' unchanged.

;;; Code:

(defvar dynamic-find-file-datetime-token-alist
  '(("YYYY" . "%Y")
    ("YY"   . "%y")
    ("MM"   . "%m")
    ("DD"   . "%d")
    ("hh"   . "%H")
    ("mm"   . "%M")
    ("ss"   . "%S"))
  "Alist mapping `dynamic-find-file' \"datetime\" namespace token names
to `format-time-string' directives.")

(defconst dynamic-find-file--token-regexp
  "{\\([A-Za-z]+\\):\\([A-Za-z0-9-]+\\)}"
  "Regexp matching a `{namespace:name}' placeholder.")

(defun dynamic-find-file--resolve-datetime-token (name time)
  "Resolve NAME in the \"datetime\" namespace at TIME.
Signal a `user-error' if NAME is not a known datetime token."
  (let ((directive (cdr (assoc name dynamic-find-file-datetime-token-alist))))
    (unless directive
      (user-error "dynamic-find-file: unknown datetime token `%s'" name))
    (format-time-string directive time)))

(defun dynamic-find-file--resolve-emacs-token (name)
  "Resolve NAME in the \"emacs\" namespace to the value of the
Emacs variable named NAME, converted to a string.
Signal a `user-error' if NAME is not a bound variable."
  (let ((symbol (intern name)))
    (unless (boundp symbol)
      (user-error "dynamic-find-file: unbound emacs variable `%s'" name))
    (let ((value (symbol-value symbol)))
      (if (stringp value) value (format "%s" value)))))

(defun dynamic-find-file--resolve-token (namespace name time)
  "Resolve a placeholder given its NAMESPACE and NAME.
TIME is the reference time used for the \"datetime\" namespace.
Signal a `user-error' if NAMESPACE is unknown."
  (cond
   ((equal namespace "datetime")
    (dynamic-find-file--resolve-datetime-token name time))
   ((equal namespace "emacs")
    (dynamic-find-file--resolve-emacs-token name))
   (t
    (user-error "dynamic-find-file: unknown namespace `%s'" namespace))))

(defun dynamic-find-file--expand-template (template &optional time)
  "Expand all `{namespace:name}' placeholders in TEMPLATE and return the result.
TIME defaults to the current time when omitted."
  (let ((time (or time (current-time))))
    (replace-regexp-in-string
     dynamic-find-file--token-regexp
     (lambda (match)
       (dynamic-find-file--resolve-token
        (match-string 1 match) (match-string 2 match) time))
     template t t)))

;;;###autoload
(defun dynamic-find-file (template)
  "Expand TEMPLATE and open the resulting path with `find-file'.
When called interactively, TEMPLATE is read from the minibuffer."
  (interactive "sTemplate: ")
  (find-file (dynamic-find-file--expand-template template)))

(provide 'dynamic-find-file)
;;; dynamic-find-file.el ends here
