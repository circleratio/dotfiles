;;; qrencode.el --- init.el  -*- lexical-binding: t; -*-
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

(defvar *qrencode-script* "python /home/user/.emacs.d/scripts/qrencode.py")

(defun qr-region ()
  (interactive)
  (let* ((png-file
          (make-temp-file "qrencode" nil ".png"))
         (command-str
          (mapconcat #'identity
                     (list *qrencode-script*
                           "-o"
                           png-file)
                     " ")))
    (shell-command-on-region (region-beginning) (region-end)
                             command-str
                             nil t)
    (insert-image (create-image (expand-file-name png-file)))))

;; Local Variables:
;; indent-tabs-mode: nil
;; End:
