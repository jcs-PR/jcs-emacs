;;; jcs-jsx-mode.el --- JavaScript XML mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'rjsx-mode)
(require 'web-mode)
(require 'emmet-mode)

(defun jcs-jsx--ask-source (sc)
  "Ask the source SC for editing JavaScript XML file."
  (interactive
   (list (completing-read
          "Major source for this JavaScript XML file: "
          '("Default"
            "ReactJS"
            "React Native"))))
  (cond ((string= sc "Default") (jcs-insert-jsx-template))
        ((string= sc "ReactJS") (jcs-insert-jsx-react-js-template))
        ((string= sc "React Native") (jcs-insert-jsx-react-native-template))))

;;
;; (@* "Faces" )
;;

(custom-set-faces
 '(rjsx-tag ((t (:foreground "#87CEFA"))))
 '(rjsx-attr ((t (:foreground "#EEDD82"))))
 '(rjsx-text ((t (:inherit default))))
 '(rjsx-tag-bracket-face ((t (:inherit 'web-mode-html-attr-name-face)))))

;;
;; (@* "Templates" )
;;

(defun jcs-insert-jsx-template ()
  "Template for JavaScript XML (JSX)."
  (jcs--file-header--insert "jsx" "default.txt"))

(defun jcs-insert-jsx-react-js-template ()
  "Template for React JS JavaScript XML (JSX)."
  (jcs--file-header--insert "jsx" "react/js.txt"))

(defun jcs-insert-jsx-react-native-template ()
  "Template for React Native JavaScript XML (JSX)."
  (jcs--file-header--insert "jsx" "react/native.txt"))

;;
;; (@* "Hook" )
;;

(add-hook 'rjsx-mode-hook 'emmet-mode)

(jcs-add-hook 'rjsx-mode-hook
  (auto-rename-tag-mode 1)

  ;; File Header
  (jcs-insert-header-if-valid '("[.]jsx$")
                              'jcs-jsx--ask-source
                              :interactive t)

  (jcs-key-local
    `(((kbd "{") . jcs-web-vs-opening-curly-bracket-key)
      ((kbd ";") . jcs-vs-semicolon-key)))

  (jcs-key emmet-mode-keymap
    `(((kbd "C-<return>") . jcs-emmet-expand-line))))


(provide 'jcs-jsx-mode)
;;; jcs-jsx-mode.el ends here