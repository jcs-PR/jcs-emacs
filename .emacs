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
    (clojure-mode undo-tree ein cobol-mode tabbar javadoc-lookup typescript-mode haxe-mode yasnippet xcscope wgrep-helm wgrep-ag wgrep websocket vimrc-mode tablist sql-indent skewer-mode simple-httpd scss-mode s request-deferred request popup pkg-info php-mode php-auto-yasnippets pcache multiple-cursors memoize levenshtein json-snatcher json-reformat htmlize highlight-indentation highlight helm-core helm-ag google-translate google-this google-maps git-messenger git-commit fringe-helper flymake-easy flycheck find-file-in-project f epl emmet-mode diminish deferred cmake-mode bind-key avy auto-complete async ace-window ac-php-core ac-emmet with-editor pyvenv magit-popup js2-mode ghub dash ivy helm company apache-mode xwidgete which-key web-mode visual-regexp use-ttf use-package tree-mode togetherly sublimity ssass-mode shader-mode scala-mode rainbow-mode python-mode py-autopep8 project-abbrev processing-mode preproc-font-lock powerline pdf-tools package-lint package-build organize-imports-java neotree nasm-mode multi-web-mode meghanada magit lua-mode line-reminder json-mode js2-refactor jdee impatient-mode iedit helm-gtags haskell-mode google-c-style go-mode gitlab gitignore-mode github-notifier gitconfig-mode gitattributes-mode git-timemachine git-link flymake-google-cpplint flymake-cursor floobits exec-path-from-shell elpy csharp-mode cpputils-cmake com-css-sort cmake-project cmake-ide cmake-font-lock better-defaults basic-mode auto-package-update auto-highlight-symbol auto-complete-c-headers all-the-icons ag adaptive-wrap actionscript-mode ac-php ac-js2 ac-html)))
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
(ensure-package-installed 'ac-emmet
                          'ac-html            ;; auto complete html
                          'ac-js2
                          'ac-php             ;; auto complete php
                          'ace-window
                          'actionscript-mode
                          'adaptive-wrap
                          'ag
                          'all-the-icons
                          'apache-mode
                          'auto-complete
                          'auto-complete-c-headers
                          'auto-highlight-symbol
                          'auto-package-update
                          'basic-mode
                          'better-defaults
                          'clojure-mode
                          'cmake-font-lock
                          'cmake-ide
                          'cmake-mode
                          'cmake-project
                          'cobol-mode
                          'com-css-sort
                          'company
                          'cpputils-cmake
                          'csharp-mode
                          'dash
                          'diminish
                          'ein
                          'elpy
                          'emmet-mode
                          'exec-path-from-shell
                          'find-file-in-project
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
                          'haskell-mode
                          'helm
                          'helm-ag
                          'helm-gtags
                          'javadoc-lookup
                          ;; TEMPORARY(jenchieh): Hopefully melpa will let me push
                          ;; my package `jayces-mode' to their package system.
                          ;; Then we can add this line under directly.
                          ;;'jayces-mode
                          ;; TEMPORARY(jenchieh): Hopefully melpa will let me push
                          ;; my package `jcs-ex-pkg' to their package system.
                          ;; Then we can add this line under directly.
                          ;;'jcs-ex-pkg
                          'jdee
                          'js2-mode
                          'js2-refactor
                          'json-mode
                          'line-reminder
                          'lua-mode
                          'magit
                          'meghanada
                          'multiple-cursors
                          'nasm-mode
                          'neotree
                          'organize-imports-java
                          'package-build
                          'package-lint
                          'pdf-tools
                          'php-auto-yasnippets
                          'powerline
                          'processing-mode
                          'project-abbrev
                          'py-autopep8
                          'python-mode
                          'rainbow-mode
                          'scala-mode
                          'shader-mode
                          'ssass-mode
                          'scss-mode
                          'sublimity
                          'sql-indent
                          'tabbar
                          'togetherly
                          'typescript-mode
                          'undo-tree
                          'use-package
                          'use-ttf
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
;;         Manually Install
;;----------------------------------

(load-file "~/.emacs.d/elisp/verilog-mode.el")

;;
;; TEMPORARY(jenchieh): Hopefully melpa will let me push
;; my package `jcs-ex-pkg' to their package system.
;; Then we can remove load file/manually install package system.
;;
(load-file "~/.emacs.d/elisp/jcs-ex-pkg-20180705.001/jcs-ex-pkg.el")

;;
;; TEMPORARY(jenchieh): Hopefully melpa will let me push
;; my package `jayces-mode' to their package system.
;; Then we can remove load file/manually install package system.
;;
(load-file "~/.emacs.d/elisp/jayces-mode-20181011.001/jayces-mode.el")

;;========================================
;;      JENCHIEH FILE LOADING
;;----------------------------------

;;; Environment.
(load-file "~/.emacs.jcs/jcs-face.el")
(load-file "~/.emacs.jcs/jcs-dev.el")
(load-file "~/.emacs.jcs/jcs-env.el")
(load-file "~/.emacs.jcs/jcs-plugin.el")

;;; Customization
(load-file "~/.emacs.jcs/jcs-theme.el")

;;; Initialize
(load-file "~/.emacs.jcs/jcs-before-init.el")

;;; Utilities
(load-file "~/.emacs.jcs/jcs-log.el")
(load-file "~/.emacs.jcs/jcs-package.el")
(load-file "~/.emacs.jcs/jcs-function.el")
(load-file "~/.emacs.jcs/jcs-corresponding-file.el")
(load-file "~/.emacs.jcs/jcs-mode.el")
(load-file "~/.emacs.jcs/jcs-file-info-format.el")
(load-file "~/.emacs.jcs/jcs-helm.el")

;;; Modes
(load-file "~/.emacs.jcs/mode/jcs-elisp-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-cs-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-nasm-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-batch-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-sh-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-cc-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-c-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-c++-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-jayces-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-java-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-actionscript-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-python-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-web-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-js-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-json-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-lua-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-message-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-xml-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-shader-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-sass-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-scss-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-sql-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-go-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-vimscript-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-cbl-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-re-builder-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-txt-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-cmake-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-scala-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-perl-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-basic-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-processing-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-shell-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-haskell-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-haxe-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-typescript-mode.el")
(load-file "~/.emacs.jcs/mode/jcs-clojure-mode.el")

;; Add hook to all Emacs' events.
(load-file "~/.emacs.jcs/jcs-hook.el")

;; Set default font.
(load-file "~/.emacs.jcs/jcs-font.el")

;;; Do stuff after initialize.
(load-file "~/.emacs.jcs/jcs-after-init.el")

;;------------------------------------------------------------------------------------------------------
;; This is the end of .emacs file
(put 'erase-buffer 'disabled nil)
