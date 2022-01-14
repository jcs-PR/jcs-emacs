;;; test-speed.el --- Test the configuration  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'package)
(package-initialize)

(load (concat user-emacs-directory "bin/test-startup.el"))

(message "[INFO] %s" dashboard-init-info)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
;;; test-speed.el ends here