;;; jcs-jenkinsfile-mode.el --- Jenkinsfile mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'jenkinsfile-mode)

;;
;; (@* "Templates" )
;;

(defun jcs-insert-jenkinsfile-template ()
  "Header for Jenkinsfile."
  (jcs--file-header--insert "jenkins" "default.txt"))

;;
;; (@* "Hook" )
;;

(jcs-add-hook 'jenkinsfile-mode-hook
  (jcs-insert-header-if-valid '("Jenkinsfile")
                              'jcs-insert-jenkinsfile-template))

(provide 'jcs-jenkinsfile-mode)
;;; jcs-jenkinsfile-mode.el ends here