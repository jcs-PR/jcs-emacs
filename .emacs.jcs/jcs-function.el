;;; jcs-function.el --- Self defines function.  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(require 'f)
(require 'helm)
(require 'linum)
(require 's)

;;----------------------------------------------
;; Beacon
;;----------------------------------------------

;;;###autoload
(defun jcs-reset-beacon-color-by-theme ()
  "Reset beacon color base on the theme color."
  (interactive)
  (if (jcs-is-light-color (face-background 'default))
      (setq beacon-color "yellow")
    (setq beacon-color 0.5)))

;;----------------------------------------------
;; Calculator
;;----------------------------------------------

;;;###autoload
(defun jcs-calc-eval-region ()
  "Eval the arithmetic expression in the region and replace it with the result."
  (interactive)
  (if (not (use-region-p))
      (message "Trying to use calc eval but with no region selected")
    (let ((val (calc-eval (buffer-substring (region-beginning) (region-end)))))
      (delete-region (region-beginning) (region-end))
      (insert val))))

;;----------------------------------------------
;; Dashboard
;;----------------------------------------------

;;;###autoload
(defun jcs-refresh-dashboard-buffer ()
  "Update dashboard buffer by killing it and start a new one."
  (interactive)
  (when (boundp 'dashboard-buffer-name)
    (let ((db-id-lst (jcs-get-window-id-by-buffer-name dashboard-buffer-name))
          (buf-pts '())
          (index 0))
      (save-selected-window
        (dolist (win-id db-id-lst)
          (jcs-ace-select-window win-id)
          (push (point) buf-pts)))
      (setq buf-pts (reverse buf-pts))
      (when (jcs-buffer-exists-p dashboard-buffer-name)
        (kill-buffer dashboard-buffer-name))
      (dashboard-insert-startupify-lists)
      (save-selected-window
        (dolist (win-id db-id-lst)
          (jcs-ace-select-window win-id)
          (switch-to-buffer dashboard-buffer-name)
          (goto-char (nth index buf-pts))
          (setq index (1+ index)))))))

;;;###autoload
(defun jcs-maybe-kill-dashboard-buffer ()
  "Kill the dashboard buffer then open the new one immediately."
  (interactive)
  (jcs-maybe-kill-this-buffer)
  (jcs-refresh-dashboard-buffer))

;;;###autoload
(defun jcs-reset-dashboard-banner-by-theme ()
  "Reset dashboard banner."
  (interactive)
  (if (jcs-is-light-color (face-background 'default))
      (setq dashboard-startup-banner "~/.emacs.jcs/banner/sink_black.png")
    (setq dashboard-startup-banner "~/.emacs.jcs/banner/sink_white.png"))
  (jcs-refresh-dashboard-buffer))

;;----------------------------------------------
;; Electric Pair
;;----------------------------------------------

(defun jcs-make-electric-pair-pairs-local (lst-pr)
  "Append a list of pair to local mode.
LST-PR: List of pair."
  (setq-local electric-pair-pairs (append electric-pair-pairs lst-pr))
  (setq-local electric-pair-text-pairs electric-pair-pairs))

;;---------------------------------------------
;; Helm
;;---------------------------------------------

;;;###autoload
(defun jcs-reset-helm-theme-by-theme ()
  "Set the theme by theme color."
  (interactive)
  (set-face-attribute 'helm-source-header nil
                      :background (face-background 'default)
                      :foreground "steel blue")
  (set-face-attribute 'helm-selection nil
                      :background (face-background 'hl-line)
                      :foreground (face-background 'cursor)))

;;---------------------------------------------
;; Iedit
;;---------------------------------------------

;;;###autoload
(defun jcs-iedit-mode ()
  "Enable Iedit mode in the safe way."
  (interactive)
  (when (and (not (jcs-current-whitespace-or-tab-p))
             (not (jcs-is-beginning-of-line-p)))
    (call-interactively #'iedit-mode)))

;;---------------------------------------------
;; Line Numbers
;;---------------------------------------------

(defun jcs-display-line-numbers-mode-exists-p ()
  "Return nil, `display-line-numbers-mode' does not exists in current Emacs version.
Return non-nil, `display-line-numbers-mode' does exists in current Emacs version."
  (version<= "26.0.50" emacs-version))

;;;###autoload
(defun jcs-reset-line-number-color-by-theme ()
  "Reset the line numbers color base on the theme."
  (interactive)
  (let ((ln-light-theme-color "#2B91AF")
        (ln-dark-theme-color "#B3B3B3"))
    (if (jcs-is-light-color (face-background 'default))
        (progn
          (when (jcs-display-line-numbers-mode-exists-p)
            (set-face-foreground 'line-number ln-light-theme-color))
          (set-face-foreground 'linum ln-light-theme-color))
      (when (jcs-display-line-numbers-mode-exists-p)
        (set-face-foreground 'line-number ln-dark-theme-color))
      (set-face-foreground 'linum ln-dark-theme-color))))

;;;###autoload
(defun jcs-update-line-number-each-window ()
  "Update each window's line number mode."
  (interactive)
  (jcs-walk-through-all-windows-once
   (lambda ()
     (jcs-active-line-numbers-by-mode))))

;;;###autoload
(defun jcs-display-line-numbers-mode (&optional act)
  "Safe enable/disable `display-line-numbers-mode'.
If non-nil, safe active `display-line-numbers-mode'."
  (interactive)
  (unless act
    (if act (setq act 1) (setq act -1)))
  (when (jcs-display-line-numbers-mode-exists-p)
    (display-line-numbers-mode act)))

;;;###autoload
(defun jcs-global-display-line-numbers-mode (&optional act)
  "Safe enable/disable `global-display-line-numbers-mode'.
If non-nil, safe active `global-display-line-numbers-mode'."
  (interactive)
  (unless act
    (if act (setq act 1) (setq act -1)))
  (when (jcs-display-line-numbers-mode-exists-p)
    (global-display-line-numbers-mode act)))

;;;###autoload
(defun jcs-active-line-numbers-by-version (&optional act g)
  "Active line number by Emacs version.
Basically decide between `linum-mode' and `display-line-numbers-mode'.
If one is activated, the other one will be deactivated.

ACT : 1 => `display-line-numbers-mode'
     -1 => `linum-mode'.
G : Active line numbers globally."
  (interactive)
  (unless act
    (if act (setq act 1) (setq act -1)))
  ;; Flag confirm line number activated.
  (if (jcs-display-line-numbers-mode-exists-p)
      (progn
        (if g
            (if (= act 1)
                (progn
                  (jcs-global-display-line-numbers-mode 1)
                  (global-linum-mode -1))
              (jcs-global-display-line-numbers-mode -1)
              (global-linum-mode 1))
          (if (= act 1)
              (progn
                (jcs-display-line-numbers-mode 1)
                (linum-mode -1))
            (jcs-display-line-numbers-mode -1)
            (linum-mode 1))))
    ;; If `display-line-numbers-mode' does not exists,
    ;; ue `linum-mode' instead.
    (linum-mode act)))

;;;###autoload
(defun jcs-deactive-line-numbers-modes (&optional g)
  "Deactive all line numbers modes.
G : Deactive line numbers globally."
  (interactive)
  (if g
      (progn
        (jcs-global-display-line-numbers-mode -1)
        (global-linum-mode 1))
    (jcs-display-line-numbers-mode -1)
    (linum-mode -1)))

;;;###autoload
(defun jcs-active-line-numbers-by-mode (&optional g)
  "Active line number by mode.
G : Active line numbers globally."
  (interactive)
  (if (or (minibufferp)
          (jcs-is-contain-list-string jcs-line-numbers-ignore-buffers (buffer-name))
          (jcs-is-contain-list-string jcs-line-numbers-ignore-modes (symbol-name major-mode)))
      ;; Don't use line numbers at all.
      (jcs-deactive-line-numbers-modes)
    (if (line-reminder-is-valid-line-reminder-situation)
        ;; Use `linum' as default.
        (jcs-active-line-numbers-by-version -1 g)
      ;; Active `display-line-numbers-mode', if Emacs version
      ;; does not have `display-line-numbers-mode' use `linum'
      ;; instead then.
      (jcs-active-line-numbers-by-version 1 g))))

;;---------------------------------------------
;; Mode Line
;;---------------------------------------------

(defvar jcs-mode-line-face-attr-height 1
  "Record down `mode-line' the face attribute height.")

(defvar jcs-mode-line-inactive-face-attr-height 1
  "Record down `mode-line-inactive' the face attribute height.")

(defvar jcs-record-mode-line-format nil
  "Record down the mode line format.")

;;;###autoload
(defun jcs-toggle-mode-line ()
  "Toggle mode line shown."
  (interactive)
  (if (stringp mode-line-format)
      (setq-default mode-line-format jcs-record-mode-line-format)
    (setq jcs-mode-line-face-attr-height (face-attribute 'mode-line :height))
    (setq jcs-mode-line-inactive-face-attr-height (face-attribute 'mode-line-inactive :height))
    (setq jcs-record-mode-line-format mode-line-format)
    (setq-default mode-line-format ""))
  (jcs-update-mode-line-face-by-mode-line-format))

(defun jcs-update-mode-line-face-by-mode-line-format ()
  "Update mode line face attributes by `mode-line-format'."
  (if (stringp mode-line-format)
      (progn
        (set-face-attribute 'mode-line nil
                            :height 0.2)
        (set-face-attribute 'mode-line-inactive nil
                            :height 0.2))
    (set-face-attribute 'mode-line nil
                        :height jcs-mode-line-face-attr-height)
    (set-face-attribute 'mode-line-inactive nil
                        :height jcs-mode-line-inactive-face-attr-height)))

;;----------------------------------------------
;; Shift Select
;;----------------------------------------------

;;;###autoload
(defun jcs-toggle-shift-select-mode ()
  "Toggle `shift-select-mode'."
  (interactive)
  (if shift-select-mode
      (jcs-disable-shift-select-mode)
    (jcs-enable-shift-select-mode)))

;;;###autoload
(defun jcs-enable-shift-select-mode ()
  "Enable `shift-select-mode'."
  (interactive)
  (setq shift-select-mode t))

;;;###autoload
(defun jcs-disable-shift-select-mode ()
  "Enable `shift-select-mode'."
  (interactive)
  (setq shift-select-mode nil))

;;----------------------------------------------
;; Speedbar
;;----------------------------------------------

(defvar jcs-speedbar-opening-buffer-file-name nil
  "Record down the current speedbar is opening which buffer.")

;;;###autoload
(defun jcs-speedbar-edit-line ()
  "Customize `speedbar-edit-line' function."
  (interactive)
  (let ((is-opening-a-file t))
    (save-excursion
      (beginning-of-line)

      ;; Weird character infront, ignore them by moving forward.
      (forward-char 1)  ;; 0
      (forward-char 1)  ;; :
      (forward-char 1)  ;; < or [, < stand for directory and [ stand for file.

      (when (jcs-current-char-equal-p "<")
        (setq is-opening-a-file nil)))

    ;; Call it normally.
    (call-interactively #'speedbar-edit-line)

    (call-interactively #'sr-speedbar-select-window)

    ;; If is file..
    (when is-opening-a-file
      (let (;; Preserve the previous selected window.
            (record-selected-window jcs-sr-speedbar-record-selected-window))
        ;; Back to previous select window.
        ;;
        ;; NOTE: This will change the previous selected window value.
        (jcs-other-window-prev)

        ;; Record the opening buffer/file down.
        (setq jcs-speedbar-opening-buffer-file-name (buffer-file-name))

        ;; Maybe kill it, because we are going to open it in originally
        ;; selected window instead of the default window after close we
        ;; the `speedbar' window.
        ;;
        ;; NOTE: This seems like it will change the
        ;; `jcs-sr-speedbar-record-selected-window', value by calling
        ;; `jcs-other-window-next' or `jcs-other-window-prev' functions.
        ;; So we also need to wrap this function inside the `let' operation.
        (jcs-maybe-kill-this-buffer)

        ;; Restore previous selected window.
        (setq jcs-sr-speedbar-record-selected-window record-selected-window))

      ;; Close the speedbar window.
      (jcs-sr-speedbar-toggle))))

(defvar jcs-sr-speedbar-window-all-on-right t
  "Make speedbar open on the right of all window.")

(defvar jcs-sr-speedbar-record-selected-window nil
  "Record down the current selected window before toggle.")

;;;###autoload
(defun jcs-sr-speedbar-toggle ()
  "Toggle the speedbar window."
  (interactive)
  (require 'sr-speedbar)
  (if (sr-speedbar-exist-p)
      (progn
        ;; Close it.
        (call-interactively #'sr-speedbar-toggle)

        ;; Go back to previous selected/editing window.
        (select-window jcs-sr-speedbar-record-selected-window)

        ;; Try to open a recorded opening file.
        (when jcs-speedbar-opening-buffer-file-name
          (find-file jcs-speedbar-opening-buffer-file-name)))
    (setq jcs-sr-speedbar-record-selected-window (selected-window))

    (let ((default-directory default-directory)
          (pro-dir (cdr (project-current))))
      ;; NOTE: Use current buffer directory as default.
      (when (buffer-file-name)
        (setq default-directory (f-dirname (buffer-file-name))))

      ;; NOTE: If found project directory, use project directory.
      (when pro-dir
        (setq default-directory pro-dir))

      ;; Esure speedbar is active.
      (call-interactively #'sr-speedbar-toggle)
      (call-interactively #'sr-speedbar-toggle)

      ;; Refresh the speedbar object after the `default-directory'
      ;; has been set.
      (call-interactively #'speedbar-refresh)

      ;; Goto very right/left of the window.
      (if jcs-sr-speedbar-window-all-on-right
          (jcs-move-to-rightmost-window nil)
        (jcs-move-to-leftmost-window nil))

      ;; Open it.
      (call-interactively #'sr-speedbar-toggle))

    ;; Select the speedbar window.
    (call-interactively #'sr-speedbar-select-window)))

(defun jcs-update-speedbar-record-after-select-new-window ()
  "Update speedbar by selecting new window."
  (when (and (functionp 'sr-speedbar-exist-p)
             (sr-speedbar-exist-p)
             (not (jcs-is-current-major-mode-p "speedbar-mode")))
    (setq jcs-sr-speedbar-record-selected-window (selected-window))))

;;----------------------------------------------
;; Sublimity Mode
;;----------------------------------------------

;;;###autoload
(defun jcs-toggle-sublimity-mode ()
  "Toggle sublimity mode and reactive line number."
  (interactive)
  (call-interactively #'sublimity-mode)
  (jcs-update-line-number-each-window))

;;----------------------------------------------
;; Syntax Check
;;----------------------------------------------

;;;###autoload
(defun jcs-flycheck-mode ()
  "Flycheck mode toggle."
  (interactive)
  (require 'flycheck)
  (if (string= (buffer-name) flycheck-error-list-buffer)
      (if (ignore-errors (jcs-jump-shown-to-buffer (buffer-name flycheck-error-list-source-buffer)))
          (jcs-flycheck-mode)
        (jcs-maybe-kill-this-buffer))
    (call-interactively #'flycheck-mode)
    (if flycheck-mode
        (call-interactively #'flycheck-list-errors)
      (save-selected-window
        (when (ignore-errors (jcs-jump-shown-to-buffer flycheck-error-list-buffer))
          (jcs-maybe-kill-this-buffer))))
    ;; STUDY: For some reason, we need to walk
    ;; through all windows once in order to display
    ;; the `flycheck-list-errors' in other window.
    (jcs-walk-through-all-windows-once)))

;;----------------------------------------------
;; Tabbar Mode
;;----------------------------------------------

;;;###autoload
(defun jcs-toggle-tabbar-mode ()
  "Toggle `tabbar-mode'."
  (interactive)
  (if tabbar-mode
      (tabbar-mode 0)
    (tabbar-mode 1))
  ;; Loop through all window so all windows take effect.
  (jcs-buffer-visible-list))

;;---------------------------------------------
;; Text Scale
;;---------------------------------------------

(defun jcs-text-scale-delta (vec)
  "Scale the text by passing `vec' value.
VEC : Either position or negative number."
  ;; NOTE: Known `text-scale-increase' and
  ;; `text-scale-decrease' ruin the margin of the
  ;; `linum-mode'. Disable it before ruining it, to
  ;; avoid the bug.
  (jcs-deactive-line-numbers-modes)
  (if (jcs-is-positive vec)
      (call-interactively #'text-scale-increase)
    (call-interactively #'text-scale-decrease))
  ;; Renable line number mode.
  (jcs-active-line-numbers-by-mode))

;;;###autoload
(defun jcs-text-scale-increase ()
  "Scale the text up."
  (interactive)
  (jcs-text-scale-delta 1))

;;;###autoload
(defun jcs-text-scale-decrease ()
  "Scale the text down."
  (interactive)
  (jcs-text-scale-delta -1))

;;----------------------------------------------
;; Tips
;;----------------------------------------------

;;;###autoload
(defun jcs-describe-thing-in-popup ()
  "Show current symbol info."
  (interactive)
  (let* ((thing (symbol-at-point))
         (help-xref-following t)
         (description (with-temp-buffer
                        (help-mode)
                        (describe-symbol thing)
                        (buffer-string)))
         (timeout 300)
         (fg-bg `(,company-quickhelp-color-foreground
                  . ,company-quickhelp-color-background)))
    (if (display-graphic-p)
        (pos-tip-show description
                      fg-bg
                      (point)
                      nil
                      timeout)
      (popup-tip description
                 :point (point)
                 :around t
                 :height 30
                 :scroll-bar t
                 :margin t))))

;;---------------------------------------------
;; Todo
;;---------------------------------------------

(defvar jcs-hl-todo-not-found-prev nil
  "See if found the previous `hl-todo' matches.")

(defvar jcs-hl-todo-not-found-next nil
  "See if found the next `hl-todo' matches.")

;;;###autoload
(defun jcs-hl-todo-previous (&optional no-prompt)
  "Around `hl-todo-previous' command.
NO-PROMPT : Don't prompt the overwrap message."
  (interactive)
  (require 'hl-todo)
  (setq jcs-hl-todo-not-found-next nil)
  (if jcs-hl-todo-not-found-prev
      (progn
        (setq jcs-hl-todo-not-found-prev nil)
        (goto-char (point-max))
        (call-interactively #'hl-todo-previous))
    (let ((before-pt (point)))
      (ignore-errors (call-interactively #'hl-todo-previous))
      (if (not (= (point) before-pt))
          (setq jcs-hl-todo-not-found-prev nil)
        (setq jcs-hl-todo-not-found-prev t)
        (if no-prompt
            (jcs-hl-todo-previous)
          (message "%s" (propertize "user-error: No more matches :: overwrap"
                                    'face '(:foreground "cyan"))))))))

;;;###autoload
(defun jcs-hl-todo-next (&optional no-prompt)
  "Around `hl-todo-next' command.
NO-PROMPT : Don't prompt the overwrap message."
  (interactive)
  (require 'hl-todo)
  (setq jcs-hl-todo-not-found-prev nil)
  (if jcs-hl-todo-not-found-next
      (progn
        (setq jcs-hl-todo-not-found-next nil)
        (goto-char (point-min))
        (call-interactively #'hl-todo-next))
    (let ((before-pt (point)))
      (ignore-errors (call-interactively #'hl-todo-next))
      (if (not (= (point) before-pt))
          (setq jcs-hl-todo-not-found-next nil)
        (setq jcs-hl-todo-not-found-next t)
        (if no-prompt
            (jcs-hl-todo-next)
          (message "%s" (propertize "user-error: No more matches :: overwrap"
                                    'face '(:foreground "cyan"))))))))

;;---------------------------------------------
;; Truncate Lines
;;---------------------------------------------

;;;###autoload
(defun jcs-enable-truncate-lines ()
  "Enable truncate lines."
  (interactive)
  (unless truncate-lines
    (toggle-truncate-lines)))

;;;###autoload
(defun jcs-disable-truncate-lines ()
  "Disable truncate lines."
  (interactive)
  (when truncate-lines
    (toggle-truncate-lines)))

;;----------------------------------------------
;; wgrep
;;----------------------------------------------

;;;###autoload
(defun jcs-ag-project-regexp ()
  "Use `wgrep' to replace the word in the entire project."
  (interactive)
  ;; open search result menu.
  (call-interactively #'ag-project-regexp)

  (other-window 1)

  ;; make result menu editable.
  (call-interactively #'wgrep-change-to-wgrep-mode))

;;----------------------------------------------
;; Yasnippet
;;----------------------------------------------

;;;###autoload
(defun jcs-yas-expand ()
  "Yasnippet expand current point."
  (interactive)
  (require 'yasnippet-snippets)
  (call-interactively #'yas-expand))


;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;; Load files.
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

;; Utilities
(require 'jcs-math)
(require 'jcs-util)
(require 'jcs-frame)
(require 'jcs-window)
(with-eval-after-load 'shell (require 'jcs-shell))
(with-eval-after-load 'sublimity (require 'jcs-minimap))
(with-eval-after-load 'helm (require 'jcs-helm-func))
(require 'jcs-message-func)

;; Editing
(require 'jcs-buffer-menu)
(require 'jcs-edit)
(require 'jcs-comment)
(require 'jcs-vs-func)

;; Navigation
(require 'jcs-nav)

;; For Specific Mode
(with-eval-after-load 're-builder (require 'jcs-re-builder-func))
(require 'jcs-preproc-func)

(with-eval-after-load 'org (require 'jcs-org-func))
(with-eval-after-load 'cc-mode
  (require 'jcs-cc-func)
  (require 'jcs-java-func))
(with-eval-after-load 'csharp-mode (require 'jcs-csharp-func))
(with-eval-after-load 'make-mode (require 'jcs-makefile-func))
(with-eval-after-load 'lua-mode (require 'jcs-lua-func))
(with-eval-after-load 'nasm-mode (require 'jcs-nasm-func))
(with-eval-after-load 'python-mode (require 'jcs-python-func))
(with-eval-after-load 'sh-script (require 'jcs-sh-func))
(with-eval-after-load 'css-mode (require 'jcs-css-func))
(with-eval-after-load 'web-mode (require 'jcs-web-func))
(with-eval-after-load 'yaml-mode (require 'jcs-yaml-func))
(require 'jcs-oop-func)


(provide 'jcs-function)
;;; jcs-function.el ends here
