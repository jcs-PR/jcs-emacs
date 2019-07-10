;;; jcs-make-mode.el --- Makefile mode. -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(require 'make-mode)


(defun jcs-makefile-mode-hook ()
  "Makefile mode hook."
  (electric-pair-mode nil)
  (goto-address-mode 1)
  (auto-highlight-symbol-mode t)

  ;; File Header
  (jcs-insert-header-if-valid '("[.]makefile"
                                "[Mm]akefile"
                                "[.]mak")
                              'jcs-makefile-format-info)

  ;; Normal
  (define-key makefile-mode-map (kbd "<up>") #'jcs-py-indent-up)
  (define-key makefile-mode-map (kbd "<down>") #'jcs-py-indent-down)
  (define-key makefile-mode-map (kbd "RET") #'jcs-makefile-newline)

  (define-key makefile-mode-map (kbd "C-d") #'jcs-kill-whole-line)
  (define-key makefile-mode-map (kbd "C-c C-c") #'kill-ring-save)

  ;; tabify save key
  (define-key makefile-mode-map (kbd "C-s") #'jcs-tabify-save-buffer)
  )
(add-hook 'makefile-mode-hook 'jcs-makefile-mode-hook)


(provide 'jcs-make-mode)
;;; jcs-make-mode.el ends here
