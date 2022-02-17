;;; jcs-buffer-menu.el --- Functions in buffer menu mode  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'buffer-menu-project)

;;
;; (@* "Diminish" )
;;

(defvar jcs-buffer-menu-diminish-list
  (append
   '("[*]Minibuf-" "[*]Buffer List[*]" "[*]Echo Area"
     "[*]http"
     "[*]code-conversion-work[*]" "[*]code-converting-work[*]"
     "[*]company-"
     "[*]tip[*]"
     "[*]diff-hl"
     "[*]Treemacs-Scoped-Buffer"
     "[*]pfuture stderr"))
  "List of buffers that are diminished by default.")

(defun jcs-buffer-menu--buffer-list (&optional buffer-list)
  "Return a list of buffers that only shows in buffer menu.

If optional argument BUFFER-LIST is non-nil, use this buffer list instead."
  (cl-remove-if
   (lambda (buf)
     (jcs-contain-list-type-str (buffer-name buf) jcs-buffer-menu-diminish-list 'regex))
   (or buffer-list (buffer-list))))

(defun jcs-buffer-menu--diminish-buffer-list (&optional buffer-list)
  "Return a list of diminished buffer.

If optional argument BUFFER-LIST is non-nil, use this buffer list instead."
  (cl-remove-if
   (lambda (buf)
     (jcs-contain-list-type-str (buffer-name buf) diminish-buffer-list 'regex))
   (jcs-buffer-menu--buffer-list buffer-list)))

;;
;; (@* "Customization" )
;;

(defconst jcs-buffer-menu--default-project-value ""
  "Default value for project column.")

(defun jcs-buffer-menu--name-width (&optional buffer-list)
  "Return max buffer name width by BUFFER-LIST."
  (jcs-buffer-menu--header-width
   "Buffer " (if diminish-buffer-mode
                 (jcs-buffer-menu--diminish-buffer-list buffer-list)
               (jcs-buffer-menu--buffer-list buffer-list))
   2))

(defun jcs-buffer-menu--project-width ()
  "Return max project width."
  (require 'f)
  (max (length jcs-buffer-menu--default-project-value)
       (jcs-buffer-menu--header-width "Project " (f-uniquify (jcs-project-opened-projects)))))

(defun jcs-buffer-menu--size-width (buffer-list)
  "Return max buffer size width by BUFFER-LIST."
  (jcs-buffer-menu--header-width
   "Size " (let (sizes)
             (dolist ( buf (or buffer-list (buffer-list)))
               (push (number-to-string (buffer-size buf)) sizes))
             sizes)))

(defun jcs-buffer-menu--header-width (name lst &optional extra)
  "Return the width by NAME and LST."
  (let ((extra (or extra 0)) (min-size (length name)))
    (+ (max min-size (or (jcs-list-max lst) min-size)) extra)))

(defun jcs-buffer-menu--show-project-p ()
  ""
  (and (jcs-project-opened-projects) (not buffer-menu-project-buffers)))

(defun jcs--list-buffers--refresh (&optional buffer-list old-buffer &rest _)
  "Override function `list-buffers--refresh'."
  (let ((name-width (jcs-buffer-menu--name-width buffer-list))
        (size-width (jcs-buffer-menu--size-width buffer-list))
        (marked-buffers (Buffer-menu-marked-buffers))
        (buffer-menu-buffer (current-buffer))
        (show-non-file (not Buffer-menu-files-only))
        entries)
    ;; Handle obsolete variable:
    (if Buffer-menu-buffer+size-width
        (setq name-width (- Buffer-menu-buffer+size-width size-width)))
    (setq tabulated-list-format
          (vector '("C" 1 t :pad-right 0)
                  '("R" 1 t :pad-right 0)
                  '("M" 1 t)
                  `("Buffer" ,name-width t)
                  (when (jcs-buffer-menu--show-project-p)
                    `("Project" ,(jcs-buffer-menu--project-width) t))
                  `("Size" ,size-width tabulated-list-entry-size-> :right-align t)
                  `("Mode" ,Buffer-menu-mode-width t)
                  '("File" 1 t))
          tabulated-list-format (cl-remove-if #'null tabulated-list-format))
    (setq tabulated-list-use-header-line Buffer-menu-use-header-line)
    ;; Collect info for each buffer we're interested in.
    (dolist (buffer (or buffer-menu-project-buffers
                        buffer-list
                        (buffer-list (if Buffer-menu-use-frame-buffer-list
                                         (selected-frame)))))
      (with-current-buffer buffer
        (let* ((name (buffer-name))
               (file buffer-file-name))
          (when (and (buffer-live-p buffer)
                     (or buffer-list
                         (and (or (not (string= (substring name 0 1) " "))
                                  file)
                              (not (eq buffer buffer-menu-buffer))
                              (or file show-non-file))))
            (push (list buffer
                        (cl-remove-if
                         #'null
                         (vector (cond
                                  ((eq buffer old-buffer) ".")
                                  ((member buffer marked-buffers) ">")
                                  (t " "))
                                 (if buffer-read-only "%" " ")
                                 (if (buffer-modified-p) "*" " ")
                                 (Buffer-menu--pretty-name name)
                                 (when (jcs-buffer-menu--show-project-p)
                                   (or (jcs-project-current-uniquify) jcs-buffer-menu--default-project-value))
                                 (number-to-string (buffer-size))
                                 (concat (format-mode-line mode-name
                                                           nil nil buffer)
                                         (if mode-line-process
                                             (format-mode-line mode-line-process
                                                               nil nil buffer)))
                                 (Buffer-menu--pretty-file-name file))))
                  entries)))))
    (setq tabulated-list-entries (nreverse entries)))
  (tabulated-list-init-header))

(advice-add 'list-buffers--refresh :override #'jcs--list-buffers--refresh)

;;
;; (@* "Search / Filter" )
;;

(defun jcs-buffer-menu-return ()
  "Implemenetation for `buffer menu`'s return key."
  (interactive)
  (if jcs--buffer-menu--done-filtering
      (progn
        (ignore-errors (Buffer-menu-this-window))
        (if (jcs-buffer-menu-p)
            (user-error "No buffer on this line")
          (message nil)))  ; Use to clear `[Display not ready]'.
    (setq jcs--buffer-menu-return-delay t)
    (message "[Display not ready]")))


(defvar jcs--buffer-menu--score-standard 0
  "Standard score that minimum to reach, or else delete it.
From scale 0 to 100.")

(defvar jcs--buffer-menu--done-filtering t
  "Flag to check if done filtering.")

(defvar jcs--buffer-menu--filter-timer nil
  "Store filter timer function.")

(defvar jcs--buffer-menu--filter-delay 0.1
  "Filter delay time.")

(defvar jcs--buffer-menu--pattern ""
  "Search pattern.")


(defun jcs--safe-print-fake-header ()
  "Safe way to print fake header."
  (unless (tabulated-list-header-overlay-p)
    (tabulated-list-print-fake-header)))

(defun jcs--buffer-menu-clean ()
  "Clean all the menu list."
  (goto-char (point-min))
  (while (< (line-number-at-pos) (line-number-at-pos (point-max)))
    (if (tabulated-list-get-id) (tabulated-list-delete-entry) (forward-line 1))))

(defun jcs--buffer-menu-filter-list ()
  "Do filtering the buffer list."
  (jcs-require '(flx ht))
  (with-current-buffer jcs-buffer-menu-buffer-name
    (let ((scoring-table (ht-create)) scoring-keys)
      (while (< (line-number-at-pos) (line-number-at-pos (point-max)))
        (let* ((id (tabulated-list-get-id))
               (entry (tabulated-list-get-entry))
               (buf-name (buffer-name id))
               (scoring (flx-score buf-name jcs--buffer-menu--pattern))
               ;; Ensure score is not `nil'
               (score (cond ((listp scoring) (nth 0 scoring))
                            ((vectorp scoring) (aref scoring 0))
                            ((numberp scoring) scoring)
                            (t 0))))
          (when score
            (push (cons id entry) (ht-get scoring-table score))))
        (forward-line 1))
      ;; Get all the keys into a list.
      (ht-map (lambda (score-key _) (push score-key scoring-keys)) scoring-table)
      (setq scoring-keys (sort scoring-keys #'>))  ; Sort keys in order
      (jcs--buffer-menu-clean)  ; Clean it
      (dolist (key scoring-keys)
        (when (< jcs--buffer-menu--score-standard key)
          (let ((ens (sort (ht-get scoring-table key)
                           (lambda (en1 en2)
                             (let ((en1-str (buffer-name (car en1)))
                                   (en2-str (buffer-name (car en2))))
                               (string-lessp en1-str en2-str))))))
            (dolist (en ens)
              (tabulated-list-print-entry (car en) (cdr en))))))
      (jcs-goto-line 2))
    (setq jcs--buffer-menu--done-filtering t)
    (jcs--safe-print-fake-header)
    ;; Once it is done filtering, we redo return action if needed.
    (when jcs--buffer-menu-return-delay (jcs-buffer-menu-return))))

(defun jcs--buffer-menu--update-header-string ()
  "Update the header string."
  (let ((title jcs--buffer-menu-search-title))
    (when buffer-menu-project-name
      (setq title (concat "[%s] " title)
            title (format title buffer-menu-project-name)))
    (when (> (length title) (length tabulated-list--header-string))
      (setq-local tabulated-list--header-string title))
    (setq jcs--buffer-menu--pattern (substring tabulated-list--header-string
                                               (length title)
                                               (length tabulated-list--header-string)))))

(defun jcs--buffer-menu-trigger-filter ()
  "Trigger the filtering operation, with PRINT-HEADER."
  (tabulated-list-revert)
  (jcs--buffer-menu--update-header-string)
  (jcs--safe-print-fake-header)
  (unless (string-empty-p jcs--buffer-menu--pattern)
    (setq jcs--buffer-menu--filter-timer (jcs-safe-kill-timer jcs--buffer-menu--filter-timer)
          jcs--buffer-menu--done-filtering nil
          jcs--buffer-menu--filter-timer
          (run-with-idle-timer jcs--buffer-menu--filter-delay
                               nil #'jcs--buffer-menu-filter-list))))

(defun jcs--buffer-menu-input (key-input &optional add-del-num)
  "Insert key KEY-INPUT for fake header for search bar.
ADD-DEL-NUM : Addition or deletion number."
  (unless jcs--buffer-menu--first-enter
    (jcs--buffer-menu--update-header-string)
    (setq jcs--buffer-menu--first-enter t))
  (unless add-del-num (setq add-del-num (length key-input)))
  (if (> add-del-num 0)
      (setq tabulated-list--header-string
            (concat tabulated-list--header-string key-input))
    (setq tabulated-list--header-string
          (substring tabulated-list--header-string 0 (1- (length tabulated-list--header-string)))))
  (jcs--buffer-menu-trigger-filter))

(provide 'jcs-buffer-menu)
;;; jcs-buffer-menu.el ends here
