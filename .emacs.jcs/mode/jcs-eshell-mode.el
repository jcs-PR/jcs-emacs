;;; jcs-eshell-mode.el --- Eshell mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'esh-mode)

;;
;; (@* "Hook" )
;;

(defun jcs-eshell-mode-hook ()
  "Eshell mode hook."

  (define-key eshell-mode-map (kbd "M-k") #'jcs-maybe-kill-shell))

(add-hook 'eshell-mode-hook 'jcs-eshell-mode-hook)

(provide 'jcs-eshell-mode)
;;; jcs-eshell-mode.el ends here
