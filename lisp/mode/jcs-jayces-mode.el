;;; jcs-jayces-mode.el --- JayCeS mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'jayces-mode)

;;
;; (@* "Templates" )
;;

(file-header-defins jcs-insert-jayces-template "jayces" "default.txt"
  "Header for JayCeS header file.")

;;
;; (@* "Hook" )
;;

(jcs-add-hook 'jayces-mode-hook
  ;; Treat underscore as word.
  (modify-syntax-entry ?_ "w")

  ;; File Header
  (jcs-insert-header-if-valid '("[.]jcs"
                                "[.]jayces")
                              'jcs-insert-jayces-template))

(provide 'jcs-jayces-mode)
;;; jcs-jayces-mode.el ends here
