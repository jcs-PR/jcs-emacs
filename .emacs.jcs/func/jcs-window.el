;;; jcs-window.el --- Window related  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;
;; (@* "Navigation" )
;;

(defun jcs-ensure-switch-to-buffer-other-window (win-name)
  "Ensure switch to buffer, try multiple times with WIN-NAME"
  (unless (or (ignore-errors (switch-to-buffer-other-window win-name)))
    (unless (or (ignore-errors (switch-to-buffer-other-window win-name)))
      (unless (or (ignore-errors (switch-to-buffer-other-window win-name)))
        (switch-to-buffer-other-window win-name)))))

(cl-defun jcs-safe-jump-shown-to-buffer (in-buffer-name &key success error type)
  "Safely jump to IN-BUFFER-NAME's window and execute SUCCESS operations.

If IN-BUFFER-NAME isn't showing; then execute ERROR operations instead.

For argument TYPE; see function `jcs-string-compare-p' for description."
  (if (not (jcs-buffer-shown-p in-buffer-name))
      (when error (funcall error))
    (save-selected-window
      (when (and (jcs-jump-shown-to-buffer in-buffer-name t type) success)
        (funcall success)))))

;;;###autoload
(defun jcs-jump-shown-to-buffer (in-buffer-name &optional no-error type)
  "Jump to the IN-BUFFER-NAME if the buffer current shown in the window.

If optional argument NO-ERROR is non-nil; then it won't trigger error.

For argument TYPE; see function `jcs-string-compare-p' for description."
  (interactive "bEnter buffer to jump to: ")
  (let (found)
    (when (jcs-buffer-shown-p in-buffer-name)
      (let ((jcs-walking-through-windows-p t) (win-len (jcs-count-windows)) (index 0))
        (while (and (< index win-len) (not found))
          ;; NOTE: we use `string-match-p' instead of `string=' because some
          ;; buffer cannot be detected in the buffer list. For instance,
          ;; `*undo-tree*' is buffer that cannot be detected for some reason.
          (if (jcs-string-compare-p in-buffer-name (jcs-buffer-name-or-buffer-file-name) type)
              (setq found t)
            (other-window 1 t))
          (setq index (1+ index)))))
    ;; If not found, prompt error.
    (when (and (not found) (not no-error))
      (user-error "[ERROR] '%s' does not shown in any window" in-buffer-name))
    found))

;;;###autoload
(defun jcs-switch-to-previous-buffer (&optional cnt)
  "Switch to previously open buffer with CNT."
  (interactive)
  (let ((target-cnt 1))  ; Default is 1.
    (when cnt (setq target-cnt cnt))
    (switch-to-buffer (other-buffer (current-buffer) target-cnt))))

;;;###autoload
(defun jcs-switch-to-next-valid-buffer ()
  "Switch to the previous buffer that are not nil."
  (interactive)
  (when (jcs-valid-buffers-exists-p)
    (let* ((lst (jcs-valid-buffer-list))
           (target-index 1)
           (target-buffer (nth target-index lst)))
      (unless target-buffer (setq target-buffer (nth 0 lst)))
      (switch-to-buffer target-buffer))))

;;;###autoload
(defun jcs-switch-to-prev-valid-buffer ()
  "Switch to the previous buffer that are not nil."
  (interactive)
  (when (jcs-valid-buffers-exists-p)
    (let* ((lst (jcs-valid-buffer-list))
           (target-index (1- (length lst)))
           (target-buffer (nth target-index lst)))
      (unless target-buffer (setq target-buffer (nth 0 lst)))
      (switch-to-buffer target-buffer))))

(defun jcs-count-windows (&optional util)
  "Total windows count.

If optional argument UTIL is non-nil; then FNC will be executed even within
inside the utility frame.  See function `jcs-frame-util-p' for the definition
of utility frame."
  (let ((jcs-walking-through-windows-p t) (count 0))
    (dolist (fn (frame-list))
      (when (or util (not (jcs-frame-util-p fn)))
        (setq count (+ (length (window-list fn)) count))))
    count))

(defun jcs-buffer-visible-list ()
  "List of buffer that current visible in frame."
  (save-selected-window
    (let ((jcs-walking-through-windows-p t) (buffers '()))
      (jcs-walk-through-all-windows-once
       (lambda () (push (buffer-name) buffers)))
      buffers)))

(defun jcs-buffer-shown-count (in-buf-name &optional type)
  "Return the count of the IN-BUF-NAME shown.

For argument TYPE; see function `jcs-string-compare-p' for description."
  (let ((bv-lst (jcs-buffer-visible-list)) (cnt 0))
    (dolist (buf bv-lst)
      (when (jcs-string-compare-p in-buf-name buf type)
        (setq cnt (1+ cnt))))
    cnt))

(defun jcs-buffer-shown-p (in-buf-name &optional type)
  "Check if IN-BUF-NAME shown in program.

For argument TYPE; see function `jcs-string-compare-p' for description."
  (>= (jcs-buffer-shown-count in-buf-name type) 1))

(defun jcs-buffer-shown-in-multiple-window-p (in-buf-name &optional type)
  "Check if IN-BUF-NAME shown in multiple windows.

For argument TYPE; see function `jcs-string-compare-p' for description."
  (>= (jcs-buffer-shown-count in-buf-name type) 2))

(defvar jcs-walking-through-windows-p nil
  "Flag to see if currently walking through windows.")

;;;###autoload
(defun jcs-walk-through-all-windows-once (&optional fnc minibuf util)
  "Walk through all windows once and execute callback FNC for each moves.

If optional argument MINIBUF is non-nil; then FNC will be executed in the
minibuffer window.

If optional argument UTIL is non-nil; then FNC will be executed even within
inside the utility frame.  See function `jcs-frame-util-p' for the definition
of utility frame."
  (interactive)
  (let ((jcs-walking-through-windows-p t))
    (save-selected-window
      (let ((win-len (jcs-count-windows)) (index 0) can-execute-p)
        (while (< index win-len)
          (setq can-execute-p
                (cond ((and (not minibuf) (jcs-minibuf-window-p)) nil)
                      (t t)))
          (when (or util (not (jcs-frame-util-p)))
            (when (and can-execute-p fnc) (funcall fnc)))
          (other-window 1 t)
          (setq index (1+ index)))))))

;;
;; (@* "Ace Window" )
;;

(defun jcs-ace-select-window (win-id)
  "Use `ace-window' to select the window by using window index, WIN-ID."
  (require 'ace-window)
  (let ((wnd (nth win-id (aw-window-list))))
    (when wnd
      (select-window wnd)
      (select-frame-set-input-focus (selected-frame)))))

;;;###autoload
(defun jcs-ace-window-min () "Select window min." (interactive) (jcs-ace-select-window 0))
;;;###autoload
(defun jcs-ace-window-max () "Select window max." (interactive) (jcs-ace-select-window (1- (length (aw-window-list)))))

;;;###autoload
(defun jcs-ace-window-1 () "Select window 1." (interactive) (jcs-ace-window-min))
;;;###autoload
(defun jcs-ace-window-2 () "Select window 2." (interactive) (jcs-ace-select-window 1))
;;;###autoload
(defun jcs-ace-window-3 () "Select window 3." (interactive) (jcs-ace-select-window 2))
;;;###autoload
(defun jcs-ace-window-4 () "Select window 4." (interactive) (jcs-ace-select-window 3))
;;;###autoload
(defun jcs-ace-window-5 () "Select window 5." (interactive) (jcs-ace-select-window 4))
;;;###autoload
(defun jcs-ace-window-6 () "Select window 6." (interactive) (jcs-ace-select-window 5))
;;;###autoload
(defun jcs-ace-window-7 () "Select window 7." (interactive) (jcs-ace-select-window 6))
;;;###autoload
(defun jcs-ace-window-8 () "Select window 8." (interactive) (jcs-ace-select-window 7))
;;;###autoload
(defun jcs-ace-window-9 () "Select window 9." (interactive) (jcs-ace-select-window 8))

;;
;; (@* "Advices" )
;;

(defun jcs--delete-window--advice-after (&rest _)
  "Advice run after execute `delete-window' function."
  (jcs-buffer-menu-safe-refresh))
(advice-add 'delete-window :after #'jcs--delete-window--advice-after)

;;
;; (@* "Column" )
;;

(defun jcs-window-type-list-in-column (type)
  "Return the list of TYPE in column.
TYPE can be 'buffer or 'window."
  (let ((type-list '()) (break nil) (windmove-wrap-around nil))
    (save-selected-window
      (jcs-move-to-upmost-window t)
      (while (not break)
        (push
         (cl-case type
           (buffer (buffer-name))
           (window (selected-window)))
         type-list)
        (setq break (not (ignore-errors (windmove-down))))))
    type-list))

(defun jcs-window-buffer-on-column-p (buf)
  "Check if BUF on same column."
  (jcs-is-contain-list-string-regexp-reverse (jcs-window-type-list-in-column 'buffer) buf))

;;
;; (@* "Deleting" )
;;

;;;###autoload
(defun jcs-balance-delete-window ()
  "Balance windows after deleting a window."
  (interactive)
  (delete-window)
  (balance-windows))

;;;###autoload
(defun jcs-delete-window-downwind ()
  "Delete window in downwind order."
  (interactive)
  (other-window -1)
  (save-selected-window (other-window 1) (delete-window)))

;;
;; (@* "Splitting" )
;;

;;;###autoload
(defun jcs-balance-split-window-horizontally ()
  "Balance windows after split window horizontally."
  (interactive)
  (split-window-horizontally)
  (balance-windows)
  (save-selected-window
    (other-window 1)
    (jcs-bury-buffer)))

;;;###autoload
(defun jcs-balance-split-window-vertically ()
  "Balance windows after split window vertically."
  (interactive)
  (split-window-vertically)
  (balance-windows)
  (save-selected-window
    (other-window 1)
    (jcs-bury-buffer)))


(defvar jcs-is-enlarge-buffer nil
  "Is any buffer in the frame enlarge already?")

(defvar-local jcs-is-enlarge-current-buffer nil
  "Is the current buffer enlarge already?")

;;;###autoload
(defun jcs-toggle-enlarge-window-selected ()
  "Toggle between show the whole buffer and current window state."
  (interactive)
  (if (and jcs-is-enlarge-current-buffer jcs-is-enlarge-buffer)
      (progn (balance-windows) (setq jcs-is-enlarge-buffer nil))
    (maximize-window)

    ;; Set all local enlarge to false.
    (jcs-setq-all-local-buffer 'jcs-is-enlarge-current-buffer nil)

    ;; Current buffer is enlarge.
    (setq-local jcs-is-enlarge-current-buffer t)

    ;; One buffer in the frame is enlarge.
    (setq jcs-is-enlarge-buffer t)))


;;;###autoload
(defun jcs-toggle-window-split-hv ()
  "Switch window split from horizontally to vertically, or vice versa.
i.e. change right window to bottom, or change bottom window to right."
  (interactive)
  (save-selected-window
    (let ((win-len (count-windows)) (windmove-wrap-around nil))
      (if (= win-len 2)
          (let ((other-win-buf nil) (split-h-now t) (window-switched nil))
            (when (or (window-in-direction 'above) (window-in-direction 'below))
              (setq split-h-now nil))

            (if split-h-now
                (when (window-in-direction 'right)
                  (windmove-right 1)
                  (setq window-switched t))
              (when (window-in-direction 'below)
                (windmove-down 1)
                (setq window-switched t)))

            (setq other-win-buf (buffer-name))
            (call-interactively #'delete-window)

            (if split-h-now
                (call-interactively #'split-window-vertically)
              (call-interactively #'split-window-horizontally))
            (other-window 1)

            (switch-to-buffer other-win-buf)

            ;; If the window is switched, switch back to original window.
            (when window-switched (other-window 1)))
        (user-error "[WARNING] Can't toggle vertical/horizontal editor layout with more than 2 windows in current frame")))))

;;
;; (@* "Util" )
;;

(defun jcs-switch-to-next-window-larger-in-height ()
  "Return the next window that have larger height in column."
  (other-window 1 t)
  (let (larger-window)
    (jcs-walk-through-all-windows-once
     (lambda ()
       (when (and (not larger-window) (jcs-window-is-larger-in-height-p))
         (setq larger-window (selected-window)))))
    larger-window))

(defun jcs-window-is-larger-in-height-p ()
  "Get the window that are larget than other windows in vertical/column."
  (let ((jcs-walking-through-windows-p t)
        (current-height (window-height)) (is-larger t))
    (dolist (win (jcs-window-type-list-in-column 'window))
      (when (> (window-height win) current-height)
        (setq is-larger nil)))
    is-larger))

;;;###autoload
(defun jcs-move-to-upmost-window (&optional not-all-frame)
  "Move to the upmost window by flag NOT-ALL-FRAME."
  (interactive)
  (if not-all-frame
      (let ((was-wrap-around windmove-wrap-around))
        (setq windmove-wrap-around nil)
        (while (ignore-errors (windmove-up)))
        (setq windmove-wrap-around was-wrap-around))
    (jcs-ace-window-min)))

;;;###autoload
(defun jcs-move-to-downmost-window (&optional not-all-frame)
  "Move to the downmost window by flag NOT-ALL-FRAME."
  (interactive)
  (if not-all-frame
      (let ((was-wrap-around windmove-wrap-around))
        (setq windmove-wrap-around nil)
        (while (ignore-errors (windmove-down)))
        (setq windmove-wrap-around was-wrap-around))
    (jcs-ace-window-max)))

;;;###autoload
(defun jcs-move-to-leftmost-window (&optional not-all-frame)
  "Move to the leftmost window by flag NOT-ALL-FRAME."
  (interactive)
  (if not-all-frame
      (let ((was-wrap-around windmove-wrap-around))
        (setq windmove-wrap-around nil)
        (while (ignore-errors (windmove-left)))
        (setq windmove-wrap-around was-wrap-around))
    (jcs-ace-window-min)))

;;;###autoload
(defun jcs-move-to-rightmost-window (&optional not-all-frame)
  "Move to the rightmost window by flag NOT-ALL-FRAME."
  (interactive)
  (if not-all-frame
      (let ((was-wrap-around windmove-wrap-around))
        (setq windmove-wrap-around nil)
        (while (ignore-errors (windmove-right)))
        (setq windmove-wrap-around was-wrap-around))
    (jcs-ace-window-max)))

;;
;; (@* "Get Window" )
;;

(defun jcs-current-window-id ()
  "Return the current window id."
  (save-selected-window
    (let ((win-id -1) (cur-wind (selected-window)) (index 0))
      (jcs-ace-window-min)
      (jcs-walk-through-all-windows-once
       (lambda ()
         (when (eq cur-wind (selected-window))
           (setq win-id index))
         (setq index (1+ index))))
      win-id)))

(defun jcs-get-window-id-by-buffer-name (buf-name)
  "Return a list of window id if match the BUF-NAME."
  (save-selected-window
    (let ((win-id-lst '()) (index 0))
      (jcs-ace-window-min)
      (jcs-walk-through-all-windows-once
       (lambda ()
         (when (string= buf-name (jcs-buffer-name-or-buffer-file-name))
           (push index win-id-lst))
         (setq index (1+ index))))
      (setq win-id-lst (reverse win-id-lst))
      win-id-lst)))

;;
;; (@* "Center" )
;;

;;;###autoload
(defun jcs-horizontal-recenter ()
  "Make the point horizontally centered in the window."
  (interactive)
  (let ((mid (/ (window-width) 2))
        (line-len (save-excursion (end-of-line) (current-column)))
        (cur (current-column)))
    (if (< mid cur)
        (set-window-hscroll (selected-window)
                            (- cur mid)))))

;;
;; (@* "Restore Windows Status" )
;;

(defvar jcs-window--record-buffer-names '() "Record all windows' buffer.")
(defvar jcs-window--record-points '() "Record all windows' point.")
(defvar jcs-window--record-first-visible-lines '()
  "Record all windows' first visible line.")

(defun jcs-window-record-once ()
  "Record windows status once."
  (let (buf-names pts f-lns)
    ;; Record down all the window information with the same buffer opened.
    (jcs-walk-through-all-windows-once
     (lambda ()
       (push (jcs-buffer-name-or-buffer-file-name) buf-names)  ; Record as string!
       (push (point) pts)
       (push (jcs-first-visible-line-in-window) f-lns)))
    ;; Reverse the order to have the information order corresponding to the window
    ;; order correctly.
    (setq buf-names (reverse buf-names) pts (reverse pts) f-lns (reverse f-lns))
    (push buf-names jcs-window--record-buffer-names)
    (push pts jcs-window--record-points)
    (push f-lns jcs-window--record-first-visible-lines)))

(defun jcs-window-restore-once ()
  "Restore windows status once."
  (let* ((buf-names (pop jcs-window--record-buffer-names)) (pts (pop jcs-window--record-points))
         (f-lns (pop jcs-window--record-first-visible-lines))
         (win-cnt 0) buf-name (current-pt -1) (current-first-vs-line -1)
         actual-buf)
    ;; Restore the window information after, including opening the same buffer.
    (jcs-walk-through-all-windows-once
     (lambda ()
       (setq buf-name (nth win-cnt buf-names)
             current-pt (nth win-cnt f-lns)
             current-first-vs-line (nth win-cnt pts)
             actual-buf (jcs-get-buffer-by-path buf-name))
       (if actual-buf (switch-to-buffer actual-buf) (find-file buf-name))
       (jcs-make-first-visible-line-to current-pt)
       (goto-char current-first-vs-line)
       (setq win-cnt (1+ win-cnt))))))

(provide 'jcs-window)
;;; jcs-window.el ends here
