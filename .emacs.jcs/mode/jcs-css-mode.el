;;; jcs-css-mode.el --- CSS mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'css-mode)
(require 'com-css-sort)
(require 'emmet-mode)
(require 'rainbow-mode)

(require 'jcs-web)

;;
;; (@* "Hook" )
;;

(defun jcs-css-mode-hook ()
  "Hook for CSS mode."
  (impatient-mode t)

  (face-remap-add-relative 'font-lock-variable-name-face
                           `(:foreground ,(face-foreground 'jcs-css-variable-face)))

  ;; File Header
  (jcs-insert-header-if-valid '("[.]css")
                              'jcs-insert-css-template)

  ;; Normal
  (define-key css-mode-map (kbd "<up>") (jcs-get-prev/next-key-type 'previous))
  (define-key css-mode-map (kbd "<down>") (jcs-get-prev/next-key-type 'next))

  (define-key css-mode-map (kbd "DEL") #'jcs-electric-backspace)
  (define-key css-mode-map (kbd "{") #'jcs-vs-opening-curly-bracket-key)
  (define-key css-mode-map (kbd ";") #'jcs-vs-semicolon-key)

  ;; comment block
  (define-key css-mode-map (kbd "RET") #'jcs-css-return-key)
  (define-key css-mode-map (kbd "*") #'jcs-c-comment-pair)

  ;; sort attribute in order => `com-css-sort' package.
  (define-key css-mode-map (kbd "C-k s") #'com-css-sort-attributes-block)
  (define-key css-mode-map (kbd "C-k d") #'com-css-sort-attributes-document)

  ;; Eemmet
  (define-key emmet-mode-keymap (kbd "C-<return>") #'jcs-emmet-expand-line))

(add-hook 'css-mode-hook 'jcs-css-mode-hook)
(add-hook 'css-mode-hook 'emmet-mode)

(provide 'jcs-css-mode)
;;; jcs-css-mode.el ends here
