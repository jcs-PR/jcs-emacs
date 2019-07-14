;;; jcs-shell.el --- Shell function.  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;;;###autoload
(defun jcs-show-shell-window ()
  "Shell Command prompt."
  (interactive)
  (unless (get-buffer-process jcs-shell-buffer-name)
    (split-window-below)

    ;; TODO: I have no idea why the first time would not work.
    ;; So I have to error handle it and do it again to just in
    ;; if something weird happen to Emacs itself.
    ;;
    ;; NOTE: Call it multiple time to just in case the shell
    ;; process will run.
    (jcs-ensure-switch-to-buffer-other-window jcs-shell-buffer-name)

    (erase-buffer)
    ;; Run shell process.
    (cond ((equal jcs-prefer-shell-type 'shell) (shell))
          ((equal jcs-prefer-shell-type 'eshell) (eshell)))

    ;; active truncate line as default for shell window.
    (jcs-disable-truncate-lines)))

;;;###autoload
(defun jcs-hide-shell-window ()
  "Kill process prompt."
  (interactive)
  (if (ignore-errors (jcs-jump-shown-to-buffer jcs-shell-buffer-name))
      (progn
        (kill-process jcs-shell-buffer-name)
        (kill-buffer jcs-shell-buffer-name)
        (delete-window))
    (error (format "No \"%s\" buffer found" jcs-shell-buffer-name))))

;;;###autoload
(defun jcs-maybe-kill-shell ()
  "Ask to make sure the user want to kill shell."
  (interactive)
  (if (ignore-errors (jcs-jump-shown-to-buffer jcs-shell-buffer-name))
      (when (yes-or-no-p (format "Buffer \"%s\" has a running process; kill it? " jcs-shell-buffer-name))
        (jcs-toggle-shell-window))
    (jcs-maybe-kill-this-buffer)))

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; Shell Commands
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;;;###autoload
(defun jcs-shell-clear-command ()
  "Clear buffer and make new command prompt."
  (interactive)
  (erase-buffer)
  (comint-send-input))

;;;###autoload
(defun jcs-shell-return ()
  "Shell mode's return key."
  (interactive)
  ;; Goto the end of the command line.
  (goto-char (point-max))

  ;; STUDY: This actually does not goes to the
  ;; beginning of line. It actually goto the
  ;; start of the command prompt. Which mean
  ;; we do not have to code ourselves to the
  ;; start of command line.
  ;;
  ;; >>> Image: <<<
  ;;                             ┌─ It will jump to this point.
  ;; ┌─ In general, will goto    │
  ;; │ this point.               │
  ;; ▼                           ▼
  ;; `c:\to\some\example\dir\path>'
  (beginning-of-line)

  (let ((command-start-point nil)
        (command-string ""))
    (setq command-start-point (point))

    ;; Get the string start from command to end of command.
    (setq command-string (buffer-substring command-start-point (point-max)))

    ;; Execute the command.
    (cond ((string= command-string "exit")
           (progn
             ;; Here toggle, actually close the terminal itself.
             (jcs-toggle-shell-window)))
          ((or (string= command-string "clear")
               (string= command-string "cls"))
           (progn
             ;; Clear the terminal once.
             (jcs-shell-clear-command)))
          ;; Else just send the command to terminal.
          (t
           (progn
             ;; Call default return key.
             (comint-send-input))))))

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; Deletion
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

(defvar jcs-shell-highlight-face-name "comint-highlight-prompt"
  "Face name in shell mode that we do not want to delete.")

(defun jcs-shell-is-current-on-command ()
  "Return non-nil if current on command line."
  (let ((is-shell-prompt-char nil))
    (save-excursion
      (backward-char 1)
      (setq is-shell-prompt-char
            (jcs-is-current-point-face jcs-shell-highlight-face-name)))
    (and (jcs-last-line-in-buffer-p)
         (not (jcs-is-beginning-of-line-p))
         (not is-shell-prompt-char))))

;;;###autoload
(defun jcs-shell-backspace ()
  "Backspace key in shell mode."
  (interactive)
  ;; Only the last line of buffer can do deletion.
  (when (jcs-shell-is-current-on-command)
    (backward-delete-char 1)))

;;;###autoload
(defun jcs-shell-kill-whole-line ()
  "Kill whole line in shell mode."
  (interactive)
  ;; Directly jump to the end of the buffer.
  (goto-char (point-max))
  ;; Delete eveything from current command line.
  (while (and (not (jcs-is-current-point-face jcs-shell-highlight-face-name))
              (not (jcs-is-beginning-of-line-p)))
    (backward-delete-char 1)))


;;;###autoload
(defun jcs-shell-backward-delete-word ()
  "Shell mode's version of backward delete word."
  (interactive)
  (when (jcs-shell-is-current-on-command)
    (call-interactively 'jcs-backward-delete-word)))

;;;###autoload
(defun jcs-shell-forward-delete-word ()
  "Shell mode's version of forward delete word."
  (interactive)
  (when (jcs-shell-is-current-on-command)
    (call-interactively 'jcs-forward-delete-word)))


;;;###autoload
(defun jcs-shell-backward-kill-word-capital ()
  "Shell mode's version of forward delete word."
  (interactive)
  (when (jcs-shell-is-current-on-command)
    (call-interactively 'jcs-backward-kill-word-capital)))

;;;###autoload
(defun jcs-shell-forward-kill-word-capital ()
  "Shell mode's version of forward delete word."
  (interactive)
  (when (jcs-shell-is-current-on-command)
    (call-interactively 'jcs-forward-kill-word-capital)))

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; Navigation
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;;;###autoload
(defun jcs-shell-up-key ()
  "Shell mode up key."
  (interactive)
  (if (or (jcs-shell-is-current-on-command)
          (jcs-is-end-of-buffer-p))
      (comint-previous-input 1)
    (jcs-previous-line))
  (when (jcs-last-line-in-buffer-p)
    (goto-char (point-max))))

;;;###autoload
(defun jcs-shell-down-key ()
  "Shell mode down key."
  (interactive)
  (if (or (jcs-shell-is-current-on-command)
          (jcs-is-end-of-buffer-p))
      (comint-next-input 1)
    (jcs-next-line))
  (when (jcs-last-line-in-buffer-p)
    (goto-char (point-max))))

;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; Completion
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;;;###autoload
(defun jcs-company-manual-begin ()
  "Completion for the shell command."
  (interactive)
  (goto-char (point-max))
  ;; Call default completion function.
  (call-interactively #'company-manual-begin))


(provide 'jcs-shell)
;;; jcs-shell.el ends here
