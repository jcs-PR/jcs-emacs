;;; jcs-vs.el --- Visual Studio function related  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; DESCRIPTION: For function that simulate the Visual Studio IDE's action.

(defun jcs-vs-opening-curly-bracket-key ()
  "For programming langauge that need `{`."
  (interactive)
  (jcs-delete-region)
  (if (jcs-inside-comment-or-string-p)
      (insert "{")
    (let (pretty-it space-infront)
      (unless (jcs-current-char-equal-p "{")
        (setq pretty-it t)
        (when (and (not (jcs-current-whitespace-or-tab-p))
                   (not (jcs-current-char-equal-p '("(" "["))))
          (setq space-infront t)))

      (when space-infront (insert " "))

      (insert "{ }")
      (backward-char 1)
      (indent-for-tab-command)

      (when pretty-it
        (save-excursion
          (jcs-safe-forward-char 2)
          (when (and (not (eobp))
                     (not (jcs-is-beginning-of-line-p))
                     (jcs-current-char-equal-p "}"))
            (backward-char 1)
            (insert " ")))))))

(defun jcs-vs-semicolon-key ()
  "For programming language that use semicolon as the end operator sign."
  (interactive)
  (jcs-delete-region)
  (insert ";")
  (save-excursion
    (forward-char 1)
    (when (and (not (jcs-is-beginning-of-line-p))
               (jcs-current-char-equal-p "}"))
      (backward-char 1)
      (insert " "))))

(defun jcs-vs-sharp-key ()
  "For programming language that use # as the preprocessor."
  (interactive)
  (jcs-delete-region)
  (insert "#")
  (backward-char 1)
  (when (jcs-is-infront-first-char-at-line-p)
    (kill-region (line-beginning-position) (point)))
  (forward-char 1))

(defun jcs-own-delete-backward-char ()
  "This isn't the VS like key action, is more likely to be user's own preferences."
  (interactive)
  (save-excursion
    (when (jcs-current-char-equal-p "{")
      (jcs-safe-forward-char 1)
      (when (and (not (jcs-is-beginning-of-line-p))
                 (jcs-current-char-equal-p " "))
        (jcs-safe-forward-char 1)
        (when (and (not (jcs-is-beginning-of-line-p))
                   (jcs-current-char-equal-p "}"))
          (backward-delete-char 1)))))
  (backward-delete-char 1)
  (save-excursion
    (when (jcs-current-char-equal-p "{")
      (forward-char 1)
      (when (and (not (jcs-is-beginning-of-line-p))
                 (jcs-current-char-equal-p " "))
        (forward-char 1)
        (when (and (not (jcs-is-beginning-of-line-p))
                   (jcs-current-char-equal-p "}"))
          (backward-char 1)
          (backward-delete-char 1))))))

(defun jcs-vs-cut-key ()
  "VS like cut key action.
If nothing is selected, we cut the current line, else we just delete the region."
  (interactive)
  (if buffer-read-only
      (call-interactively #'kill-ring-save)
    (if (jcs-is-region-selected-p)
        (call-interactively #'kill-region)
      (kill-whole-line))))

(provide 'jcs-vs)
;;; jcs-vs.el ends here
