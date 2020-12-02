;;; jcs-perl-mode.el --- Perl mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'perl-mode)

;;
;; (@* "Hook" )
;;

(defun jcs-perl-mode-hook ()
  "Perl mode hook."

  (modify-syntax-entry ?_ "w")

  ;; File Header
  (jcs-insert-header-if-valid '("[.]pl")
                              'jcs-insert-perl-template)

  ;; Normal
  (define-key perl-mode-map (kbd "DEL") #'jcs-electric-backspace)
  (define-key perl-mode-map (kbd "{") #'jcs-vs-opening-curly-bracket-key)
  (define-key perl-mode-map (kbd "}") #'jcs-vs-closing-curly-bracket-key)
  (define-key perl-mode-map (kbd ";") #'jcs-vs-semicolon-key))

(add-hook 'perl-mode-hook 'jcs-perl-mode-hook)

(provide 'jcs-perl-mode)
;;; jcs-perl-mode.el ends here
