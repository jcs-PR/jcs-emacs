;;; jcs-lua-mode.el --- Lua mode. -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'lua-mode)

;;
;; (@* "Hook" )
;;

(defun jcs-lua-mode-hook ()
  "Lau mode hook."

  ;; Treat underscore as word.
  (modify-syntax-entry ?_ "w")

  ;; File Header
  (jcs-insert-header-if-valid '("[.]lua"
                                "[.]luac")
                              'jcs-insert-lua-template)

  ;; Comment
  (define-key lua-mode-map (kbd "-") #'jcs-lua-maybe-insert-codedoc)

  ;; comment block
  (define-key lua-mode-map (kbd "RET") #'jcs-smart-context-line-break))

(add-hook 'lua-mode-hook 'jcs-lua-mode-hook)

(provide 'jcs-lua-mode)
;;; jcs-lua-mode.el ends here
