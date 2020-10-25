;;; jcs-cc-mode.el --- C/C++ Common mode. -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'cc-mode)

(require 'company-c-headers)

;;
;; (@* "Style" )
;;

(defconst jcs-big-fun-cc-style
  '((c-electric-pound-behavior   . nil)
    (c-tab-always-indent         . t)
    (c-comment-only-line-offset  . 0)
    (c-hanging-braces-alist      . ((class-open)
                                    (class-close)
                                    (defun-open)
                                    (defun-close)
                                    (inline-open)
                                    (inline-close)
                                    (brace-list-open)
                                    (brace-list-close)
                                    (brace-list-intro)
                                    (brace-list-entry)
                                    (block-open)
                                    (block-close)
                                    (substatement-open)
                                    (statement-case-open)
                                    (class-open)))
    (c-hanging-colons-alist      . ((inher-intro)
                                    (case-label)
                                    (label)
                                    (access-label)
                                    (access-key)
                                    (member-init-intro)))
    (c-cleanup-list              . (scope-operator
                                    list-close-comma
                                    defun-close-semi))
    (c-offsets-alist             . ((arglist-close         . c-lineup-arglist)
                                    (label                 . -)
                                    (access-label          . -)
                                    (substatement-open     . 0)
                                    (statement-case-intro  . +)
                                    (statement-block-intro . +)
                                    (case-label            . 0)
                                    (block-open            . 0)
                                    (inline-open           . 0)
                                    (inlambda              . 0)
                                    (topmost-intro-cont    . 0)
                                    (knr-argdecl-intro     . -)
                                    (brace-list-open       . 0)
                                    (brace-list-intro      . +)))
    ;; NOTE: no more echo.
    (c-echo-syntactic-information-p . nil))
  "Casey's Big Fun C/C++ Style")

;;
;; (@* "Header" )
;;

(defconst jcs-c-header-extensions '("[.]h")
  "List of C header file extension.")

(defconst jcs-c-source-extensions '("[.]c")
  "List of C source file extension.")

(defconst jcs-c++-header-extensions '("[.]hin" "[.]hpp")
  "List of C++ header file extension.")

(defconst jcs-c++-source-extensions '("[.]cin" "[.]cpp")
  "List of C++ source file extension.")

(defun jcs-cc-insert-header ()
  "Insert header for `cc-mode' related modes."
  (jcs-insert-header-if-valid jcs-c++-header-extensions 'jcs-insert-c++-header-template)
  (jcs-insert-header-if-valid jcs-c++-source-extensions 'jcs-insert-c++-source-template)
  (jcs-insert-header-if-valid jcs-c-header-extensions 'jcs-insert-c-header-template)
  (jcs-insert-header-if-valid jcs-c-source-extensions 'jcs-insert-c-source-template))

;;
;; (@* "Hook" )
;;

(defun jcs-cc-mode-hook ()
  "C/C++ mode hook."

  (jcs-company-safe-add-backend 'company-clang)

  ;; Set my style for the current buffer
  (c-add-style "BigFun" jcs-big-fun-cc-style t)

  ;; Additional style stuff
  (c-set-offset 'member-init-intro '++)

  ;; No hungry backspace
  (c-toggle-auto-hungry-state -1)

  (modify-syntax-entry ?_ "w"))

(add-hook 'c-mode-common-hook 'jcs-cc-mode-hook)

(provide 'jcs-cc-mode)
;;; jcs-cc-mode.el ends here
