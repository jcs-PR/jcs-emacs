;;; jcs-web-func.el --- Web Development related.  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;----------------------------------------------------------------------------
;; Deletion

;;;###autoload
(defun jcs-web-kill-whole-line ()
  "Kill whole line in web-mode."
  (interactive)
  (jcs-kill-whole-line))

;;;###autoload
(defun jcs-web-kill-ring-save ()
  "Kill ring save in web-mode."
  (interactive)
  (kill-ring-save (region-beginning) (region-end)))

;;;###autoload
(defun jcs-web-yank ()
  "Yank in web-mode."
  (interactive)
  ;; NOTE: No idea why, yank function just need to get wrap by
  ;; another function...

  (jcs-delete-region)

  ;; then paste it.
  (jcs-smart-yank))

;;;###autoload
(defun jcs-web-backward-delete-word ()
  "Web backward delete the word, fit PHP variable naming."
  (interactive)
  (backward-delete-char 1)
  (when (and (not (jcs-current-whitespace-or-tab-p))
             (not (jcs-current-char-equal-p "$"))
             (jcs-current-char-a-wordp))
    (jcs-web-backward-delete-word)))

;;;###autoload
(defun jcs-web-backward-delete-word-capital ()
  "Web backward delete word capital, fit PHP variable naming."
  (interactive)
  (backward-delete-char 1)
  (when (and (not (jcs-current-whitespace-or-tab-p))
             (not (jcs-current-char-equal-p "$"))
             (not (jcs-current-char-uppercasep))
             (jcs-current-char-a-wordp))
    (jcs-web-backward-delete-word-capital))

  (when (and (jcs-current-char-uppercasep)
             (not (jcs-current-char-equal-p "$")))
    (backward-delete-char 1)))

;;----------------------------------------------------------------------------
;; Indentation

;;;###autoload
(defun jcs-web-return-key ()
  "Return key for Web mode."
  (interactive)
  (let ((did-ret-key nil) (close-tag-found nil))
    (when (and (jcs-first-forward-char-in-line-p "<")
               (jcs-first-backward-char-in-line-p ">"))
      ;; Check closing tag.
      (save-excursion
        (jcs-move-to-forward-a-char "<")
        (forward-char 1)
        (setq close-tag-found (jcs-current-char-equal-p "/")))

      (when close-tag-found
        (newline-and-indent)
        (newline-and-indent)
        (jcs-smart-indent-up)
        (setq did-ret-key t)))

    (unless did-ret-key
      (call-interactively #'jcs-smart-context-line-break))))

;;;###autoload
(defun jcs-web-vs-opening-curly-bracket-key ()
  "Web mode front curly bracket key."
  (interactive)
  (if (or (jcs-is-current-point-face "web-mode-script-face")
          (jcs-is-current-point-face "web-mode-block-face")
          (jcs-is-current-point-face "web-mode-style-face"))
      (call-interactively #'jcs-vs-opening-curly-bracket-key)
    (insert "{}")
    (backward-char 1)))

;;----------------------------------------------------------------------------
;; Impatient Mode

;;;###autoload
(defun jcs-httpd-start ()
  "Active real time editing with default port (`impatient-mode')."
  (interactive)
  (require 'impatient-mode)
  (call-interactively 'httpd-start)
  (message "Active real time editing with port: %d" httpd-port))

;;;###autoload
(defun jcs-httpd-stop ()
  "Close real time editing with default port. (`impatient-mode')"
  (interactive)
  (require 'impatient-mode)
  (call-interactively 'httpd-stop)
  (message "Close real time editing with port: %d" httpd-port))

;;----------------------------------------------------------------------------
;; Other

;;;###autoload
(defun jcs-toggle-web-mode-offsetless-elements ()
  "Toggle between indent with html tag or not to."
  (interactive)
  (if (get 'jcs-toggle-web-mode-offsetless-elements 'state)
      (progn
        (dolist (tmp-element jcs-web-mode-offsetless-elements-toggle)
          (push tmp-element web-mode-offsetless-elements))
        (put 'jcs-toggle-web-mode-offsetless-elements 'state nil))
    (dolist (tmp-element jcs-web-mode-offsetless-elements-toggle)
      (setq web-mode-offsetless-elements (remove tmp-element web-mode-offsetless-elements)))
    (put 'jcs-toggle-web-mode-offsetless-elements 'state t)))

;;;###autoload
(defun jcs-emmet-expand-line ()
  "Wrapper of `emmet-expand-line' function."
  (interactive)
  (if (jcs-is-current-point-face "link")
      (call-interactively #'goto-address-at-point)
    (unless (call-interactively #'emmet-expand-line)
      (jcs-ctrl-return-key))))

;;----------------------------------------------------------------------------

(defun jcs-init-web-faces ()
  "Initialize Web mode faces highlihgting."
  (let ((missing-modes '(web-mode)))
    (dolist (mode missing-modes)
      (font-lock-add-keywords
       mode
       '(;; For nomral HTML comment.
         ("\\(<!--[a-zA-Z0-9 \n\t-.<>?,*'`@\"=_(){}:;&^%$#!~]*-->\\)" 1 'font-lock-comment-face t)
         ("\\(@[ \t\n]*{[[:ascii:]]*\\)/\\*[[:ascii:]]*\\*/[[:ascii:]]*}" 1 'jcs-web-mode-block-face t)
         ("@[ \t\n]*{[[:ascii:]]*/\\*[[:ascii:]]*\\*/\\([[:ascii:]]*}\\)" 1 'jcs-web-mode-block-face t)
         ;; For multi-lines comment.
         ("@[ \t\n]*{[[:ascii:]]*\\(/\\*[[:ascii:]]*\\*/\\)[[:ascii:]]*}" 1 'jcs-web-mode-block-comment-face t))
       'end))))

(provide 'jcs-web-func)
;;; jcs-web-func.el ends here
