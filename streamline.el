;;; streamline.el --- Minimalist's Mode Line  -*- lexical-binding: t; -*-

;; Copyright (C) 2019 Matthias Margush <matthias.margush@gmail.com>

;; Author: Matthias Margush <matthias.margush@gmail.com>
;; URL: https://github.com/matthias-margush/streamline
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.4.0"))
;; Keywords: convenience

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; A minimalist's mode line.

;; See the README for more info:
;; https://github.com/matthias-margush/streamline

;;; Code:
(defgroup streamline nil
  "A minimalist's mode line."
  :group 'mode-line
  :prefix "streamline-")

(defcustom streamline-toggle-keybinding "C-s-g"
  "Key binding to show original mode line for a few seconds."
  :type 'string)

(defun streamline--original-mode-line-format ()
  "Get the original mode line format."
  (or (eval (car (get 'mode-line-format 'saved-value)))
      (eval (car (get 'mode-line-format 'customized-value)))
      (eval (car (get 'mode-line-format 'standard-value)))))

(defun streamline-toggle ()
  "Display the original modeline for a few seconds."
  (interactive)
  (streamline--hide)
  (run-at-time "4 sec" nil #'streamline--show))

(defun streamline--show ()
  "Set the style attributes for the streamline."
  (setq-default mode-line-format '(""))
  (setq mode-line-format '(""))
  ;; clear background and foreground so they will inherit from default
  (set-face-attribute 'mode-line nil :background nil :foreground nil :underline t :box nil)
  (set-face-attribute 'mode-line nil :inherit 'default :underline t)
  (set-face-attribute 'mode-line-inactive nil :background nil :foreground nil :underline t :box nil)
  (set-face-attribute 'mode-line-inactive nil :inherit 'default :underline t)
  (force-mode-line-update t))

(defvar streamline--original-active-face-attributes nil
  "Save original active face attributes.")

(defvar streamline--original-inactive-face-attributes nil
  "Save original inactive face attributes.")

(defun streamline--init ()
  "Initialize streamline."
  (add-hook 'after-init-hook
            (lambda ()
              (setq streamline--original-active-face-attributes (face-all-attributes 'mode-line))
              (setq streamline--original-inactive-face-attributes (face-all-attributes 'mode-line-inactive))
              (streamline--show)))
  (when streamline-toggle-keybinding
    (global-set-key (kbd streamline-toggle-keybinding) #'streamline-toggle))
  (streamline--show))

(defun streamline--hide ()
  "Hide streamline; show original mode line."
  (dolist (attr streamline--original-active-face-attributes)
    (let ((attr-name (car attr))
          (attr-value (cdr attr)))
      (set-face-attribute 'mode-line nil attr-name attr-value)))
  (dolist (attr streamline--original-inactive-face-attributes)
    (let ((attr-name (car attr))
          (attr-value (cdr attr)))
      (set-face-attribute 'mode-line-inactive nil attr-name attr-value)))
  (setq-default mode-line-format (streamline--original-mode-line-format))
  (setq mode-line-format (streamline--original-mode-line-format))
  (force-mode-line-update t))

(defun streamline--deinit ()
  "Show the original mode line."
  (streamline--hide)
  (when streamline-toggle-keybinding
    (global-unset-key (kbd streamline-toggle-keybinding))))

;;;###autoload
(define-minor-mode streamline-mode
  "Toggle 'streamline mode'.

  This global minor mode provides a minimalist mode line."
  :global t
  (if streamline-mode
      (streamline--init)
    (streamline--deinit)))

;;;###autoload
(provide 'streamline)
;;; streamline.el ends here
