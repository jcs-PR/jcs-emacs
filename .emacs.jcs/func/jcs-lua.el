;;; jcs-lua.el --- Lua related.  -*- lexical-binding: t -*-
;;; Commentary: When editing the Lua related file.
;;; Code:

(defconst jcs-lua-doc-splitter
  "-------------------------------------------------------------"
  "String that inserted around/between docstring.")

(defun jcs-lua-comment-prefix-p ()
  "Check if current line is a Lua style comment prefix."
  (jcs-triple-char-comment-prefix-p "-"))

(defun jcs-lua-comment-prefix-at-current-point-p ()
  "Check if the current point is Lua style comment prefix."
  (jcs-tripple-char-comment-prefix-at-current-point-p "-"))

(defun jcs-only-lua-comment-prefix-this-line-p ()
  "Check if there is only comment in this line."
  (save-excursion
    (let (only-comment-this-line)
      (when (jcs-lua-comment-prefix-p)
        (jcs-goto-first-char-in-line)
        (forward-char 3)
        (unless (jcs-is-there-char-forward-until-end-of-line-p)
          (setq only-comment-this-line t)))
      only-comment-this-line)))


(defun jcs-lua-do-doc-string ()
  "Check if should insert the doc string by checking only comment character \
 on the same line."
  (let ((do-doc-string t))
    (jcs-goto-first-char-in-line)
    (while (not (jcs-is-end-of-line-p))
      (forward-char 1)
      (unless (jcs-current-char-equal-p '(" " "\t" "-"))
        (setq do-doc-string nil)))
    do-doc-string))

;;;###autoload
(defun jcs-lua-maybe-insert-codedoc ()
  "Insert common Lua document/comment string."
  ;;URL: http://lua-users.org/wiki/LuaStyleGuide
  (interactive)
  (insert "-")
  (let (active-comment next-line-not-empty)
    (save-excursion
      (when (and
             ;; Line can only have Lua comment prefix.
             (jcs-only-lua-comment-prefix-this-line-p)
             ;; Only enable when `---' at current point.
             (jcs-lua-comment-prefix-at-current-point-p))
        (setq active-comment t))

      ;; check if next line empty.
      (jcs-next-line)
      (unless (jcs-current-line-empty-p) (setq next-line-not-empty t)))

    (when (and active-comment next-line-not-empty)
      (insert (format "%s\n" jcs-lua-doc-splitter))
      (insert "-- \n")
      (insert (format "%s---" jcs-lua-doc-splitter))

      (jcs-smart-indent-up)
      (jcs-smart-indent-down)
      (jcs-smart-indent-down)
      (jcs-smart-indent-up)
      (jcs-smart-indent-up)
      (end-of-line)

      ;; Check other comment type.
      ;; ex: param, returns, etc.
      (save-excursion
        ;; Goto the function line before insert doc string.
        (jcs-next-line)
        (jcs-next-line)

        ;; insert comment doc comment string.
        (jcs-insert-comment-style-by-current-line ")")))))

(provide 'jcs-lua)
;;; jcs-lua.el ends here
