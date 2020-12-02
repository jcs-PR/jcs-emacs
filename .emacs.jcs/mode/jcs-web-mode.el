;;; jcs-web-mode.el --- Web Development mode  -*- lexical-binding: t -*-
;;; Commentary: Including HTML, CSS, PHP, JavaScript, JSON.
;;; Code:

;;
;; (@* "Real time editing" )
;;

;; Note for "Impatient Mode" (real time editing)
;; Step 1: M-x httpd-start        (Open the port default: 8080)
;; Step 2: M-x impatient-mode     (Enabled Impatient Mode)

(require 'impatient-mode)

;;
;; (@* "Related Packages" )
;;

(require 'auto-rename-tag)
(require 'emmet-mode)
(require 'htmltagwrap)

;;
;; (@* "Hook" )
;;

(require 'web-mode)

(defun jcs-web-mode-hook ()
  "Hooks for Web mode."
  (auto-rename-tag-mode 1)
  (atl-markup-mode 1)
  (visual-line-mode t)
  (impatient-mode t)

  (jcs-enable-truncate-lines)

  ;; Docstring Faces
  (face-remap-add-relative 'docstr-faces-tag-face '(:inherit web-mode-block-face))
  (face-remap-add-relative 'docstr-faces-type-face '(:inherit web-mode-block-face))
  (face-remap-add-relative 'docstr-faces-value-face '(:inherit web-mode-block-face))
  (face-remap-add-relative 'web-mode-block-string-face '(font-lock-string-face))
  (face-remap-add-relative 'web-mode-html-attr-value-face '(jcs-web-mode-html-attr-value-face))

  (jcs-make-electric-pair-pairs-local '((?\' . ?\')))
  (jcs-make-electric-pair-pairs-local '((?\" . ?\")))

  ;; File Header
  (jcs-insert-header-if-valid '("[.]htm" "[.]html"
                                "[.]asp"
                                "[.]as[cp]x")
                              'jcs-insert-html-template)
  (jcs-insert-header-if-valid '("[.]php")
                              'jcs-insert-php-template)

  ;; Normal
  (define-key web-mode-map (kbd "RET") #'jcs-web-return-key)

  (define-key web-mode-map (kbd "DEL") #'jcs-electric-backspace)
  (define-key web-mode-map (kbd "{") #'jcs-web-vs-opening-curly-bracket-key)
  (define-key web-mode-map (kbd "}") #'jcs-vs-closing-curly-bracket-key)
  (define-key web-mode-map (kbd ";") #'jcs-vs-semicolon-key)

  ;; File Corresponding
  (define-key web-mode-map [f8] #'jcs-find-corresponding-file)
  (define-key web-mode-map [S-f8] #'jcs-find-corresponding-file-other-window)

  ;; comment block
  (define-key web-mode-map (kbd "*") #'jcs-c-comment-pair)

  ;; Shortcuts
  (define-key web-mode-map (kbd "C-n") #'web-mode-tag-match)

  ;; Emmet
  (define-key emmet-mode-keymap (kbd "C-<return>") #'jcs-emmet-expand-line)

  ;; PHP
  (define-key web-mode-map [C-backspace] #'jcs-web-backward-delete-word)
  (define-key web-mode-map (kbd "M-<backspace>") #'jcs-web-backward-delete-word-capital))

(add-hook 'web-mode-hook 'jcs-web-mode-hook)
(add-hook 'web-mode-hook 'emmet-mode)

(defun jcs-html-mode-hook ()
  "HTML mode hook."
  (define-key html-mode-map (kbd "<up>") (jcs-get-prev/next-key-type 'previous))
  (define-key html-mode-map (kbd "<down>") (jcs-get-prev/next-key-type 'next)))

(add-hook 'html-mode-hook 'jcs-html-mode-hook)

(provide 'jcs-web-mode)
;;; jcs-web-mode.el ends here
