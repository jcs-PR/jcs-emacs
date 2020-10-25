;;; jcs-vimscript-mode.el --- VimScript mode. -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'vimrc-mode)

;;
;; (@* "Hook" )
;;

(defun jcs-vim-mode-hook ()
  "Vimrc mode hook."

  ;; File Header
  (jcs-insert-header-if-valid '("[.]vim"
                                "[.]vimrc"
                                "_vimrc")
                              'jcs-insert-vimscript-template)

  ;; Normal
  (define-key vimrc-mode-map (kbd "<up>") (jcs-get-prev/next-key-type 'previous))
  (define-key vimrc-mode-map (kbd "<down>") (jcs-get-prev/next-key-type 'next))

  (define-key vimrc-mode-map (kbd "C-a") #'jcs-mark-whole-buffer))

(add-hook 'vimrc-mode-hook 'jcs-vim-mode-hook)

(provide 'jcs-vimscript-mode)
;;; jcs-vimscript-mode.el ends here
