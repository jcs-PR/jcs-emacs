;;; jcs-plugin.el --- Plugin Configurations  -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(leaf adaptive-wrap
  :init
  (jcs-add-hook 'visual-line-mode-hook (adaptive-wrap-prefix-mode +1)))

(leaf auto-highlight-symbol
  :init
  (setq ahs-idle-interval 0.15))

(leaf auto-read-only
  :defer-config
  (nconc auto-read-only-file-regexps
         '("emacs/.*/lisp/"
           "/[.]emacs[.]d/elpa/"))
  (jcs-advice-add 'auto-read-only--hook-find-file :override
    (when (and (not jcs-package-installing-p) (not (jcs-project-current)))
      (auto-read-only))))

(leaf auto-rename-tag
  :init
  (setq auto-rename-tag-disabled-commands '(query-replace)
        auto-rename-tag-disabled-minor-modes '(iedit-mode
                                               multiple-cursors-mode)))

(leaf balance-windows
  :init
  (setq balanced-windows-functions
        '(delete-window
          quit-window
          split-window-horizontally split-window-vertically)))

(leaf better-scroll
  :init
  (setq better-scroll-align-type 'relative
        better-scroll-allow-boundary-movement t))

(leaf blamer
  :init
  (setq blamer-type 'visual
        blamer-view 'overlay-right
        blamer-idle-time 0.3))

(leaf browse-kill-ring
  :init
  (setq browse-kill-ring-separator-face 'font-lock-comment-face)
  :defer-config
  (jcs-add-hook 'browse-kill-ring-mode-hook
    (setq browse-kill-ring-separator (jcs-env-separator))
    (page-break-lines-mode 1)))

(leaf buffer-wrap
  :defer-config
  (defun jcs--buffer-wrap--fixed-window-off ()
    "Fixed windows is off after wrapping."
    (let ((max-ln (+ (line-number-at-pos (point-max)) buffer-wrap--relative-max-line)))
      (when (= max-ln (line-number-at-pos (point)))
        (jcs-recenter-top-bottom 'bottom))))

  (defun jcs--buffer-wrap--fixed-fake-header ()
    "Fixed line offset consider fake header calculation."
    (when tabulated-list-format
      (unless (ignore-errors (tabulated-list-get-entry))
        (cond ((= 0 buffer-wrap--delta-lines)
               (goto-char (point-min)))
              ((< 0 buffer-wrap--delta-lines)
               (ignore-errors (forward-line 1)))
              (t
               (jcs-goto-line (1- (line-number-at-pos (point-max))))))
        (unless (ignore-errors (tabulated-list-get-entry))
          (ignore-errors (forward-line 1))))))

  (jcs-add-hook 'buffer-wrap-post-command-hook
    (jcs--buffer-wrap--fixed-fake-header)
    (jcs--buffer-wrap--fixed-window-off)))

(leaf centaur-tabs
  :init
  (setq centaur-tabs-set-icons nil
        centaur-tabs-style "wave"
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "*"))

(leaf company
  :init
  (setq company-frontends '(company-pseudo-tooltip-frontend)
        company-require-match nil
        company-tooltip-align-annotations t
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-eclim-auto-save nil
        company-minimum-prefix-length 0
        company-idle-delay 0.07
        company-selection-wrap-around 'on
        company-format-margin-function #'company-detect-icons-margin)
  (setq company-backends
        (append
         '(company-capf company-semantic)
         '(company-keywords)
         '(company-abbrev company-dabbrev company-dabbrev-code)
         '(company-files)
         '(company-etags company-gtags)
         '(company-yasnippet)))
  :defer-config
  (unless (display-graphic-p)
    (push 'company-echo-metadata-frontend company-frontends))
  (require 'jcs-company))

(leaf company-box
  :hook (company-mode-hook . company-box-mode)
  :init
  (setq company-box-backends-colors nil
        company-box-frame-behavior 'point
        company-box-doc-delay 0.3
        company-box-doc-text-scale-level -2))

(leaf company-c-headers
  :defer-config
  (require 'dash)

  (defconst jcs--msvc-path
    '("C:/Program Files (x86)/Microsoft Visual Studio/"
      "/Community/VC/Tools/MSVC/"
      "/include/")
    "Path for Microsoft Visual Studio.")

  (defconst jcs--windows-kits-path
    '("C:/Program Files (x86)/Windows Kits/10/Include/"
      "/ucrt/")
    "Path for Windows Kits.")

  (setq company-c-headers-path-user '(".")
        company-c-headers-path-system
        (-flatten
         (append
          '("/usr/include/" "/usr/local/include/")
          (list (jcs--path-guess jcs--msvc-path
                                 (lambda (dirname)
                                   (not (= (string-to-number dirname) 0))))
                (jcs--path-guess jcs--windows-kits-path
                                 (lambda (dirname)
                                   (not (= (string-to-number dirname) 0)))))))))

(leaf company-emojify
  :init
  (setq company-emojify-annotation 'image
        company-emojify-emoji-styles '(github)))

(leaf company-fuzzy
  :hook (company-mode-hook . company-fuzzy-mode)
  :init
  (setq company-fuzzy-sorting-backend 'flx
        company-fuzzy-prefix-on-top nil
        company-fuzzy-history-backends '(company-yasnippet)
        company-fuzzy-trigger-symbols '("." "->" "<" "\"" "'" "@")))

(leaf csharp-mode
  :init
  (setq csharp-codedoc-tag-face 'font-lock-doc-face))

(leaf dashboard
  :init
  (setq dashboard-banner-logo-title "[J C S • E M A C S]"
        dashboard-footer-icon ""
        dashboard-footer-messages
        `(,(format "Copyright (c) %s %s" (format-time-string "%Y") (jcs-copyright-info)))
        dashboard-items '((ls-directories . 5)
                          (ls-files       . 5)
                          (recents        . 5)
                          (projects       . 5)
                          ;;(bookmarks      . 5)
                          ;;(agenda         . 5)
                          ;;(registers      . 5)
                          )
        dashboard-item-shortcuts '((recents        . "r")
                                   (bookmarks      . "m")
                                   (projects       . "p")
                                   (agenda         . "a")
                                   (registers      . "e")
                                   (ls-directories . "d")
                                   (ls-files       . "f"))
        dashboard-center-content t
        dashboard-set-navigator nil
        dashboard-projects-backend 'project-el
        ;; Truncate style
        dashboard-path-style 'truncate-middle
        dashboard-recentf-show-base 'align
        dashboard-projects-show-base 'align
        dashboard-bookmarks-show-base 'align
        dashboard-bookmarks-item-format "%s  %s"
        dashboard-shorten-by-window-width t
        dashboard-shorten-path-offset 15)
  :defer-config
  (jcs-require '(project jcs-dashboard dashboard-ls))

  (jcs-add-hook 'jcs-after-load-theme-hook
    (setq dashboard-startup-banner (jcs-dashboard--get-banner-path))
    (when (bound-and-true-p jcs-emacs-startup-directory)
      (jcs-dashboard-refresh-buffer)))

  (dashboard-setup-startup-hook))

(leaf define-it
  :init
  (setq define-it-output-choice 'view))

(leaf diff-hl
  :init
  (setq diff-hl-side 'right))

(leaf diminish-buffer
  :init
  (setq diminish-buffer-list
        (append
         '("[*]helm" "[*]esup-" "[*]quelpa-")
         '("[*]compilation" "[*]output")
         '("[*]Apropos[*]" "[*]Backtrace[*]" "[*]Compile-Log[*]" "[*]Help[*]"
           "[*]Warnings[*]")
         '("[*]VC-history[*]")
         '("[*]CPU-Profiler-Report" "[*]Memory-Profiler-Report")
         '("[*]Process List[*]")
         '("[*]Checkdoc " "[*]Package-Lint[*]")
         '("[*]Async Shell Command[*]" "[*]shell" "[*]eshell")
         '("[*]ESS[*]")
         '("[*]emacs[*]")  ; From `async'
         '("[*]lsp-" "[*]LSP[ ]+"
           "[*][a-zA-Z0-9]+[-]*ls" "[*][a-zA-Z0-9]+::stderr[*]"
           "[*]csharp[*]"
           "[*]rust-analyzer[*:]"
           "[*]tcp-server-sonarlint")  ; From `lsp'
         '("[*]tree-sitter" "tree-sitter-tree:")
         '("[*]company")
         '("[*]Local Variables[*]")
         '("[*]Kill Ring[*]")  ; From `browse-kill-ring'
         '("[*]SPEEDBAR")
         '("[*]Flycheck" "[*]Flymake log[*]")
         '("[*]httpd[*]")
         '("[*]helpful")
         '("[*]ert[*]")  ; Emacs Lisp Regression Testing
         '("magit[-]*[[:ascii:]]*[:]")  ; From `magit'
         '("[*]Most used words[*]")
         '("[*]Test SHA[*]")
         '("[*]RE-Builder")
         '("[*]preview-it")
         '("[*]wclock[*]")
         '("[*]Clippy[*]")
         '("[*]CMake Temporary[*]")
         '("[*]org-src-fontification")
         '("[*]ASCII[*]")
         '("[*]npm:")
         '("[*]Flutter"))
        diminish-buffer-mode-list
        (append
         '("Dired by name")))
  :defer-config
  (jcs-advice-add 'jcs-buffer-menu-refresh-buffer :before
    (when diminish-buffer-mode (diminish-buffer-clean))))

(leaf display-fill-column-indicator
  :init
  (setq-default display-fill-column-indicator-column 80))

(leaf docstr
  :init
  (setq docstr-key-support t
        docstr-desc-summary ""))

(leaf dumb-jump
  :init
  (setq dumb-jump-selector 'completing-read))

(leaf elisp-demos
  :init
  (advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

(leaf emojify
  :init
  (setq emojify-emoji-styles '(github)
        emojify-company-tooltips-p t))

(leaf eshell-syntax-highlighting
  :hook (eshell-mode-hook . eshell-syntax-highlighting-global-mode))

(leaf exec-path-from-shell
  :defer-config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(leaf file-header
  :init
  (setq file-header-template-config-filepath (concat user-emacs-directory "templates/config.properties")))

(leaf flx
  :defer-config
  (flx-rs-load-dyn)
  (advice-add 'flx-score :override #'flx-rs-score))

(leaf flycheck
  :defer-config
  (advice-add 'flycheck-display-error-messages
              :around (lambda (fnc &rest args) (jcs-no-log-apply (apply fnc args)))))

(leaf flycheck-grammarly
  :hook (flycheck-mode-hook . (lambda () (require 'flycheck-grammarly))))

(leaf flycheck-languagetool
  :hook (flycheck-mode-hook . (lambda () (require 'flycheck-languagetool))))

(leaf google-translate
  :init
  (setq google-translate-default-source-language "auto"
        google-translate-default-target-language "zh-TW")
  :defer-config
  (jcs-advice-add 'google-translate--search-tkk :override (list 430675 2721866130)))

(leaf goto-char-preview
  :defer-config
  (advice-add 'goto-char-preview :after #'jcs--recenter--advice-after))

(leaf goto-line-preview
  :defer-config
  (advice-add 'goto-line-preview :after #'jcs--recenter--advice-after))

(leaf highlight-indent-guides
  :init
  (setq highlight-indent-guides-method 'character
        highlight-indent-guides-character ?\|
        highlight-indent-guides-responsive 'top))

(leaf hl-todo
  :init
  (setq hl-todo-highlight-punctuation "")
  :defer-config
  (require 'asoc)
  (asoc-put! hl-todo-keyword-faces "TODO" "red" t)
  (asoc-put! hl-todo-keyword-faces "NOTE" "dark green" t)
  (asoc-put! hl-todo-keyword-faces "TEMP" "turquoise" t)
  (asoc-put! hl-todo-keyword-faces "FIXME" "red" t)
  (nconc hl-todo-keyword-faces
         '(("ATTENTION"   . "red")
           ("STUDY"       . "yellow")
           ("IMPORTANT"   . "yellow")
           ("CAUTION"     . "yellow")
           ("OPTIMIZE"    . "yellow")
           ("DESCRIPTION" . "dark green")
           ("TAG"         . "dark green")
           ("OPTION"      . "dark green")
           ("DEBUG"       . "turquoise")
           ("DEBUGGING"   . "turquoise")
           ("TEMPORARY"   . "turquoise")
           ("SOURCE"      . "PaleTurquoise2")
           ("URL"         . "PaleTurquoise2")
           ("IDEA"        . "green yellow")
           ("OBSOLETE"    . "DarkOrange3")
           ("DEPRECATED"  . "DarkOrange3")
           ("TOPIC"       . "slate blue")
           ("SEE"         . "slate blue")))
  (advice-add #'hl-todo--inside-comment-or-string-p :override #'jcs-inside-comment-or-string-p))

(leaf impatient-showdown
  :init
  (setq impatient-showdown-flavor 'github))

(leaf indent-control
  :init
  (setq indent-control-records
        '((actionscript-mode     . 4)
          (c-mode                . 4)
          (c++-mode              . 4)
          (csharp-mode           . 4)
          (css-mode              . 2)
          (dockerfile-mode       . 2)
          (elisp-mode            . 2)
          (emacs-lisp-mode       . 2)
          (go-mode               . 4)
          (groovy-mode           . 4)
          (java-mode             . 4)
          (jayces-mode           . 4)
          (js-mode               . 2)
          (js2-mode              . 2)
          (json-mode             . 2)
          (kotlin-mode           . 4)
          (less-css-mode         . 2)
          (lisp-mode             . 2)
          (lisp-interaction-mode . 2)
          (lua-mode              . 4)
          (nasm-mode             . 4)
          (nix-mode              . 2)
          (nxml-mode             . 2)
          (objc-mode             . 4)
          (python-mode           . 4)
          (rjsx-mode             . 2)
          (ruby-mode             . 2)
          (rust-mode             . 4)
          (scss-mode             . 2)
          (shader-mode           . 4)
          (ssass-mode            . 2)
          (sql-mode              . 1)
          (typescript-mode       . 4)
          (web-mode              . 2)
          (yaml-mode             . 2))))

(leaf isearch
  :init
  (setq isearch-lazy-count t
        lazy-count-prefix-format "[%s:%s] ")
  :defer-config
  (add-hook 'isearch-mode-hook #'jcs-scroll-conservatively-disable)
  (add-hook 'isearch-mode-end-hook #'jcs-scroll-conservatively-enable))

(leaf isearch-project
  :init
  (setq isearch-project-ignore-paths '(".vs/"
                                       ".vscode/"
                                       "bin/"
                                       "build/"
                                       "build.min/"
                                       "node_modules/"
                                       "res/"))
  :defer-config
  (jcs-add-hook 'isearch-mode-hook
    "Paste the current symbol when `isearch' enabled."
    (cond ((use-region-p)
           (progn
             (deactivate-mark)
             (ignore-errors
               (isearch-yank-string (buffer-substring-no-properties (region-beginning) (region-end))))))
          ((memq this-command '(jcs-isearch-project-backward-symbol-at-point))
           (when (char-or-string-p isearch-project--thing-at-point)
             (backward-word 1)
             (isearch-project--isearch-yank-string isearch-project--thing-at-point)
             (isearch-repeat-backward))))))

(leaf keypression
  :defer-config
  (setq keypression-ignore-mouse-events
        (append keypression-ignore-mouse-events
                '(switch-frame menu-bar tool-bar tab-bar))))

(leaf line-reminder
  :init
  (setq line-reminder-show-option (if (display-graphic-p) 'indicators 'linum)
        line-reminder-thumbnail t)
  (unless (display-graphic-p)
    (setq line-reminder-saved-sign " |"
          line-reminder-modified-sign " |")))

(leaf logms
  :defer-config
  (logms-mode 1))

(leaf lsp-mode
  :init
  (setq lsp-auto-guess-root t
        lsp-prefer-capf t
        lsp-keep-workspace-alive nil                   ; Auto-kill LSP server
        lsp-modeline-code-action-fallback-icon "Œ"
        lsp-prefer-flymake nil                         ; Use lsp-ui and flycheck
        flymake-fringe-indicator-position 'right-fringe)

  (defvar jcs-lsp-lighter-delay 3.0
    "Shorten lighter after this amount of time.")

  (defun jcs--lsp-connected-p ()
    "Return non-nil if LSP connected."
    (bound-and-true-p lsp-managed-mode))

  (defun jcs--safe-lsp-active ()
    "Safe way to active LSP."
    (when (and (jcs-project-under-p) (not (jcs--lsp-connected-p)))
      (lsp-deferred)))
  :defer-config
  (require 'jcs-lsp))

(leaf lsp-tailwindcss
  :init
  (setq lsp-tailwindcss-add-on-mode t
        lsp-tailwindcss-emmet-completions t))

(leaf lsp-ui
  :init
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-text-scale-level -1
        lsp-ui-doc-use-webkit nil
        lsp-ui-doc-delay 0.6
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'at-point
        lsp-eldoc-enable-hover nil
        lsp-ui-imenu-enable t
        lsp-ui-imenu-colors `(,(face-foreground 'font-lock-keyword-face)
                              ,(face-foreground 'font-lock-string-face)
                              ,(face-foreground 'font-lock-constant-face)
                              ,(face-foreground 'font-lock-variable-name-face))
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-diagnostics nil
        lsp-ui-sideline-ignore-duplicate t)
  (defun jcs--lsp-ui-doc--hide-frame ()
    "Safe way to call `lsp-ui-doc--hide-frame' function."
    (when (functionp 'lsp-ui-doc--hide-frame) (lsp-ui-doc--hide-frame)))
  :defer-config
  (setq lsp-ui-doc-border (face-foreground 'font-lock-comment-face))
  (lsp-ui-sideline-set-default-icon))

(leaf marginalia
  :init
  (setq marginalia-align 'right))

(leaf meta-view
  :defer-config
  (jcs-add-hook 'meta-view-after-insert-hook
    ;; Hook runs after meta-view buffer insertion.
    (jcs-prog-mode-hook)
    (display-line-numbers-mode 1)
    (setq-local ts-fold-summary-show nil)
    (jcs-save-excursion  ; fold all comments
      (goto-char (point-min))
      (call-interactively #'ts-fold-close)
      (let (continuation)
        (while (not (eobp))
          (forward-line 1)
          (end-of-line)
          (if (jcs-inside-comment-p)
              (unless continuation
                (call-interactively #'ts-fold-close)
                (setq continuation t))
            (setq continuation nil)))))))

(leaf minions
  :init
  (setq minions-mode-line-delimiters nil
        minions-mode-line-lighter ""))

(leaf moody
  :init
  (setq x-underline-at-descent-line t)
  :defer-config
  (require 'jcs-mode-line)
  ;; XXX For issue, https://github.com/tarsius/moody/pull/41
  (advice-add 'moody-redisplay :around
              (lambda (fnc &rest args) (let ((inhibit-redisplay t)) (apply fnc args)))))

(leaf most-used-words
  :init
  (setq most-used-words-display-type 'table
        most-used-words-word-display 100))

(leaf multi-shell
  :init
  (setq multi-shell-prefer-shell-type 'shell))  ; Accept `shell' or `eshll'.

(leaf multiple-cursors
  :init
  (defconst jcs-mc/cancel-commands
    (append
     '(jcs-previous-blank-line jcs-next-blank-line)
     '(jcs-isearch-backward-symbol-at-point
       isearch-forward-symbol-at-point
       jcs-isearch-repeat-backward
       jcs-isearch-repeat-forward)
     '(jcs-isearch-project-backward-symbol-at-point
       isearch-project-forward-symbol-at-point
       jcs-isearch-project-repeat-backward
       jcs-isearch-project-repeat-forward))
    "List of commands that will quite `multiple-cursors' after execution.")

  (defun jcs-mc/cancel-multiple-cursors (&rest _)
    "Cancel the `multiple-cursors' behaviour."
    (when (and (functionp 'mc/num-cursors) (> (mc/num-cursors) 1))
      (mc/keyboard-quit)))

  (dolist (cmd jcs-mc/cancel-commands)
    (advice-add cmd :after #'jcs-mc/cancel-multiple-cursors))
  :defer-config
  (defun jcs--mc/mark-lines (num-lines direction)
    "Override `mc/mark-lines' function."
    (let ((cur-column (current-column)))
      (dotimes (i (if (= num-lines 0) 1 num-lines))
        (mc/save-excursion
         (let ((furthest-cursor (cl-ecase direction
                                  (forwards  (mc/furthest-cursor-after-point))
                                  (backwards (mc/furthest-cursor-before-point)))))
           (when (overlayp furthest-cursor)
             (goto-char (overlay-get furthest-cursor 'point))
             (when (= num-lines 0)
               (mc/remove-fake-cursor furthest-cursor))))
         (cl-ecase direction
           (forwards (next-logical-line 1 nil))
           (backwards (previous-logical-line 1 nil)))
         (move-to-column cur-column)
         (mc/create-fake-cursor-at-point)))))
  (advice-add 'mc/mark-lines :override #'jcs--mc/mark-lines))

(leaf popup
  :defer-config
  (defvar jcs-popup-mouse-events-flag-p nil
    "Check if `popup-menu-item-of-mouse-event' is called.")

  (defvar jcs-popup-selected-item-flag-p nil
    "Check if `popup-selected-item' is called.")

  (defun jcs-popup-clicked-on-menu-p ()
    "Check if the user actually clicked on the `popup' object."
    (and jcs-popup-mouse-events-flag-p
         (not jcs-popup-selected-item-flag-p)))

  (jcs-advice-add 'popup-menu-item-of-mouse-event :after
    (setq jcs-popup-mouse-events-flag-p t
          jcs-popup-selected-item-flag-p nil))

  (jcs-advice-add 'popup-selected-item :after
    (setq jcs-popup-selected-item-flag-p (jcs-last-input-event-p "mouse-1")))

  (defun jcs--popup-draw--advice-around (fnc &rest args)
    "Advice around execute command `popup-draw'."
    (let ((do-orig-fun t))
      (when (and (jcs-last-input-event-p "mouse-1")
                 (not (jcs-popup-clicked-on-menu-p)))
        (keyboard-quit)
        (setq do-orig-fun nil))
      (when do-orig-fun (apply fnc args))))
  (advice-add 'popup-draw :around #'jcs--popup-draw--advice-around))

(leaf pos-tip
  :init
  (setq pos-tip-internal-border-width 5))

(leaf project
  :defer-config
  (setq project-vc-ignores
        (append project-vc-ignores
                '(".idea" ".vscode"
                  ".ensime_cache" ".eunit"
                  ".git" ".hg" ".fslckout"
                  "_FOSSIL_" ".bzr" "_darcs"
                  ".tox" ".svn"
                  ".stack-work" ".ccls-cache" ".cache" ".clangd")
                '(".log" ".vs" "node_modules"))))

(leaf quelpa
  :defer-config
  (jcs-add-hook 'quelpa-before-hook (setq jcs-package-installing-p t))
  (jcs-add-hook 'quelpa-after-hook (setq jcs-package-installing-p nil)))

(leaf quick-peek
  :init
  (defun jcs-quick-peek--form-face (fg &optional weight)
    "Form `quick-peek' face with FG."
    (unless weight (setq weight 'normal))
    (let ((color (or (face-attribute 'highlight :background) "black")))
      `(:background ,color :foreground ,fg :inherit quick-peek-border-face :weight ,weight)))

  (defun jcs-set-quick-peek-spacers (buf ln)
    "Prepare quick peek header and footer."
    (let ((default-face (jcs-quick-peek--form-face "white")))
      (setq jcs-quick-peek--spacer-header
            (concat
             (if (jcs-last-line-in-buffer-p) "\n" "")
             (propertize " " 'face default-face)
             (propertize (buffer-name buf) 'face (jcs-quick-peek--form-face "black" 'bold))
             (propertize " " 'face default-face)
             (propertize (buffer-file-name buf) 'face (jcs-quick-peek--form-face "#222"))
             (propertize "\n" 'face default-face))
            jcs-quick-peek--spacer-footer
            (propertize (concat (jcs-env-separator)
                                (if (eq quick-peek-position 'below) "" "\n"))
                        'face default-face))))

  (defun jcs-quick-peek--scroll-to-see ()
    "Scroll buffer in order to see the full `quick-peek' content."
    (let ((default-max-h 16) (ln-current (line-number-at-pos)) lvl ln-diff)
      (when (eq quick-peek-position 'below)
        (setq lvl (jcs-last-visible-line-in-window)
              ln-diff (- lvl ln-current))
        (when (< ln-diff default-max-h)
          (scroll-up-line (- default-max-h ln-diff))))))
  :defer-config
  (defvar jcs-quick-peek--spacer-header nil
    "Header string for `quick-peek'")
  (defvar jcs-quick-peek--spacer-footer nil
    "Footer string for `quick-peek'.")
  (defun jcs--quick-peek--insert-spacer--advice-override (pos str-before str-after)
    "Advice exection override function `quick-peek--insert-spacer'."
    (let ((str (if (= pos (point-min)) jcs-quick-peek--spacer-header
                 jcs-quick-peek--spacer-footer)))
      (save-excursion (goto-char pos) (insert str))))
  (advice-add 'quick-peek--insert-spacer :override #'jcs--quick-peek--insert-spacer--advice-override))

(leaf region-occurrences-highlighter
  :init
  (setq region-occurrences-highlighter-min-size 1))

(leaf right-click-context
  :defer-config
  (defun right-click-context-menu ()
    "Open Right Click Context menu."
    (interactive)
    (let ((popup-menu-keymap (copy-sequence popup-menu-keymap)))
      (define-key popup-menu-keymap [mouse-3] #'right-click-context--click-menu-popup)
      (let ((value (popup-cascade-menu (right-click-context--build-menu-for-popup-el (right-click-context--menu-tree) nil))))
        (when (and (jcs-popup-clicked-on-menu-p) value)
          (if (symbolp value) (call-interactively value t) (eval value)))))))

(leaf searcher
  :init
  (setq searcher-search-type 'regex  ; `regex' or `flx'
        searcher-flx-threshold 25))

(leaf show-eol
  :defer-config
  (show-eol-set-mark-with-string 'newline-mark "¶")
  (jcs-advice-add 'show-eol-enable :before
    (face-remap-add-relative 'whitespace-newline :inverse-video t))
  (jcs-advice-add 'show-eol-disable :before
    (face-remap-add-relative 'whitespace-newline :inverse-video nil)))

(leaf sql-indent
  :init
  ;; URL: https://www.emacswiki.org/emacs/SqlIndent

  ;; 1 = 2 spaces,
  ;; 2 = 4 spaces,
  ;; 3 = 6 spaces,
  ;; n = n * 2 spaces,
  ;; etc.
  (setq sql-indent-offset 1))

(leaf tree-sitter-langs
  :hook (tree-sitter-after-on-hook . tree-sitter-hl-mode)
  :defer-config
  (defconst jcs--tree-sitter-langs--query-repo
    "https://github.com/jcs-emacs/tree-sitter-queries"
    "Repository URL where stores all tree-sitter highlight queries.")

  (defun jcs--tree-sitter-grab-queries ()
    "Download all custom queries to the `tree-sitter-langs' queries folder."
    (require 'find-func)
    (let* ((default-directory (file-name-directory (find-library-name "tree-sitter-langs")))
           (repo-url (shell-quote-argument jcs--tree-sitter-langs--query-repo))
           (dirname (file-name-base jcs--tree-sitter-langs--query-repo))
           (clone-dir (expand-file-name dirname))
           (clone-queries (expand-file-name "queries" clone-dir))
           (dest-queries (expand-file-name "queries" default-directory))
           lang-dirs)
      (ignore-errors (delete-directory (expand-file-name dirname default-directory) t))
      (when (= 0 (shell-command (format "git clone %s" repo-url)))
        (setq lang-dirs (directory-files clone-queries))
        (pop lang-dirs) (pop lang-dirs)  ; remove . and ..
        (message "Installing custom tree-sitter query...")
        (dolist (lang-dir lang-dirs)
          (message "  - %s" lang-dir)
          (ignore-errors
            (delete-directory (expand-file-name lang-dir clone-queries)))
          (ignore-errors
            (copy-directory (expand-file-name lang-dir clone-queries)
                            (expand-file-name lang-dir dest-queries)
                            nil nil t)))
        (delete-directory clone-dir t)
        (message "Done install custom tree-sitter queries"))))

  (defun jcs--tree-sitter-hl-mode-hook ()
    "Hook for `tree-sitter-hl-mode'."
    (remove-hook 'tree-sitter-hl-mode-hook #'jcs--tree-sitter-hl-mode-hook)
    (jcs--tree-sitter-grab-queries)
    (tree-sitter-hl-mode 1))  ; re-enable it once
  (add-hook 'tree-sitter-hl-mode-hook #'jcs--tree-sitter-hl-mode-hook))

(leaf ts-fold
  :hook (tree-sitter-after-on-hook . ts-fold-indicators-mode)
  :init
  (setq ts-fold-indicators-fringe 'left-fringe
        ts-fold-indicators-face-function #'jcs--ts-fold-indicators-face-function)
  :defer-config
  (require 'line-reminder)
  (defun jcs--ts-fold-indicators-face-function (pos &rest _)
    "Return the face of it's function."
    (let ((line (line-number-at-pos pos t))) (line-reminder--get-face line)))

  (jcs-advice-add 'line-reminder-transfer-to-saved-lines :after
    ;; Refresh indicators for package `ts-fold'.
    (ts-fold-indicators-refresh)))

(leaf treemacs
  :init
  (setq treemacs-position 'right
        treemacs-missing-project-action 'remove
        treemacs-sorting 'alphabetic-asc
        treemacs-follow-after-init t
        treemacs-no-png-images t)
  :defer-config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)

  (defvar jcs-treemacs-width-ratio 0.15
    "Ratio that respect to `frame-width' and `neo-window-width'.")

  (defun jcs-treemacs-toggle-refresh ()
    "Refresh `treemacs' by toggle twice."
    (save-selected-window (treemacs) (treemacs)))

  (jcs-add-hook 'window-size-change-functions
    (setq treemacs-width (round (* (frame-width) jcs-treemacs-width-ratio)))
    (when (treemacs-get-local-window) (jcs-treemacs-toggle-refresh)))

  (jcs-add-hook 'treemacs-mode-hook
    (setq buffer-wrap--relative-max-line 0)
    (buffer-wrap-mode 1)))

(leaf turbo-log
  :init
  (setq turbo-log-no-ask t))

(leaf un-mini
  :init
  (setq un-mini-abort-commands '(right-click-context-click-menu)))

(leaf undo-tree
  :defer-config
  (global-undo-tree-mode t))

(leaf use-ttf
  :init
  (setq use-ttf-default-ttf-fonts
        (mapcar (lambda (file) (concat user-emacs-directory file))
                '("fonts/clacon.ttf"
                  "fonts/UbuntuMono-R.ttf"))
        use-ttf-default-ttf-font-name "Ubuntu Mono"))

(leaf vertico
  :hook (rfn-eshadow-update-overlay-hook . vertico-directory-tidy)
  :init
  (setq vertico-cycle t
        vertico-resize t
        vertico-scroll-margin 0
        vertico-sort-function #'jcs-vertico--sort-function)
  :defer-config
  (require 'jcs-vertico)
  (defconst jcs-vertico-height-ratio 0.3
    "Ratio that respect to `frame-height' and `vertico-count'."))

(leaf web-mode
  :init
  ;; Indentation
  (setq web-mode-markup-indent-offset 2  ; html
        web-mode-css-indent-offset 2     ; css
        web-mode-code-indent-offset 2    ; script
        web-mode-style-padding 2   ; For `<style>' tag
        web-mode-script-padding 2  ; For `<script>' tag
        web-mode-block-padding 0   ; For `php', `ruby', `java', `python', `asp', etc.
        web-mode-offsetless-elements '("html"))
  :defer-config
  ;; NOTE: Do not make these lists to one list.
  ;; They are totally different list.
  (defvar jcs-web-mode-offsetless-elements-toggle '("html")
    "List of HTML elements you want to be toggable to the
`wen-mode-offsetless-elements' list in Web mode."))

(leaf which-key
  :init
  (setq which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        which-key-side-window-max-width 0.33
        which-key-side-window-max-height 0.25
        which-key-dont-use-unicode t
        which-key-idle-delay 1.0))

(leaf yascroll
  :init
  (setq yascroll:delay-to-hide 0.8
        yascroll:priority 50))

(leaf yasnippet
  :init
  (setq yas-verbosity 0)
  :defer-config
  (require 'yasnippet-snippets)
  (yas-global-mode 1))

(provide 'jcs-plugin)
;;; jcs-plugin.el ends here
