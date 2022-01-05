;;; jcs-ini-mode.el --- INI mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'ini-mode)

;;
;; (@* "Hook" )
;;

(defun jcs-ini-mode-hook ()
  "INI mode hook."

  ;; Treat underscore as word.
  (modify-syntax-entry ?_ "w")

  ;; Normal
  (jcs-bind-key (kbd "<up>") (jcs-get-prev/next-key-type 'previous))
  (jcs-bind-key (kbd "<down>") (jcs-get-prev/next-key-type 'next)))

(add-hook 'ini-mode-hook 'jcs-ini-mode-hook)

(provide 'jcs-ini-mode)
;;; jcs-ini-mode.el ends here
