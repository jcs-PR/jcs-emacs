;;; jcs-js-mode.el --- JavaScript mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'js)

;;
;; (@* "Detection" )
;;

(defconst jcs-javascript-modes '(javascript-mode js-mode js2-mode js3-mode)
  "List of all JavaScript major modes.")

(defun jcs--js-to-jsx-mode (&optional force)
  "Switch from JavaScript mode to JSX mode, FORCE will ignore any conditions."
  (let (case-fold-search)
    (when (or (and (memq major-mode jcs-javascript-modes)
                   (string-match-p "React" (buffer-string)))
              force)
      (message "[INFO] Detect JSX file, change to `rjsx-mode` instead")
      (rjsx-mode))))

(file-header-defsrc jcs-js--ask-source "Major source for this JavaScript file: "
  '("Default (JS)" "Default (JSX)" "ReactJS" "React Native")
  (let (to-jsx)
    (pcase index
      (0 (jcs-insert-js-template))
      (1 (jcs-insert-jsx-template) (setq to-jsx t))
      (2 (jcs-insert-jsx-react-js-template) (setq to-jsx t))
      (3 (jcs-insert-jsx-react-native-template) (setq to-jsx t)))
    (when to-jsx (jcs--js-to-jsx-mode t))))

;;
;; (@* "Templates" )
;;

(file-header-defins jcs-insert-js-template "js" "default.txt"
  "Template for JavaScript.")

;;
;; (@* "Hook" )
;;

(jcs-add-hook '(js-mode-hook)
  (modify-syntax-entry ?_ "w")  ; Treat underscore as word

  (auto-rename-tag-mode 1)
  (impatient-mode t)

  ;; File Header
  (jcs-insert-header-if-valid '("[.]js$")
                              'jcs-js--ask-source
                              :interactive t)

  (jcs--js-to-jsx-mode))

(provide 'jcs-js-mode)
;;; jcs-js-mode.el ends here
