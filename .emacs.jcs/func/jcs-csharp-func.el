;;; jcs-csharp-func.el --- C Sharp related.  -*- lexical-binding: t -*-
;;; Commentary: When editing the C# related file.
;;; Code:

;;;###autoload
(defun jcs-csharp-ask-source (sc)
  "Ask the source SC for editing CSharp file."
  (interactive
   (list (completing-read
          "Major source for this CSharp file: " '("Default"
                                                  "Unity Scripting"))))
  (cond ((string= sc "Default") (jcs-insert-csharp-template))
        ((string= sc "Unity Scripting") (jcs-insert-csharp-unity-template))))

(defun jcs-vs-csharp-comment-prefix-p ()
  "Check if current line is a Visual Studio's style comment prefix."
  (jcs-triple-char-comment-prefix-p "/"))

(defun jcs-vs-csharp-comment-prefix-at-current-point-p ()
  "Check if the current point is Visaul Studio's style comment prefix."
  (jcs-tripple-char-comment-prefix-at-current-point-p "/"))

(defun jcs-vs-csharp-only-vs-comment-prefix-this-line-p ()
  "Check if there is only comment in this line and is Visaul Studio \
comment prefix only."
  (save-excursion
    (let ((only-comment-this-line nil))
      (when (jcs-vs-csharp-comment-prefix-p)
        (jcs-goto-first-char-in-line)
        (forward-char 3)
        (when (not (jcs-is-there-char-forward-until-end-of-line-p))
          (setq only-comment-this-line t)))
      only-comment-this-line)))

(defun jcs-vs-csharp-do-doc-string ()
  "Check if should insert the doc string by checking only comment characters \
on the same line."
  (let ((do-doc-string t))
    (jcs-goto-first-char-in-line)
    (while (not (jcs-is-end-of-line-p))
      (forward-char 1)
      (unless (jcs-current-char-equal-p '(" " "\t" "/"))
        ;; return false.
        (setq do-doc-string nil)))
    ;; return true.
    do-doc-string))

;;;###autoload
(defun jcs-vs-csharp-maybe-insert-codedoc ()
  "Insert comment like Visual Studio comment style."
  ;; URL: https://github.com/josteink/csharp-mode/issues/123
  (interactive)
  (insert "/")
  (let (active-comment next-line-not-empty)
    (save-excursion
      (when (and
             ;; Line can only have vs comment prefix.
             (jcs-vs-csharp-only-vs-comment-prefix-this-line-p)
             ;; Current point match vs comment prefix.
             (jcs-vs-csharp-comment-prefix-at-current-point-p))
        (setq active-comment t))

      ;; check if next line empty.
      (jcs-next-line)
      (unless (jcs-current-line-empty-p) (setq next-line-not-empty t)))

    (when (and active-comment next-line-not-empty)
      (insert " <summary>\n")
      (insert "/// \n")
      (insert "/// </summary>")

      (jcs-smart-indent-up)
      (jcs-smart-indent-down)
      (jcs-smart-indent-up)
      (end-of-line)

      ;; Check other comment type.
      ;; ex: param, returns, etc.
      (save-excursion
        ;; Goto the function line before insert doc string.
        (jcs-next-line)
        (jcs-next-line)

        ;; insert comment doc comment string.
        (jcs-insert-comment-style-by-current-line "[{;]")))))

;;
;; (@* "Indentation" )
;;

;;;###autoload
(defun jcs-csharp-smart-indent-up ()
  "CSharp mode smart indent up."
  (interactive)
  (jcs-smart-indent-up)
  (when (and (jcs-is-end-of-line-p)
             (jcs-current-char-equal-p "/")
             (jcs-vs-csharp-only-vs-comment-prefix-this-line-p))
    (insert " ")))

;;;###autoload
(defun jcs-csharp-smart-indent-down ()
  "CSharp mode smart indent down."
  (interactive)
  (jcs-smart-indent-down)
  (when (and (jcs-is-end-of-line-p)
             (jcs-current-char-equal-p "/")
             (jcs-vs-csharp-only-vs-comment-prefix-this-line-p))
    (insert " ")))

(provide 'jcs-csharp-func)
;;; jcs-csharp-func.el ends here
