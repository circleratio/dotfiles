;;; wget.el --- init.el  -*- lexical-binding: t; -*-
;;;
;;; Copyright (C) 2023  Teruyoshi FUJIWARA <tf@dsl.gr.jp>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(defvar *wg-default-extention* "jpg")

(defun wg-get(&optional ext-arg)
  "Scan HTML and extract URLs in href and src arguments with a specifiled extention. This function makes a result as a shell script using wget to retrieve extracted files."
  (interactive "sExtention: ")
  (let ((ext (if (equal ext-arg "") *wg-default-extention*
               ext-arg)))
    (goto-line (point-min))
    (replace-string ">" "\n")
    (goto-line (point-min))
    (replace-regexp "^wget.*" "")
    (goto-line (point-min))
    (replace-regexp "^mv.*" "")
    (goto-line (point-min))
    (replace-regexp "^.*href=\"" "wget -c ")
    (replace-regexp "^.*src=\"" "wget -c ")
    (goto-line (point-min))
    (replace-regexp "\".*$" "")
    (goto-line (point-min))
    (replace-regexp "^<.*" "")
    (goto-line (point-min))
    (replace-regexp "^.*\\.js$" "")
    (goto-line (point-min))
    (keep-lines (concat "^wget.*" ext "$"))
    
    (goto-line (point-min))
    (flush-lines "^$")))

(defun wg-recur-insert-numbered-file (&optional ext-arg)
  "This command should be used after wg-get. It makes a shell script to rename retrieved files from the net, which may have irregular format, and give names with ordered numbers."
  (interactive "sExtention: ")
  (let ((ext (if (equal ext-arg "") *wg-default-extention*
               ext-arg)))
    (copy-region-as-kill (point-min) (point-max))
    (goto-char (point-max))
    (insert "\n# Mark \n")
    (yank)
    (goto-char (point-min))
    (flush-lines "^ *$")
    
    (search-forward "# Mark")
    (replace-regexp "^.*/" "mv ")
    (search-backward "# Mark")
    (next-line)
    (end-of-line)
    (insert (concat " 01." ext))
    (next-line)
    (end-of-line)
    (insert " ")
    (wg-recur-insert-numbers ext)
    (beginning-of-line)
    (kill-line)))

(defun wg-recur-insert-numbers (ext)
  (wg-insert-next-numbered-file ext)
  (if (eq (forward-line) 0)
      (progn
        (end-of-line)
        (insert " ")
        (wg-recur-insert-numbers ext))))

(defun wg-insert-next-numbered-file (ext)
  (save-excursion
    (save-restriction
      (setq bor
            (progn
              (previous-line)
              (beginning-of-line)
              (point)))
      (setq eor
            (progn
              (end-of-line)
              (point)))
      (narrow-to-region bor eor)
      (let ((s (buffer-string)))
        (string-match (concat "\\([0-9]+\\)\\." *wg-default-extention* "$") s)
        (setq cnt (string-to-number (match-string 1 s))))))
  (insert (format (concat "%02d." ext) (+ cnt 1))))

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
