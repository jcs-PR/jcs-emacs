;; This is the start of .emacs file
;;------------------------------------------------------------------------------------------------------

;; This is my super-poopy .emacs file.
;; I barely know how to program LISP, and I know
;; even less about ELISP.  So take everything in
;; this file with a grain of salt!
;;
;; - Casey
;; - JenChieh (Modefied)


;;------------------------------------------------------------------------------------------------------
;; Auto generated by Emacs.
;;------------------------------------------------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ahs-idle-interval 0.3)
 '(auto-save-default nil)
 '(auto-save-interval 0)
 '(auto-save-list-file-prefix nil)
 '(auto-save-timeout 0)
 '(auto-show-mode t t)
 '(delete-auto-save-files nil)
 '(delete-old-versions (quote other))
 '(flymake-google-cpplint-command "C:/jcs_ide_packages/jcs_win7_packages/cpplint/cpplint.exe")
 '(helm-gtags-auto-update t)
 '(helm-gtags-ignore-case t)
 '(helm-gtags-path-style (quote relative))
 '(httpd-port 8877)
 '(imenu-auto-rescan t)
 '(imenu-auto-rescan-maxout 500000)
 '(jdee-jdk-registry
   (quote
    (("1.8.0_111" . "C:/Program Files/Java/jdk1.8.0_111"))))
 '(kept-new-versions 5)
 '(kept-old-versions 5)
 '(make-backup-file-name-function (quote ignore))
 '(make-backup-files nil)
 '(mouse-wheel-follow-mouse nil)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (15)))
 '(package-selected-packages
   (quote
    (which-key processing-mode basic-mode scala-mode floobits togetherly visual-regexp package-build package-lint auto-highlight-symbol xwidgete pdf-tools preproc-font-lock sublimity tree-mode rainbow-mode py-autopep8 multi-web-mode jdee impatient-mode iedit helm-gtags google-c-style gitlab gitignore-mode github-notifier gitconfig-mode flymake-google-cpplint flymake-cursor elpy ein cpputils-cmake cmake-project cmake-ide cmake-font-lock blank-mode better-defaults auto-package-update auto-install auto-complete-c-headers actionscript-mode ace-window ac-php ac-js2 ac-html ac-emmet)))
 '(send-mail-function (quote mailclient-send-it))
 '(version-control nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ahs-definition-face ((t (:foreground nil :background "#113D6F"))))
 '(ahs-face ((t (:foreground nil :background "#113D6F"))))
 '(ahs-plugin-defalt-face ((t (:foreground nil :background "#123E70")))))


;; ==================
;; [IMPORTANT] This should be ontop of all require packages!!!

;; start package.el with emacs
(require 'package)

;; add MELPA to repository list
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; To avoid initializing twice
(setq package-enable-at-startup nil)

;; initialize package.el
(package-initialize)

;;------------------------------------------------------------------------------------------------------
;;;
;; Auto install list of packages i want at the startup of emacs.
;;;

;; Ensure all the package installed
;; Source -> http://stackoverflow.com/questions/10092322/how-to-automatically-install-emacs-packages-by-specifying-a-list-of-package-name
(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.

Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     ;; (package-installed-p 'evil)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; make sure to have downloaded archive description.
;; Or use package-archive-contents as suggested by Nicolas Dudebout
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; How to use?
(ensure-package-installed 'actionscript-mode  ;; for text related mode
                          'ac-php             ;; auto complete php
                          'ac-html            ;; auto complete html
                          'ac-js2
                          'ac-emmet
                          'ace-window
                          'adaptive-wrap
                          'ag
                          'apache-mode
                          'auto-complete
                          'auto-complete-c-headers
                          'auto-highlight-symbol
                          'auto-install
                          'auto-package-update
                          'basic-mode
                          'better-defaults
                          'blank-mode
                          'cobol-mode
                          'company
                          'cmake-font-lock
                          'cmake-ide
                          'cmake-mode
                          'cmake-project
                          'cpputils-cmake
                          'csharp-mode
                          'dash
                          'diminish
                          'ein
                          'elpy
                          'emmet-mode
                          'exec-path-from-shell
                          'floobits
                          'flycheck
                          'flymake-cursor
                          'flymake-easy
                          'flymake-google-cpplint
                          'git-link
                          'git-messenger
                          'git-timemachine
                          'gitattributes-mode
                          'gitconfig-mode
                          'github-notifier
                          'gitignore-mode
                          'gitlab
                          'go-mode
                          'google-c-style
                          'google-maps
                          'google-this
                          'google-translate
                          'helm
                          'helm-ag
                          'helm-gtags
                          'jdee
                          'js2-mode
                          'js2-refactor
                          'json-mode
                          'lua-mode
                          'magit
                          'meghanada
                          'multiple-cursors
                          'nasm-mode
                          'neotree
                          'package-build
                          'package-lint
                          'pdf-tools
                          'php-auto-yasnippets
                          'powerline
                          'processing-mode
                          'py-autopep8
                          'python-mode
                          'rainbow-mode
                          'scala-mode
                          'shader-mode
                          'ssass-mode
                          'scss-mode
                          'sublimity
                          'sql-indent
                          'togetherly
                          'undo-tree
                          'vimrc-mode
                          'visual-regexp
                          'impatient-mode
                          'web-mode
                          'which-key
                          'wgrep-ag
                          'wgrep-helm
                          'xwidgete
                          'yasnippet)


;; activate installed packages
(package-initialize)

;;========================================
;;      JENCHIEH FILE LOADING
;;----------------------------------

;;; Environment.
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-face.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-env.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-plugin.el")

;;; Customization
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-theme.el")

;;; Initialize
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-before-init.el")

;;; Utilities
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-log.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-function.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-file-info-format.el")
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-helm.el")

;;; jcs-all-mode
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-elisp-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-cs-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-nasm-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-batch-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-sh-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-cc-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-c-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-c++-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-jayces-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-java-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-actionscript-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-python-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-web-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-js-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-json-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-lua-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-message-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-xml-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-shader-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-sass-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-scss-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-sql-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-go-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-vimscript-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-cbl-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-re-builder-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-txt-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-cmake-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-scala-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-perl-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-basic-mode.el")
(load-file "~/.emacs.d/elisp/jcs-ex/ex-mode/jcs-processing-mode.el")

;;; Do stuff after initialize.
(load-file "~/.emacs.d/elisp/jcs-ex/jcs-after-init.el")

;;------------------------------------------------------------------------------------------------------
;; This is the end of .emacs file
