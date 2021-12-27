;;; .emacs --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:

;; Author:  Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL:     https://github.com/jcs-emacs/jcs-emacs

;;
;;                      ════╦╦╦╦╗
;;                  ╔═══════╩╩╩╩╩═════╗
;;                ══╝ ╔═════════════╗ ║
;;          ════════════════════════╬═╬══╗
;;           \   ╔══╗ ╓  ╥ ╥  ╥     ║ ╚══╬════
;;            ║  ║ ═╦ ║\ ║ ║  ║     ╚════╬════
;;            ║  ╚══╝ ╨ `╜ ╚══╝          ║
;;            ║   ╔══ ╔╗╔╗ ╔═╗ ╔═╕ ╔═╕   ║
;;            ║   ╠═  ║╙╜║ ╟─╢ ║   ╚═╗   ║
;;            ║   ╚══ ╨  ╨ ╨ ╨ ╚═╛ ╘═╝   ║
;;              \═══════════╣  ╠════════/
;;                 ═════════╝  ║
;;                 ════════════╝
;;
;;                [J C S - E M A C S]
;;

;; This file bootstraps the configuration, which is divided into a number of
;; other files.
;;
;; License: BSD-2-Clause

;;; Code:

;;
;; (@* "Startup" )
;;

(defconst jcs-min-require-version "27.1"
  "Minimum required Emacs version for `JCS` configuration.")

(when (version< emacs-version jcs-min-require-version)
  (error (format "This requires Emacs %s and above!" jcs-min-require-version)))

(defconst jcs-gc-cons-threshold (* 1024 1024 20)
  "The default value to use for `gc-cons-threshold'. If you experience freezing,
decrease this. If you experience stuttering, increase this.")

(defconst jcs-gc-cons-upper-limit (* 1024 1024 128)
  "The temporary value for `gc-cons-threshold' to defer it.")

(defun jcs-gc-cons-threshold-speed-up (speedup)
  "Raise/Lower GC threshold by SPEEDUP."
  (setq gc-cons-threshold (if speedup jcs-gc-cons-upper-limit jcs-gc-cons-threshold)))

(jcs-gc-cons-threshold-speed-up t)  ; Raise GC when starting Emacs!

(defconst jcs-file-name-handler-alist file-name-handler-alist
  "Record file name handler alist.")

;;
;; (@* "Optimizations" )
;;

(setq file-name-handler-alist nil)

;; A second, case-insensitive pass over `auto-mode-alist' is time wasted, and
;; indicates misconfiguration (don't rely on case insensitivity for file names).
(setq auto-mode-case-fold nil)

;; More performant rapid scrolling over unfontified regions. May cause brief
;; spells of inaccurate syntax highlighting right after scrolling, which should
;; quickly self-correct.
(setq fast-but-imprecise-scrolling t)

;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)

;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we halve startup times, particularly when we use
;; fonts that are larger than the system default (which would resize the frame).
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Emacs "updates" its ui more often than it needs to, so slow it down slightly
(setq idle-update-delay 1.0)  ; default is 0.5

;; Font compacting can be terribly expensive, especially for rendering icon
;; fonts on Windows. Whether disabling it has a notable affect on Linux and Mac
;; hasn't been determined, but do it there anyway, just in case. This increases
;; memory usage, however!
(setq inhibit-compacting-font-caches t)

;; Increase how much is read from processes in a single chunk (default is 4kb).
;; This is further increased elsewhere, where needed (like our LSP module).
(setq read-process-output-max (* 1024 1024))  ; 1MB

;; Introduced in Emacs HEAD (b2f8c9f), this inhibits fontification while
;; receiving input, which should help a little with scrolling performance.
(setq redisplay-skip-fontification-on-input t)

;; Reduce *Message* noise at startup. An empty scratch buffer (or the dashboard)
;; is more than enough.
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      inhibit-default-init t)

;;
;; (@* "Version" )
;;

(defconst jcs-emacs-version-number "7.1.0"
  "JCS-Emacs version.")

(defun jcs-emacs-version ()
  "Show JCS-Emacs version info."
  (interactive)
  (message "JCS-Emacs %s" jcs-emacs-version-number))

;;
;; (@* "Load Core" )
;;

(setq load-path (append '("~/.emacs.jcs/"
                          "~/.emacs.jcs/func/"
                          "~/.emacs.jcs/mode/")
                        load-path))

;;; Initialize
(require 'jcs-package)
(jcs-package-install-all)

;;; Utilities
(require 'jcs-log)
(require 'jcs-face)
(require 'jcs-function)

;;; Environment
(require 'jcs-file)
(require 'jcs-dev)
(require 'jcs-env)
(require 'jcs-theme)
(require 'jcs-plugin)

;;; Standardize
(require 'jcs-template)
(require 'jcs-mode)
(require 'jcs-project)

;;; Finalize
(require 'jcs-minibuf)
(require 'jcs-hook)
(require 'jcs-key)

;;; Customize
(require 'jcs-config)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
;;; .emacs ends here
