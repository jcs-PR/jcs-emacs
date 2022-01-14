;;; jcs-csharp-mode.el --- C# Mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'csharp-mode)

(defun jcs-csharp-ask-source (sc)
  "Ask the source SC for editing CSharp file."
  (interactive
   (list (completing-read
          "Major source for this CSharp file: " '("Default" "Unity Scripting"))))
  (pcase sc
    ("Default" (jcs-insert-csharp-template))
    ("Unity Scripting" (jcs-insert-csharp-unity-template))))

(defun jcs-vs-csharp-comment-prefix-p ()
  "Return non-nil if current line is Visual Studio's style comment prefix."
  (jcs-triple-char-comment-prefix-p "/"))

(defun jcs-vs-csharp-only-vs-comment-prefix-this-line-p ()
  "Return non-nil if only comment this line."
  (save-excursion
    (let (only-comment-this-line)
      (when (jcs-vs-csharp-comment-prefix-p)
        (jcs-goto-first-char-in-line)
        (forward-char 3)
        (unless (jcs-is-there-char-forward-until-end-of-line-p)
          (setq only-comment-this-line t)))
      only-comment-this-line)))

(defun jcs-vs-csharp-do-doc-string ()
  "Return non-nil if able to insert document string."
  (let ((do-doc-string t))
    (jcs-goto-first-char-in-line)
    (while (not (jcs-end-of-line-p))
      (forward-char 1)
      (unless (jcs-current-char-equal-p '(" " "\t" "/"))
        (setq do-doc-string nil)))
    do-doc-string))

;;
;; (@* "Templates" )
;;

(defun jcs-insert-csharp-template ()
  "Header for C# header file."
  (jcs--file-header--insert "csharp" "default.txt"))

(defun jcs-insert-csharp-unity-template ()
  "Header for Unity C# header file."
  (jcs--file-header--insert "csharp" "unity.txt"))

;;
;; (@* "Hook" )
;;

(jcs-add-hook 'csharp-mode-hook
  (setq-local docstr-show-type-name nil)

  (modify-syntax-entry ?_ "w")

  ;; File Header
  (jcs-insert-header-if-valid '("[.]cs")
                              'jcs-csharp-ask-source
                              :interactive t)

  (jcs-key-local
    `(((kbd "<up>")   . ,(jcs-get-prev/next-key-type 'previous))
      ((kbd "<down>") . ,(jcs-get-prev/next-key-type 'next))

      ((kbd "DEL") . jcs-electric-backspace)
      ((kbd "{") . jcs-vs-opening-curly-bracket-key)
      ((kbd ";") . jcs-vs-semicolon-key)

      ([f8] . jcs-find-corresponding-file)
      ([S-f8] . jcs-find-corresponding-file-other-window)

      ((kbd "#") . jcs-vs-sharp-key)

      ((kbd "M-q") . jcs-other-window-prev))))

(provide 'jcs-csharp-mode)
;;; jcs-csharp-mode.el ends here