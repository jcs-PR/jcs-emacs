;;; jcs-haxe-mode.el --- Haxe mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'haxe-mode)

;;
;; (@* "Templates" )
;;

(defun jcs-insert-haxe-template ()
  "Template for Haxe."
  (jcs--file-header--insert "haxe" "default.txt"))

;;
;; (@* "Hook" )
;;

(add-hook 'haxe-mode-hook 'jcs-prog-mode-hook)

(jcs-add-hook 'haxe-mode-hook
  (modify-syntax-entry ?_ "w")

  ;; File Header
  (jcs-insert-header-if-valid '("[.]hx")
                              'jcs-insert-haxe-template)

  ;; Normal
  (jcs-key-local
    `(((kbd "<up>")        . ,(jcs-get-prev/next-key-type 'previous))
      ((kbd "<down>")      . ,(jcs-get-prev/next-key-type 'next))
      ((kbd "<backspace>") . jcs-smart-backspace)
      ((kbd "<delete>")    . jcs-smart-delete)

      ((kbd "DEL")         . jcs-electric-backspace)
      ((kbd "{")           . jcs-vs-opening-curly-bracket-key)
      ((kbd ";")           . jcs-vs-semicolon-key)

      ((kbd "C-v")         . jcs-smart-yank)

      ((kbd "M-w")         . jcs-other-window-next)
      ((kbd "M-q")         . jcs-other-window-prev))))

(provide 'jcs-haxe-mode)
;;; jcs-haxe-mode.el ends here