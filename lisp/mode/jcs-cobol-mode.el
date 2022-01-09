;;; jcs-cobol-mode.el --- COBOL mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cobol-mode)

;;
;; (@* "Templates" )
;;

(defun jcs-insert-cobol-template ()
  "Template for COBOL."
  (jcs--file-header--insert "cobol" "default.txt"))

;;
;; (@* "Hook" )
;;

(jcs-add-hook 'cobol-mode-hook
  (electric-pair-mode nil)

  ;; File Header
  (jcs-insert-header-if-valid '("[.]cbl")
                              'jcs-insert-cobol-template)

  (jcs-key-local
    `(((kbd "<up>")   . ,(jcs-get-prev/next-key-type 'previous))
      ((kbd "<down>") . ,(jcs-get-prev/next-key-type 'next)))))

(provide 'jcs-cobol-mode)
;;; jcs-cobol-mode.el ends here
