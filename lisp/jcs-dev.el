;;; jcs-dev.el --- Development related  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;
;; (@* "Eval" )
;;

(jcs-advice-add '(eval-buffer eval-defun eval-region) :after (deactivate-mark))

;;
;; (@* "Navigate to Error" )
;;

(defun jcs--goto-file-point--advice-anywhere (fnc &rest args)
  "Exection runs after navigate buffer that is different than the caller."
  (let ((prev-buf (current-buffer)))
    (apply fnc args)
    (unless (eq prev-buf (current-buffer))  ; Different button, recenter it.
      (jcs-recenter-top-bottom 'middle))))

(advice-add 'push-button :around #'jcs--goto-file-point--advice-anywhere)
(advice-add 'compile-goto-error :around #'jcs--goto-file-point--advice-anywhere)

;;
;; (@* "Control Output" )
;;

(defun jcs-output-list-compilation ()
  "Return the list of compilation buffers."
  (jcs-buffer-filter (format "[*]%s[*]: " jcs-compilation-base-filename) 'regex))

(defun jcs-output-set-compilation-index (index lst)
  "Set compilation buffer with INDEX and LST."
  (cond ((< index 0) (setq index (1- (length lst))))
        ((>= index (length lst)) (setq index 0)))
  (switch-to-buffer (nth index lst)))

(defun jcs-output-prev-compilation ()
  "Select the previous compilation buffer."
  (interactive)
  (let ((output-lst (jcs-output-list-compilation)) (index 0) break)
    (while (and (< index (length output-lst)) (not break))
      (when (equal (current-buffer) (nth index output-lst))
        (bury-buffer)
        (jcs-output-set-compilation-index (1- index) output-lst)
        (setq break t))
      (setq index (1+ index)))))

(defun jcs-output-next-compilation ()
  "Select the next compilation buffer."
  (interactive)
  (let ((output-lst (jcs-output-list-compilation)) (index 0) break)
    (while (and (< index (length output-lst)) (not break))
      (when (equal (current-buffer) (nth index output-lst))
        (jcs-output-set-compilation-index (1+ index) output-lst)
        (setq break t))
      (setq index (1+ index)))))

(defun jcs-output-window ()
  "Show output window."
  (interactive)
  (let ((output-lst (jcs-output-list-compilation)))
    (if (= 0 (length output-lst))
        (user-error "[INFO] No output compilation exists")
      (jcs-output-set-compilation-index 0 output-lst))))

;;
;; (@* "Build & Run" )
;;

(defun jcs-form-compilation-filename-prefix ()
  "Form the prefix of the compilation buffer name."
  (format "*%s*: " jcs-compilation-base-filename))

(defun jcs-dev-switch-to-output-buffer ()
  "Switch to one of the output buffer."
  (interactive)
  (let* ((output-prefix (jcs-form-compilation-filename-prefix))
         (output-buf-lst (jcs-get-buffers output-prefix 'string))
         choice)
    (if (not output-buf-lst)
        (user-error "[INFO] No output buffer available: %s" output-buf-lst)
      (setq choice (completing-read "Output buffer: " output-buf-lst))
      (switch-to-buffer choice))))

(defun jcs-open-project-file (in-filename title &optional ow)
  "Open the IN-FILENAME from this project with TITLE.
OW : Open it in other window."
  (let ((filepath (jcs-find-file-in-project-and-current-dir in-filename title)))
    (if ow (find-file-other-window filepath) (find-file filepath))))

(defun jcs-compile-project-file (in-filename title)
  "Compile IN-FILENAME from the project"
  (interactive)
  (let ((filepath (jcs-find-file-in-project-and-current-dir in-filename title)))
    (jcs-compile filepath)))

(defun jcs-compile (in-op)
  "Compile command rewrapper.
IN-OP : inpuit operation script."
  (require 'f)
  (let* (;; NOTE: First we need to get the script directory. In order
         ;; to change execute/workspace directory to the current target script's
         ;; directory path.
         (script-dir (f-dirname in-op))
         ;; NOTE: Change the current execute/workspace directory
         ;; to the script directory temporary. So the script will execute
         ;; within the current directory the script is currently in.
         ;;
         ;; Without these lines of code, the script will execute in the
         ;; `default-directory' variables. The `default-directory' variables
         ;; will be the directory path where you start the Emacs. For instance,
         ;; if you start Emacs at path `/usr/home', then the default directory
         ;; will be at `usr/home' directory.
         ;;
         ;; Adding these lines of code if your scirpt is at `/usr/home/project/some-script.sh',
         ;; Then your `default-directory' became `usr/home/project'. Hurray!
         (default-directory script-dir))
    ;; Compile/Execute the target script.
    (compile in-op t)
    (jcs-update-line-number-each-window)
    (with-current-buffer "*compilation*"
      (rename-buffer (format "%s%s" (jcs-form-compilation-filename-prefix) (f-filename in-op)) t))
    (message "Executing script file: '%s'" in-op)))

;;
;; (@* "Functions" )
;;

(defun jcs-make-without-asking ()
  "Make the current build."
  (interactive)
  (jcs-compile-project-file jcs-makescript "Build script: "))

(defun jcs-run-without-asking ()
  "Run the current build program."
  (interactive)
  (jcs-compile-project-file jcs-runscript "Run script: "))

(defun jcs-output-maybe-kill-buffer ()
  "Maybe kill buffer action in `output' buffer."
  (interactive)
  (let ((output-len (length (jcs-output-list-compilation))) prev-output-buf)
    (when (< 1 output-len)
      (save-window-excursion
        (jcs-output-prev-compilation)
        (setq prev-output-buf (current-buffer))))
    (jcs-maybe-kill-this-buffer)  ; Call the regular one.
    (when prev-output-buf (switch-to-buffer prev-output-buf))))

(provide 'jcs-dev)
;;; jcs-dev.el ends here