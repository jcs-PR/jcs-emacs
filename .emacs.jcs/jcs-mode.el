;;; jcs-mode.el --- Self mode defines  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;
;; (@* "Mode State" )
;;

(defvar jcs-mode--state nil
  "Record the state of the current mode.")

(defun jcs-mode-reset-state ()
  "Reset mode state."
  (setq jcs-mode--state nil))

(defun jcs-mode-stats-p (state)
  "Check mode STATE."
  (equal jcs-mode--state state))

(defun jcs-depend-cross-mode-toggle ()
  "Toggle depend/cross mode."
  (interactive)
  (unless (minibufferp)
    (if (jcs-mode-stats-p 'cross) (jcs-depend-mode) (jcs-cross-mode))))

(defun jcs-reload-active-mode ()
  "Reload the active mode.
Note this is opposite logic to the toggle mode function."
  (interactive)
  (jcs-mute-apply
    (let ((mode-state jcs-mode--state))
      (jcs-mode-reset-state)
      (cl-case mode-state
        (`cross  (jcs-cross-mode))
        (`depend (jcs-depend-mode))))))

(defun jcs-buffer-spaces-to-tabs ()
  "Check if buffer using spaces or tabs."
  (if (= (how-many "^\t" (point-min) (point-max)) 0) "SPC" "TAB"))

(defun jcs-use-cc-style-comment ()
  "Use c-style commenting instead of two slashes."
  (setq-local comment-start "/*"
              comment-start-skip "/\\*+[ \t]*"
              comment-end "*/"
              comment-end-skip "[ \t]*\\*+/"))

(defun jcs-use-cc-mutliline-comment ()
  "Fixed multiline comment."
  (require 'typescript-mode)
  (setq-local indent-line-function 'typescript-indent-line)
  (setq c-comment-prefix-regexp "//+\\|\\**"
        c-paragraph-start "$"
        c-paragraph-separate "$"
        c-block-comment-prefix "* "
        c-line-comment-starter "//"
        c-comment-start-regexp "/[*/]\\|\\s!"
        comment-start-skip "\\(//+\\|/\\*+\\)\\s *")
  (let ((c-buffer-is-cc-mode t))
    (make-local-variable 'paragraph-start)
    (make-local-variable 'paragraph-separate)
    (make-local-variable 'paragraph-ignore-fill-prefix)
    (make-local-variable 'adaptive-fill-mode)
    (make-local-variable 'adaptive-fill-regexp)
    (c-setup-paragraph-variables)))

;;
;; (@* "License" )
;;

(defun jcs-ask-insert-license-content (in-type)
  "Ask to insert the license content base on IN-TYPE."
  (interactive
   (list (completing-read
          (format "Type of the license: "
                  (progn  ; Preloading for `interactive` function.
                    (require 'license-templates) (require 'subr-x)))
          (delete-dups
           (sort (append (list "Default (empty)")
                         (license-templates-names))
                 #'string-lessp)))))
  (cond ((string= in-type "Default (empty)") (progn ))
        ((jcs-contain-list-string (license-templates-names) in-type)
         (license-templates-insert in-type))))

;;
;; (@* "Change Log" )
;;

(defun jcs-ask-insert-changelog-content (in-type)
  "Ask to insert the changelog content base on IN-TYPE."
  (interactive
   (list (completing-read
          "Type of the changelog: "
          (append (list "Default (empty)")
                  (jcs-dir-to-filename jcs-changelog-template-dir ".txt")))))
  (pcase in-type
    ("Default (empty)" )  ; Do nothing...
    (_
     (file-header-insert-template-by-file-path
      (format "%s%s.txt" jcs-changelog-template-dir in-type)))))

;;
;; (@* "Special Modes" )
;;

(defun jcs-depend-mode ()
  "This mode depend on my own machine. More feature and more control of the editor."
  (interactive)
  (unless (jcs-mode-stats-p 'depend)
    ;; Customize Mode Line
    (jcs-gray-mode-line)

    ;; Unset 'depend' mode key
    ;; NOTE: unset key should be before of set keys
    (global-unset-key (kbd "C-f"))
    (global-unset-key (kbd "C-r"))

    ;; Set 'depend' mode key

    ;; search
    (define-key global-map (kbd "C-f") #'ivy-searcher-search-file)
    (define-key global-map (kbd "C-S-f") #'ivy-searcher-search-project)

    ;; Update mode state.
    (setq jcs-mode--state 'depend)

    (message "[INFO] Turn into `depend-mode` now")))

(defun jcs-cross-mode ()
  "This mode run anywhere will work, usually less powerful then `jcs-depend-mode'."
  (interactive)
  (unless (jcs-mode-stats-p 'cross)
    ;; Customize Mode Line
    (jcs-dark-green-mode-line)

    ;; Unset 'cross' mode key
    ;; NOTE: unset key should be before of set keys
    (global-unset-key (kbd "C-f"))
    (global-unset-key (kbd "C-r"))
    (global-unset-key (kbd "C-r p"))

    ;; Set 'cross' mode key

    ;; search
    (define-key global-map (kbd "C-f") #'isearch-forward)
    (define-key global-map (kbd "C-S-f") #'isearch-project-forward)

    ;; Update mode state.
    (setq jcs-mode--state 'cross)

    (message "[INFO] Turn into `cross-mode` now")))

;;----------------------------------------------------------------------------
;;; Startup Modes

;; NOTE: These are modes that will startup immediately, meaning there will
;; be no benefits having in the separated files except the modulation.
;;
;; So just put all the startup modes' configuration here.

;;; Special
(add-hook 'special-mode-hook (lambda () (goto-address-mode 1)))

;;; Backtrace
(add-hook 'backtrace-mode-hook (lambda () (buffer-wrap-mode 1)))

;;; Buffer Menu
(add-hook 'Buffer-menu-mode-hook (lambda () (require 'jcs-buffer-menu)))

;;; Diff
(add-hook 'diff-mode-hook
          (lambda ()
            (jcs-bind-key (kbd "M-k") #'jcs-maybe-kill-this-buffer)
            (jcs-bind-key (kbd "M-K") #'jcs-reopen-this-buffer)))

;;; Compilation
(defun jcs-compilation-mode-hook ()
  "Hook for `compilation-mode'."
  (buffer-disable-undo)
  (goto-address-mode 1)
  (toggle-truncate-lines -1)

  ;; NOTE: Set smaller font.
  (setq buffer-face-mode-face '(:height 120))
  (buffer-face-mode)

  (jcs-bind-key (kbd "M-k") #'jcs-output-maybe-kill-buffer)
  (jcs-bind-key (kbd "C-_") #'jcs-output-prev-compilation)
  (jcs-bind-key (kbd "C-+") #'jcs-output-next-compilation))

(add-hook 'compilation-mode-hook 'jcs-compilation-mode-hook)
(add-hook 'comint-mode-hook 'jcs-compilation-mode-hook)

;;; Message Buffer
(add-hook 'messages-buffer-mode-hook
          (lambda ()
            (auto-highlight-symbol-mode 1)
            (goto-address-mode 1)
            (page-break-lines-mode 1)))

;;; Tabulated List
(add-hook 'tabulated-list-mode-hook
          (lambda ()
            (when (memq major-mode '(Buffer-menu-mode package-menu-mode))
              (buffer-wrap-mode 1))))

;;============================================================================
;; Project

(defun jcs-active-project-mode-hook ()
  "Hook runs when there is valid project root."
  (when (jcs-project-under-p)
    (global-diff-hl-mode 1)
    (editorconfig-mode 1)
    (jcs--safe-lsp-active)))

;;============================================================================
;; Base Mode

(defun jcs-base-mode-hook ()
  "Major mode hook for every major mode."
  (auto-highlight-symbol-mode t)
  (electric-pair-mode 1)
  (goto-address-mode 1)
  (when (display-graphic-p) (highlight-indent-guides-mode 1))

  (jcs-active-project-mode-hook))

(add-hook 'text-mode-hook 'jcs-base-mode-hook)
(add-hook 'prog-mode-hook 'jcs-base-mode-hook)

;;; Text
(defun jcs-text-mode-hook ()
  "Text mode hook."
  (jcs-insert-header-if-valid '("\\(/\\|\\`\\)[Ll][Ii][Cc][Ee][Nn][Ss][Ee]")
                              'jcs-ask-insert-license-content
                              :interactive t)

  (jcs-insert-header-if-valid '("\\(/\\|\\`\\)[Cc][Hh][Aa][Nn][Gg][Ee][-_]*[Ll][Oo][Gg]")
                              'jcs-ask-insert-changelog-content
                              :interactive t))

(add-hook 'text-mode-hook 'jcs-text-mode-hook)

;;============================================================================
;; Programming Mode

(defconst jcs-mode--dash-major-modes '(elm-mode lua-mode)
  "List of major modes that use dash for commenting.

To avoid syntax highlighting error for comment.")

(defun jcs-prog-mode-hook ()
  "Programming language mode hook."
  (unless (jcs-is-current-major-mode-p jcs-mode--dash-major-modes)
    (modify-syntax-entry ?- "_"))

  ;; Load Docstring faces.
  (docstr-faces-apply)

  ;; Ensure indentation level is available
  (indent-control-ensure-tab-width)

  ;; Smart Parenthesis
  (dolist (key jcs-smart-closing-parens)
    (jcs-key-advice-add key :around #'jcs-smart-closing))

  (abbrev-mode 1)
  (display-fill-column-indicator-mode 1)
  (highlight-numbers-mode 1))

(add-hook 'prog-mode-hook 'jcs-prog-mode-hook)

;;; Emacs Lisp
(defun jcs-emacs-lisp-mode-hook ()
  "Emacs Lisp mode hook."
  (modify-syntax-entry ?_ "w")  ; Treat underscore as word.

  (jcs-insert-header-if-valid '("[.]el")
                              'jcs-insert-emacs-lisp-template))

(add-hook 'emacs-lisp-mode-hook 'jcs-emacs-lisp-mode-hook)

;;; Lisp
(defun jcs-lisp-mode-hook ()
  "Lisp mode hook."
  (modify-syntax-entry ?_ "w")  ; Treat underscore as word.

  (jcs-insert-header-if-valid '("[.]lisp")
                              'jcs-insert-lisp-template))

(add-hook 'lisp-mode-hook 'jcs-lisp-mode-hook)

;;; Lisp Interaction
(defun jcs-lisp-interaction-mode-hook ()
  "Lisp Interaction mode hook."
  (jcs-bind-key (kbd "M-k") #'jcs-scratch-buffer-maybe-kill)
  (jcs-bind-key (kbd "M-K") #'jcs-scratch-buffer-refresh))

(add-hook 'lisp-interaction-mode-hook 'jcs-lisp-interaction-mode-hook)

;;============================================================================
;; View

(defun jcs-view-mode-hook ()
  "In view mode, read only file."
  (require 'view)
  (unless (equal jcs-mode--state 'view)
    ;; unset all the key
    (define-key view-mode-map [tab] nil)
    (define-key view-mode-map (kbd "RET") nil)

    (dolist (key-str jcs-key-list)
      (define-key view-mode-map key-str nil))))

(add-hook 'view-mode-hook 'jcs-view-mode-hook)

;;----------------------------------------------------------------------------
;;; Modes

(with-eval-after-load 'message (require 'jcs-message-mode))
(with-eval-after-load 're-builder (require 'jcs-re-builder-mode))
(jcs-with-eval-after-load-multiple '(shell esh-mode) (require 'jcs-shell-mode))
(with-eval-after-load 'yasnippet (require 'jcs-snippet-mode))

(with-eval-after-load 'actionscript-mode (require 'jcs-actionscript-mode))
(with-eval-after-load 'ada-mode (require 'jcs-ada-mode))
(with-eval-after-load 'agda-mode (require 'jcs-agda-mode))
(with-eval-after-load 'applescript-mode (require 'jcs-applescript-mode))
(jcs-with-eval-after-load-multiple '(masm-mode nasm-mode) (require 'jcs-asm-mode))
(with-eval-after-load 'basic-mode (require 'jcs-basic-mode))
(with-eval-after-load 'bat-mode (require 'jcs-batch-mode))
(with-eval-after-load 'cc-mode
  (require 'jcs-cc-mode)
  (require 'jcs-c-mode)
  (require 'jcs-c++-mode)
  (require 'jcs-java-mode)
  (require 'jcs-objc-mode))
(with-eval-after-load 'clojure-mode (require 'jcs-clojure-mode))
(with-eval-after-load 'cmake-mode (require 'jcs-cmake-mode))
(with-eval-after-load 'cobol-mode (require 'jcs-cobol-mode))
(with-eval-after-load 'conf-mode (require 'jcs-properties-mode))
(with-eval-after-load 'csharp-mode (require 'jcs-csharp-mode))
(with-eval-after-load 'css-mode (require 'jcs-css-mode))
(with-eval-after-load 'dart-mode (require 'jcs-dart-mode))
(with-eval-after-load 'dockerfile-mode (require 'jcs-dockerfile-mode))
(with-eval-after-load 'elixir-mode (require 'jcs-elixir-mode))
(with-eval-after-load 'elm-mode (require 'jcs-elm-mode))
(with-eval-after-load 'erlang (require 'jcs-erlang-mode))
(with-eval-after-load 'ess-r-mode (require 'jcs-r-mode))
(with-eval-after-load 'fountain-mode (require 'jcs-fountain-mode))
(with-eval-after-load 'fsharp-mode (require 'jcs-fsharp-mode))
(with-eval-after-load 'gdscript-mode (require 'jcs-gdscript-mode))
(with-eval-after-load 'gitattributes-mode (require 'jcs-git-mode))
(with-eval-after-load 'gitconfig-mode (require 'jcs-git-mode))
(with-eval-after-load 'gitignore-mode (require 'jcs-git-mode))
(with-eval-after-load 'glsl-mode (require 'jcs-shader-mode))
(with-eval-after-load 'go-mode (require 'jcs-go-mode))
(with-eval-after-load 'groovy-mode (require 'jcs-groovy-mode))
(with-eval-after-load 'haskell-mode (require 'jcs-haskell-mode))
(with-eval-after-load 'haxe-mode (require 'jcs-haxe-mode))
(with-eval-after-load 'ini-mode (require 'jcs-ini-mode))
(with-eval-after-load 'jayces-mode (require 'jcs-jayces-mode))
(with-eval-after-load 'jenkinsfile-mode (require 'jcs-jenkinsfile-mode))
(with-eval-after-load 'js2-mode (require 'jcs-js-mode))
(with-eval-after-load 'json-mode (require 'jcs-json-mode))
(with-eval-after-load 'kotlin-mode (require 'jcs-kotlin-mode))
(with-eval-after-load 'less-css-mode (require 'jcs-less-css-mode))
(with-eval-after-load 'lua-mode (require 'jcs-lua-mode))
(with-eval-after-load 'make-mode (require 'jcs-make-mode))
(with-eval-after-load 'markdown-mode (require 'jcs-markdown-mode))
(with-eval-after-load 'masm-mode (require 'jcs-asm-mode))
(with-eval-after-load 'nasm-mode (require 'jcs-asm-mode))
(with-eval-after-load 'nginx-mode (require 'jcs-nginx-mode))
(with-eval-after-load 'nix-mode (require 'jcs-nix-mode))
(with-eval-after-load 'nxml-mode (require 'jcs-xml-mode))
(with-eval-after-load 'opascal (require 'jcs-opascal-mode))
(with-eval-after-load 'org (require 'jcs-org-mode))
(with-eval-after-load 'pascal (require 'jcs-pascal-mode))
(with-eval-after-load 'perl-mode (require 'jcs-perl-mode))
(with-eval-after-load 'powershell (require 'jcs-powershell-mode))
(with-eval-after-load 'processing-mode (require 'jcs-processing-mode))
(with-eval-after-load 'python-mode (require 'jcs-python-mode))
(with-eval-after-load 'rjsx-mode (require 'jcs-jsx-mode))
(with-eval-after-load 'ruby-mode (require 'jcs-ruby-mode))
(with-eval-after-load 'rust-mode (require 'jcs-rust-mode))
(with-eval-after-load 'ssass-mode (require 'jcs-sass-mode))
(with-eval-after-load 'scala-mode (require 'jcs-scala-mode))
(with-eval-after-load 'scss-mode (require 'jcs-scss-mode))
(with-eval-after-load 'sh-script (require 'jcs-sh-mode))
(with-eval-after-load 'shader-mode (require 'jcs-shader-mode))
(with-eval-after-load 'sql (require 'jcs-sql-mode))
(with-eval-after-load 'swift-mode (require 'jcs-swift-mode))
(with-eval-after-load 'typescript-mode (require 'jcs-typescript-mode))
(with-eval-after-load 'verilog-mode (require 'jcs-verilog-mode))
(with-eval-after-load 'vimrc-mode (require 'jcs-vimscript-mode))
(with-eval-after-load 'vue-mode (require 'jcs-vue-mode))
(with-eval-after-load 'web-mode (require 'jcs-web-mode))
(with-eval-after-load 'yaml-mode (require 'jcs-yaml-mode))


;;;
;; Auto mode Management

(setq
 auto-mode-alist
 (append
  '(
;;; A
    ("\\.as'?\\'"                  . actionscript-mode)
    ("\\.agda'?\\'"                . agda-mode)
    ("\\.applescript'?\\'"         . applescript-mode)
    ("\\.scpt'?\\'"                . applescript-mode)
    ("\\.scptd'?\\'"               . applescript-mode)
;;; B
    ("\\.bas'\\'"                  . basic-mode)
    ("\\.bat'?\\'"                 . bat-mode)
;;; C
    ("\\.hin'?\\'"                 . c++-mode)
    ("\\.cin'?\\'"                 . c++-mode)
    ("\\.cpp'?\\'"                 . c++-mode)
    ("\\.hpp'?\\'"                 . c++-mode)
    ("\\.inl'?\\'"                 . c++-mode)
    ("\\.rdc'?\\'"                 . c++-mode)
    ("\\.cc'?\\'"                  . c++-mode)
    ("\\.c8'?\\'"                  . c++-mode)
    ("\\.h'?\\'"                   . c++-mode)
    ("\\.c'?\\'"                   . c++-mode)
    ("\\.clj'?\\'"                 . clojure-mode)
    ("\\.cljs'?\\'"                . clojure-mode)
    ("\\.cljc'?\\'"                . clojure-mode)
    ("\\(/\\|\\`\\)CMakeLists.txt" . cmake-mode)
    ("\\.ac'?\\'"                  . cmake-mode)
    ("\\.cbl'?\\'"                 . cobol-mode)
    ("\\.properties'?\\'"          . conf-javaprop-mode)
    ("\\.cs'?\\'"                  . csharp-mode)
    ("\\.css'?"                    . css-mode)
;;; D
    ("\\.dart'?"                   . dart-mode)
    ("\\(/\\|\\`\\)Dokerfile"      . dockerfile-mode)
;;; E
    ("\\.ex'?\\'"                  . elixir-mode)
    ("\\.exs'?\\'"                 . elixir-mode)
    ("\\.el'?\\'"                  . emacs-lisp-mode)
    ("\\.erl'?\\'"                 . erlang-mode)
    ("\\.hrl'?\\'"                 . erlang-mode)
;;; F
    ("\\.fountain'?\\'"            . fountain-mode)
    ("\\.fs'?\\'"                  . fsharp-mode)
;;; G
    ("\\.gen'?\\'"                 . gen-mode)
    ("\\.gd'?\\'"                  . gdscript-mode)
    ("\\.gitattributes'?\\'"       . gitattributes-mode)
    ("\\.gitconfig'?\\'"           . gitconfig-mode)
    ("\\.gitignore'?\\'"           . gitignore-mode)
    ("\\.dockerignore'?\\'"        . gitignore-mode)
    ("\\.npmignore'?\\'"           . gitignore-mode)
    ("\\.unityignore'?\\'"         . gitignore-mode)
    ("\\.vscodeignore'?\\'"        . gitignore-mode)
    ("\\.frag'?\\'"                . glsl-mode)
    ("\\.geom'?\\'"                . glsl-mode)
    ("\\.glsl'?\\'"                . glsl-mode)
    ("\\.vert'?\\'"                . glsl-mode)
    ("\\.go'?\\'"                  . go-mode)
    ("\\.groovy'?\\'"              . groovy-mode)
    ("\\.gradle'?\\'"              . groovy-mode)
;;; H
    ("\\.hs'?\\'"                  . haskell-mode)
    ("\\.hx'?\\'"                  . haxe-mode)
    ("\\.hxml'?\\'"                . haxe-mode)
;;; I
    ("\\.ini'?\\'"                 . ini-mode)
;;; J
    ("\\.java'?\\'"                . java-mode)
    ("\\.jcs'?\\'"                 . jayces-mode)
    ("\\.jayces'?\\'"              . jayces-mode)
    ("Jenkinsfile\\'"              . jenkinsfile-mode)
    ("\\.js'?\\'"                  . js2-mode)
    ("\\.json'?\\'"                . json-mode)
    ("\\.jsx'?\\'"                 . rjsx-mode)
;;; K
    ("\\.kt'?\\'"                  . kotlin-mode)
    ("\\.ktm'?\\'"                 . kotlin-mode)
    ("\\.kts'?\\'"                 . kotlin-mode)
;;; L
    ("\\.less'?\\'"                . less-css-mode)
    ("\\.lisp'?\\'"                . lisp-mode)
    ("\\.lua'?\\'"                 . lua-mode)
    ("\\.luac'?\\'"                . lua-mode)
;;; M
    ("\\.mak'?\\'"                 . makefile-mode)
    ("\\.makfile'?\\'"             . makefile-mode)
    ("\\(/\\|\\`\\)[Mm]akefile"    . makefile-mode)
    ("\\.md'?\\'"                  . markdown-mode)
    ("\\.markdown'?\\'"            . markdown-mode)
    ("\\.asm'?\\'"                 . masm-mode)
    ("\\.inc'?\\'"                 . masm-mode)
;;; N
    ("\\.asm'?\\'"                 . nasm-mode)
    ("\\.inc'?\\'"                 . nasm-mode)
    ("\\.nix'?\\'"                 . nix-mode)
;;; O
    ("\\.m'?\\'"                   . objc-mode)
    ("\\.mm'?\\'"                  . objc-mode)
    ("\\.dpk'?\\'"                 . opascal-mode)
    ("\\.dpr'?\\'"                 . opascal-mode)
    ("\\.org'?\\'"                 . org-mode)
;;; P
    ("\\.pas'?\\'"                 . pascal-mode)
    ("\\.pl'?\\'"                  . perl-mode)
    ("\\.pde'?\\'"                 . processing-mode)
    ("\\.ps1'?\\'"                 . powershell-mode)
    ("\\.py'?\\'"                  . python-mode)
    ("\\.pyc'?\\'"                 . python-mode)
;;; R
    ("\\.r'?\\'"                   . ess-r-mode)
    ("\\.rb'?\\'"                  . ruby-mode)
    ("\\.rs'?\\'"                  . rust-mode)
;;; S
    ("\\.sass'?\\'"                . ssass-mode)
    ("\\.scala'?\\'"               . scala-mode)
    ("\\.scss?\\'"                 . scss-mode)
    ("\\.sh'?\\'"                  . sh-mode)
    ("\\.linux'?\\'"               . sh-mode)
    ("\\.macosx'?\\'"              . sh-mode)
    ("\\.shader'?\\'"              . shader-mode)
    ("\\.sql'?\\'"                 . sql-mode)
    ("\\.swift'?\\'"               . swift-mode)
;;; T
    ("\\.ts'?\\'"                  . typescript-mode)
    ("\\.tsx'?\\'"                 . typescript-mode)
    ("\\.toml'?\\'"                . conf-toml-mode)
    ("\\.txt'?\\'"                 . text-mode)
;;; V
    ("\\.v'?\\'"                   . verilog-mode)
    ("\\.vim\\(rc\\)'?\\'"         . vimrc-mode)
    ("\\(/\\|\\`\\)_vimrc"         . vimrc-mode)
    ;;
    ;;
    ;;(
    ("\\.vue'?\\'"                 . web-mode)
;;; W
    ("\\.phtml\\'"                 . web-mode)
    ("\\.tpl\\.php\\'"             . web-mode)
    ("\\.erb\\'"                   . web-mode)
    ("\\.mustache\\'"              . web-mode)
    ("\\.djhtml\\'"                . web-mode)
    ("\\.html?\\'"                 . web-mode)
    ("\\.php?\\'"                  . web-mode)
    ("\\.[agj]sp\\'"               . web-mode)
    ;;
    ("\\.as[cp]x\\'"               . web-mode)
    ("\\.cshtml\\'"                . web-mode)
    ("\\.[Mm]aster\\'"             . web-mode)
;;; X
    ("\\.xml'?\\'"                 . nxml-mode)
;;; Y
    ("\\.yaml'?\\'"                . yaml-mode)
    ("\\.yml'?\\'"                 . yaml-mode))
  auto-mode-alist))

(provide 'jcs-mode)
;;; jcs-mode.el ends here
