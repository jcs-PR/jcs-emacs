;;; jcs-nav.el --- Nagivation in file.  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;----------------------------------------------------------------------------
;; Goto Definition

;;;###autoload
(defun jcs-goto-definition ()
  "Move to definition."
  (interactive)
  (cond
   ((jcs-is-current-major-mode-p '("elisp-mode"
                                   "lisp-mode"
                                   "lisp-interaction-mode"))
    (unless (ignore-errors (elisp-def))
      (user-error "[INFO] No definition found for current target")))
   ((and lsp-mode
         (or (ignore-errors (lsp-goto-type-definition))
             (ignore-errors (lsp-goto-implementation)))))
   (t (dumb-jump-go-prefer-external)))
  t)

;;;###autoload
(defun jcs-goto-definition-other-window ()
  "Move to definition other window."
  (interactive)
  (let ((fnc nil))
    (cond
     ((or
       (jcs-is-current-major-mode-p '("elisp-mode"
                                      "lisp-mode"
                                      "lisp-interaction-mode"))
       lsp-mode)
      (setq fnc #'jcs-goto-definition))
     (t (dumb-jump-go-prefer-external-other-window)))
    (when fnc  ; Open it on the other window.
      (jcs--record-window-excursion-apply (jcs--record-window-excursion fnc)))))

;;----------------------------------------------------------------------------
;; Move Between Line (Wrapper)

(defun jcs-get-major-mode-prev/next-key-type (direction)
  "Return the major-mode's prev/next key type by DIRECTION."
  (cl-case direction
    (previous
     (cond
      ((jcs-is-current-major-mode-p '("cmake-mode"
                                      "cobol-mode"
                                      "dockerfile-mode"
                                      "makefile-mode"
                                      "masm-mode"
                                      "nasm-mode"
                                      "python-mode"
                                      "yaml-mode"))
       'jcs-py-indent-up)
      ((jcs-is-current-major-mode-p '("bat-mode"
                                      "conf-javaprop-mode"
                                      "gitattributes-mode"
                                      "gitconfig-mode"
                                      "gitignore-mode"
                                      "ini-mode"
                                      "message-mode"
                                      "reb-mode"
                                      "ssass-mode"
                                      "sql-mode"
                                      "vimrc-mode"))
       'previous-line)
      ((jcs-is-current-major-mode-p '("csharp-mode"))
       'jcs-csharp-smart-indent-up)
      ((jcs-is-current-major-mode-p '("css-mode"))
       'jcs-css-smart-indent-up)
      ((jcs-is-current-major-mode-p '("shell-mode"))
       'jcs-shell-up-key)
      (t 'jcs-smart-indent-up)))
    (next
     (cond
      ((jcs-is-current-major-mode-p '("cmake-mode"
                                      "cobol-mode"
                                      "dockerfile-mode"
                                      "makefile-mode"
                                      "masm-mode"
                                      "nasm-mode"
                                      "python-mode"
                                      "yaml-mode"))
       'jcs-py-indent-down)
      ((jcs-is-current-major-mode-p '("bat-mode"
                                      "conf-javaprop-mode"
                                      "gitattributes-mode"
                                      "gitconfig-mode"
                                      "gitignore-mode"
                                      "ini-mode"
                                      "message-mode"
                                      "reb-mode"
                                      "ssass-mode"
                                      "sql-mode"
                                      "vimrc-mode"))
       'next-line)
      ((jcs-is-current-major-mode-p '("csharp-mode"))
       'jcs-csharp-smart-indent-down)
      ((jcs-is-current-major-mode-p '("css-mode"))
       'jcs-css-smart-indent-down)
      ((jcs-is-current-major-mode-p '("shell-mode"))
       'jcs-shell-down-key)
      (t 'jcs-smart-indent-down)))
    (t (user-error "[WARNING] Please define direction with 'previous' or 'next'"))))

(defun jcs-get-prev/next-key-type (direction)
  "Return the prev/next key type by DIRECTION."
  (cl-case direction
    (previous (cl-case jcs-prev/next-key-type
                (normal 'previous-line)
                (indent (jcs-get-major-mode-prev/next-key-type direction))
                (smart 'jcs-smart-previous-line)
                (t (user-error "[WARNING] Prev/Next key type not defined"))))
    (next (cl-case jcs-prev/next-key-type
            (normal 'next-line)
            (indent (jcs-get-major-mode-prev/next-key-type direction))
            (smart 'jcs-smart-next-line)
            (t (user-error "[WARNING] Prev/Next key type not defined"))))
    (t (user-error "[WARNING] Please define direction with 'previous' or 'next'"))))

;;;###autoload
(defun jcs-previous-line ()
  "Calling `previous-line' does not execute.
Just use this without remember Emacs Lisp function."
  (interactive)
  (call-interactively #'previous-line))

;;;###autoload
(defun jcs-next-line ()
  "Calling `next-line' does not execute.
Just use this without remember Emacs Lisp function."
  (interactive)
  (call-interactively #'next-line))

;;;###autoload
(defun jcs-smart-previous-line ()
  "Smart way to navigate to previous line."
  (interactive)
  (jcs-previous-line)
  (when (jcs-is-infront-first-char-at-line-p)
    (end-of-line)
    (jcs-beginning-of-line)))

;;;###autoload
(defun jcs-smart-next-line ()
  "Smart way to navigate to next line."
  (interactive)
  (jcs-next-line)
  (when (jcs-is-infront-first-char-at-line-p)
    (end-of-line)
    (jcs-beginning-of-line)))

;;----------------------------------------------------------------------------
;; Move Between Word (Wrapper)

;;;###autoload
(defun jcs-backward-word ()
  "Backward a word."
  (interactive)
  (call-interactively #'backward-word))

;;;###autoload
(defun jcs-forward-word ()
  "Forward a word."
  (interactive)
  (call-interactively #'forward-word))

;;;###autoload
(defun jcs-smart-backward-word ()
  "Smart backward a word."
  (interactive)
  (let ((start-pt (point)) (start-ln (line-number-at-pos))
        (beg-ln (jcs-is-beginning-of-line-p))
        (infront-first-char (jcs-is-infront-first-char-at-line-p)))
    (jcs-backward-word)
    (cond ((and infront-first-char (not beg-ln))
           (goto-char start-pt)
           (beginning-of-line))
          ((and (not (= start-ln (line-number-at-pos))) (not beg-ln))
           (goto-char start-pt)
           (jcs-back-to-indentation-or-beginning))
          ((>= (jcs-to-positive (- start-ln (line-number-at-pos))) 2)
           (goto-char start-pt)
           (forward-line -1)
           (end-of-line)))))

;;;###autoload
(defun jcs-smart-forward-word ()
  "Smart forward a word."
  (interactive)
  (let ((start-pt (point))
        (start-ln (line-number-at-pos))
        (behind-last-char (jcs-is-behind-last-char-at-line-p)))
    (jcs-forward-word)
    (cond ((and (not (= start-ln (line-number-at-pos)))
                (not behind-last-char))
           (goto-char start-pt)
           (end-of-line))
          ((>= (jcs-to-positive (- start-ln (line-number-at-pos))) 2)
           (goto-char start-pt)
           (forward-line 1)
           (jcs-back-to-indentation-or-beginning)))))

;;;###autoload
(defun jcs-backward-word-capital ()
  "Backward search capital character and set the cursor to the point."
  (interactive)
  (let ((max-pt -1))
    (save-excursion (jcs-smart-backward-word) (setq max-pt (1+ (point))))
    (while (and (not (jcs-is-beginning-of-buffer-p))
                (not (jcs-current-char-uppercasep))
                (> (point) max-pt))
      (backward-char 1))
    (backward-char 1)))

;;;###autoload
(defun jcs-forward-word-capital ()
  "Forward search capital character and set the cursor to the point."
  (interactive)
  (let ((max-pt -1))
    (save-excursion (jcs-smart-forward-word) (setq max-pt (point)))
    (forward-char 1)
    (while (and (not (jcs-is-end-of-buffer-p))
                (not (jcs-current-char-uppercasep))
                (< (point) max-pt))
      (forward-char 1))))

;;----------------------------------------------------------------------------
;; Move Inside Line

(defun jcs--indentation-point ()
  "Return the indentation point at the current line."
  (save-excursion (call-interactively #'back-to-indentation) (point)))

;;;###autoload
(defun jcs-back-to-indentation-or-beginning ()
  "Toggle between first character and beginning of line."
  (interactive)
  (if (= (point) (jcs--indentation-point)) (beginning-of-line) (back-to-indentation)))

;;;###autoload
(defun jcs-beginning-of-line-or-indentation ()
  "Move to beginning of line, or indentation.
If you rather it go to beginning-of-line first and to indentation on the
next hit use this version instead."
  (interactive)
  (if (bolp) (beginning-of-line) (back-to-indentation)))

;;;###autoload
(defun jcs-back-to-indentation ()
  "Back to identation by checking first character in the line."
  (interactive)
  (beginning-of-line)
  (unless (jcs-current-line-totally-empty-p) (forward-char 1))
  (while (jcs-current-whitespace-or-tab-p) (forward-char 1))
  (backward-char 1))

;;;###autoload
(defun jcs-beginning-of-visual-line ()
  "Goto the beginning of visual line."
  (interactive)
  (let ((first-line-in-non-truncate-line nil)
        (visual-line-column -1))
    ;; First, record down the beginning of visual line point.
    (save-excursion
      (call-interactively #'beginning-of-visual-line)
      (setq visual-line-column (current-column)))

    ;; Check if is the first line of non-truncate line mode.
    (when (= visual-line-column 0)
      (setq first-line-in-non-truncate-line t))

    (if first-line-in-non-truncate-line
        (call-interactively #'jcs-back-to-indentation-or-beginning)
      (let ((before-pnt (point)))
        (call-interactively #'beginning-of-visual-line)

        ;; If before point is the same as the current point.
        ;; We call regaulr `beginning-of-line' function.
        (when (= before-pnt (point))
          (call-interactively #'jcs-back-to-indentation-or-beginning))))))

;;;###autoload
(defun jcs-end-of-visual-line()
  "Goto the end of visual line."
  (interactive)
  (let ((before-pnt (point)))
    (call-interactively #'end-of-visual-line)

    ;; If before point is the same as the current point.
    ;; We call regaulr `end-of-line' function.
    (when (= before-pnt (point))
      (call-interactively #'end-of-line))))

;;;###autoload
(defun jcs-beginning-of-line ()
  "Goto the beginning of line."
  (interactive)
  (if truncate-lines
      (call-interactively #'jcs-back-to-indentation-or-beginning)
    (call-interactively #'jcs-beginning-of-visual-line)))

;;;###autoload
(defun jcs-end-of-line ()
  "Goto the end of line."
  (interactive)
  (if truncate-lines
      (call-interactively #'end-of-line)
    (call-interactively #'jcs-end-of-visual-line)))

;;;###autoload
(defun jcs-beginning-of-buffer ()
  "Goto the beginning of buffer."
  (interactive)
  (jcs-mute-apply (call-interactively #'beginning-of-buffer)))

;;;###autoload
(defun jcs-end-of-buffer ()
  "Goto the end of buffer."
  (interactive)
  (jcs-mute-apply (call-interactively #'end-of-buffer)))

;;----------------------------------------------------------------------------
;; Navigating Blank Line

(defun jcs-goto-char (pt)
  "Goto char with interactive flag enabled."
  (execute-extended-command (- pt (point)) "forward-char"))

;;;###autoload
(defun jcs-previous-blank-line ()
  "Move to the previous line containing nothing but whitespaces or tabs."
  (interactive)
  (let ((sr-pt (save-excursion (re-search-backward "^[ \t]*\n" nil t))))
    (jcs-goto-char (if sr-pt sr-pt (point-min)))))

;;;###autoload
(defun jcs-next-blank-line ()
  "Move to the next line containing nothing but whitespaces or tabs."
  (interactive)
  (when (jcs-current-line-empty-p) (forward-line 1))
  (let ((sr-pt (save-excursion (re-search-forward "^[ \t]*\n" nil t))))
    (jcs-goto-char (if sr-pt sr-pt (point-max)))
    (when sr-pt (forward-line -1))))

;;----------------------------------------------------------------------------
;; Character Navigation

(defun jcs-safe-backward-char (n)
  "Safe way to move backward N characters."
  (ignore-errors (backward-char n)))

(defun jcs-safe-forward-char (n)
  "Safe way to move forward N characters."
  (ignore-errors (forward-char n)))

(defun jcs-move-to-forward-a-char (ch)
  "Move forward to a character CH, can be regular expression."
  (ignore-errors
    (forward-char 1)
    (while (and (not (string-match-p ch (jcs-get-current-char-string)))
                (not (jcs-is-end-of-buffer-p)))
      (forward-char 1))))

(defun jcs-move-to-backward-a-char (ch)
  "Move backward to a character CH, can be regular expression."
  (ignore-errors
    (while (and (not (string-match-p ch (jcs-get-current-char-string)))
                (not (jcs-is-beginning-of-buffer-p)))
      (backward-char 1))
    (backward-char 1)))

(defun jcs-move-to-forward-a-word (word)
  "Move forward to a WORD."
  (forward-word 1)
  (while (and (not (jcs-current-word-equal-p word))
              (not (jcs-is-end-of-buffer-p)))
    (forward-word 1)))

(defun jcs-move-to-backward-a-word (word)
  "Move backward to a WORD."
  (backward-word 1)
  (while (and (not (jcs-current-word-equal-p word))
              (not (jcs-is-beginning-of-buffer-p)))
    (backward-word 1)))

;; TODO: The naming logic here is very weird..
;; Consider changing it.
(defun jcs-move-to-forward-a-char-do-recursive (ch &optional no-rec)
  "Move forward to a character and recusrive?
CH : character we target to move toward.
as NO-REC : recursive? (Default: do recusrive method)"
  (if no-rec
      (jcs-move-to-forward-a-char ch)
    (jcs-move-to-forward-a-char-recursive ch)))

;; TODO: The naming logic here is very weird..
;; Consider changing it.
(defun jcs-move-to-backward-a-char-do-recursive (ch &optional no-rec)
  "Move backward to a character and recusrive?
CH : character we target to move toward.
as NO-REC : recursive? (Default: do recusrive method)"
  (if no-rec
      (jcs-move-to-backward-a-char ch)
    (jcs-move-to-backward-a-char-recursive ch)))

;;----------------------------------------------------------------------------
;; Symbol Navigation

;;;###autoload
(defun jcs-backward-symbol (arg)
  (interactive "p")
  (forward-symbol (- arg)))

;;;###autoload
(defun jcs-forward-symbol (arg)
  (interactive "p")
  (forward-symbol arg))

;;----------------------------------------------------------------------------
;; Navigating to a Character

(defvar jcs-search-trigger-forward-char nil
  "Trigger search forward character.")
(defvar jcs-search-trigger-backward-char nil
  "Trigger search backward character.")

(defun jcs-move-to-forward-a-char-recursive (ch)
  "Move forward to a character.
CH : character we target to move toward."
  (let ((start-pt -1))
    (when jcs-search-trigger-forward-char
      (goto-char (point-min)))

    (setq jcs-search-trigger-backward-char nil)
    (setq jcs-search-trigger-forward-char nil)
    (setq start-pt (point))
    (jcs-move-to-forward-a-char ch)

    (when (jcs-is-end-of-buffer-p)
      (setq jcs-search-trigger-forward-char t)
      (goto-char start-pt)
      (message "%s"
               (propertize (concat "Failing overwrap jcs-move-to-forward-a-char-recursive: " ch)
                           'face '(:foreground "cyan"))))))

(defun jcs-move-to-backward-a-char-recursive (ch)
  "Move backward to a character.
CH : character we target to move toward."
  (let ((start-pt -1))
    (when jcs-search-trigger-backward-char
      (goto-char (point-max)))

    (setq jcs-search-trigger-backward-char nil)
    (setq jcs-search-trigger-forward-char nil)
    (setq start-pt (point))
    (jcs-move-to-backward-a-char ch)

    (when (jcs-is-beginning-of-buffer-p)
      (setq jcs-search-trigger-backward-char t)
      (goto-char start-pt)
      (message "%s"
               (propertize (concat "Failing overwrap jcs-move-to-backward-a-char-recursive: " ch)
                           'face '(:foreground "cyan"))))))


;;----------------------------------------------------------------------------
;; Move toggle Open and Close all kind of char.

(defvar jcs-search-trigger-forward-open-close-char 0
  "Trigger search forward open and close character.")
(defvar jcs-search-trigger-backward-open-close-char 0
  "Trigger search backward open and close character.")

(defun jcs-move-forward-open-close-epair (openChar closeChar)
  "Move forward to a open/close parenthesis."
  (save-window-excursion
    ;; No matter what reset the forward trigger b/c we are doing
    ;; backward search now.
    (setq jcs-search-trigger-backward-open-close-char 0)

    (let ((point-before-do-anything (point))
          (point-after-look-open-char -1)
          (point-end-of-buffer -1)
          (point-after-look-close-char -1))
      (when (looking-at openChar)
        (forward-char 1))
      (ignore-errors (while (not (looking-at openChar)) (forward-char 1)))
      (setq point-after-look-open-char (point))

      ;; back to where it start
      (goto-char point-before-do-anything)

      (when (looking-at closeChar)
        (forward-char 1))
      (ignore-errors (while (not (looking-at closeChar)) (forward-char 1)))
      (setq point-after-look-close-char (point))

      ;; record down point max and point after look
      (goto-char (point-max))
      (setq point-end-of-buffer (point))

      ;; back to where it start
      (goto-char point-before-do-anything)

      (if (> point-after-look-open-char point-after-look-close-char)
          (goto-char point-after-look-close-char)
        (goto-char point-after-look-open-char))

      (when (= jcs-search-trigger-forward-open-close-char 1)
        (goto-char (point-min))
        (setq jcs-search-trigger-forward-open-close-char 0)
        (jcs-move-forward-open-close-epair openChar closeChar))

      (when (and (= point-after-look-open-char point-end-of-buffer)
                 (= point-after-look-close-char point-end-of-buffer))
        (goto-char point-before-do-anything)
        (setq jcs-search-trigger-forward-open-close-char 1)
        (message "%s"
                 (propertize (concat "Failing overwrap jcs-move-forward-open-close-epair: '" openChar "' and '" closeChar "'")
                             'face '(:foreground "cyan")))))))

(defun jcs-move-backward-open-close-epair (openChar closeChar)
  "Move backward to a open/close parenthesis."
  (save-window-excursion
    ;; No matter what reset the forward trigger b/c we are doing
    ;; backward search now.
    (setq jcs-search-trigger-forward-open-close-char 0)

    (let ((point-before-do-anything (point))
          (point-after-look-open-char -1)
          (point-beginning-of-buffer -1)
          (point-after-look-close-char -1))
      (when (looking-at openChar)
        (forward-char -1))
      (ignore-errors  (while (not (looking-at openChar)) (backward-char 1)))
      (setq point-after-look-open-char (point))

      ;; back to where it start
      (goto-char point-before-do-anything)

      (when (looking-at closeChar)
        (forward-char -1))
      (ignore-errors  (while (not (looking-at closeChar)) (backward-char 1)))
      (setq point-after-look-close-char (point))

      ;; record down point max and point after look
      (goto-char (point-min))
      (setq point-beginning-of-buffer (point))

      ;; back to where it start
      (goto-char point-before-do-anything)

      (if (> point-after-look-open-char point-after-look-close-char)
          (goto-char point-after-look-open-char)
        (goto-char point-after-look-close-char))

      (when (= jcs-search-trigger-backward-open-close-char 1)
        (goto-char (point-max))
        (setq jcs-search-trigger-backward-open-close-char 0)
        (jcs-move-backward-open-close-epair openChar closeChar))

      (when (and (= point-after-look-open-char point-beginning-of-buffer)
                 (= point-after-look-close-char point-beginning-of-buffer))
        (goto-char point-before-do-anything)
        (setq jcs-search-trigger-backward-open-close-char 1)
        (message "%s"
                 (propertize (concat "Failing overwrap jcs-move-forward-open-close-epair: '" openChar "' and '" closeChar "'")
                             'face '(:foreground "cyan")))))))

;;----------------------------------------------------------------------------
;; Move toggle Open and Close all kind of parenthesis.

;;;###autoload
(defun jcs-move-forward-open-close-paren ()
  "Move forward to a open/close parenthesis."
  (interactive)
  (jcs-move-forward-open-close-epair "(" ")"))

;;;###autoload
(defun jcs-move-backward-open-close-paren ()
  "Move backward to a open/close parenthesis."
  (interactive)
  (jcs-move-backward-open-close-epair "(" ")"))

;;;###autoload
(defun jcs-move-forward-open-close-sqr-paren ()
  "Move forward to a open/close square parenthesis."
  (interactive)
  (jcs-move-forward-open-close-epair "[[]" "]"))

;;;###autoload
(defun jcs-move-backward-open-close-sqr-paren ()
  "Move backward to a open/close square parenthesis."
  (interactive)
  (jcs-move-backward-open-close-epair "[[]" "]"))

;;;###autoload
(defun jcs-move-forward-open-close-curly-paren ()
  "Move forward to a open/close curly parenthesis."
  (interactive)
  (jcs-move-forward-open-close-epair "{" "}"))

;;;###autoload
(defun jcs-move-backward-open-close-curly-paren ()
  "Move backward to a open/close curly parenthesis."
  (interactive)
  (jcs-move-backward-open-close-epair "{" "}"))

;;----------------------------------------------------------------------------
;; Single Quotation Mark

;;;###autoload
(defun jcs-move-forward-single-quot (&optional no-rec)
  "Move forward to a single quotation mark.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "'" no-rec))

;;;###autoload
(defun jcs-move-backward-single-quot (&optional no-rec)
  "Move backward to a single quotation mark.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "'" no-rec))

;;----------------------------------------------------------------------------
;; Double Quotation Mark

;;;###autoload
(defun jcs-move-forward-double-quot (&optional no-rec)
  "Move forward to a double quotation mark.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "\"" no-rec))

;;;###autoload
(defun jcs-move-backward-double-quot (&optional no-rec)
  "Move backward to a double quotation mark.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "\"" no-rec))

;;----------------------------------------------------------------------------
;; Open Parenthesis

;;;###autoload
(defun jcs-move-forward-open-paren (&optional no-rec)
  "Move forward to a open parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "(" no-rec))

;;;###autoload
(defun jcs-move-backward-open-paren (&optional no-rec)
  "Move backward to a open parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "(" no-rec))

;;----------------------------------------------------------------------------
;; Close Parenthesis

;;;###autoload
(defun jcs-move-forward-close-paren (&optional no-rec)
  "Move forward to a close parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive ")" no-rec))

;;;###autoload
(defun jcs-move-backward-close-paren (&optional no-rec)
  "Move backward to a close parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive ")" no-rec))

;;----------------------------------------------------------------------------
;; Open Square Parenthesis

;;;###autoload
(defun jcs-move-forward-open-sqr-paren (&optional no-rec)
  "Move forward to a open square parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "[" no-rec))

;;;###autoload
(defun jcs-move-backward-open-sqr-paren (&optional no-rec)
  "Move backward to a open square parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "[" no-rec))

;;----------------------------------------------------------------------------
;; Close Square Parenthesis

;;;###autoload
(defun jcs-move-forward-close-sqr-paren (&optional no-rec)
  "Move forward to a close square parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "]" no-rec))

;;;###autoload
(defun jcs-move-backward-close-sqr-paren (&optional no-rec)
  "Move backward to a close square parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "]" no-rec))

;;----------------------------------------------------------------------------
;; Open Curly Parenthesis

;;;###autoload
(defun jcs-move-forward-open-curly-paren (&optional no-rec)
  "Move forward to a open curly parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "{" no-rec))

;;;###autoload
(defun jcs-move-backward-open-curly-paren (&optional no-rec)
  "Move backward to a open curly parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "{" no-rec))

;;----------------------------------------------------------------------------
;; Close Curly Parenthesis

;;;###autoload
(defun jcs-move-forward-close-curly-paren (&optional no-rec)
  "Move forward to a close curly parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "}" no-rec))

;;;###autoload
(defun jcs-move-backward-close-curly-paren (&optional no-rec)
  "Move backward to a close curly parenthesis.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "}" no-rec))

;;----------------------------------------------------------------------------
;; Colon

;;;###autoload
(defun jcs-move-forward-colon (&optional no-rec)
  "Move forward to a colon.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive ":" no-rec))

;;;###autoload
(defun jcs-move-backward-colon (&optional no-rec)
  "Move backward to a colon.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive ":" no-rec))

;;----------------------------------------------------------------------------
;; Semicolon

;;;###autoload
(defun jcs-move-forward-semicolon (&optional no-rec)
  "Move forward to a semicolon.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive ";" no-rec))

;;;###autoload
(defun jcs-move-backward-semicolon (&optional no-rec)
  "Move backward to a semicolon.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive ";" no-rec))

;;----------------------------------------------------------------------------
;; Geater than sign

;;;###autoload
(defun jcs-move-forward-greater-than-sign (&optional no-rec)
  "Move forward to a greater than sign.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive ">" no-rec))

;;;###autoload
(defun jcs-move-backward-greater-than-sign (&optional no-rec)
  "Move backward to a greater than sign.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive ">" no-rec))

;;----------------------------------------------------------------------------
;; Less than sign

;;;###autoload
(defun jcs-move-forward-less-than-sign (&optional no-rec)
  "Move forward to a less than sign.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "<" no-rec))

;;;###autoload
(defun jcs-move-backward-less-than-sign (&optional no-rec)
  "Move backward to a less than sign.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "<" no-rec))

;;----------------------------------------------------------------------------
;; Comma

;;;###autoload
(defun jcs-move-forward-comma (&optional no-rec)
  "Move forward to a comma.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "," no-rec))

;;;###autoload
(defun jcs-move-backward-comma (&optional no-rec)
  "Move backward to a comma.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "," no-rec))

;;----------------------------------------------------------------------------
;; Period

;;;###autoload
(defun jcs-move-forward-period (&optional no-rec)
  "Move forward to a period.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-forward-a-char-do-recursive "." no-rec))

;;;###autoload
(defun jcs-move-backward-period (&optional no-rec)
  "Move backward to a period.
as NO-REC : recursive? (Default: do recusrive method)"
  (interactive)
  (jcs-move-to-backward-a-char-do-recursive "." no-rec))

(provide 'jcs-nav)
;;; jcs-nav.el ends here
