;;; jcs-properties-mode.el --- Properties mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;
;; (@* "Hook" )
;;

(defun jcs-properties-mode-hook ()
  "Properties mode hook."
  (abbrev-mode 1)
  (electric-pair-mode 1)
  (goto-address-mode 1)
  (auto-highlight-symbol-mode t)

  ;; Treat underscore as word.
  (modify-syntax-entry ?_ "w")

  ;; Normal
  (jcs-bind-key (kbd "<up>") (jcs-get-prev/next-key-type 'previous))
  (jcs-bind-key (kbd "<down>") (jcs-get-prev/next-key-type 'next)))

(add-hook 'conf-javaprop-mode-hook 'jcs-properties-mode-hook)

(provide 'jcs-properties-mode)
;;; jcs-properties-mode.el ends here
