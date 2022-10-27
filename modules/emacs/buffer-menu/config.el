;;; emacs/buffer-menu/config.el  -*- lexical-binding: t; -*-

(leaf buffer-menu-filter
  :init
  (setq buffer-menu-filter-delay 0.2))

(leaf diminish-buffer
  :init
  (setq diminish-buffer-list
        '( "[*]jcs"  ; config wise
           "[*]helm" "[*]esup-" "[*]quelpa-"
           "[*]compilation" "[*]output" "[*]execrun"
           "[*]quickrun"
           "[*]Apropos[*]" "[*]Backtrace[*]" "[*]Compile-Log[*]"
           "[*]Help[*]" "[*]Bug Help[*]"
           "[*]Warnings[*]"
           "[*]VC-history[*]"
           "[*]CPU-Profiler-Report" "[*]Memory-Profiler-Report"
           "[*]Process List[*]"
           "[*]Checkdoc " "[*]Elint[*]" "[*]Package-Lint[*]" "[*]relint[*]"
           "[*]Finder[*]"
           "[*]Async Shell Command[*]" "[*]shell" "[*]eshell" "bshell<"
           "[*]eww" "[*]ESS[*]"
           "[*]emacs[*]"  ; From `async'
           ;; `lsp-mode'
           "[*]lsp-" "[*]LSP[ ]+"
           "[*][a-zA-Z0-9]+[-]*ls" "[*][a-zA-Z0-9]+::stderr[*]"
           "[*]csharp[*]"
           "[*]rust-analyzer[*:]"
           "[*]tcp-server-sonarlint"
           "[*]pyright[*]"
           "[*]tree-sitter" "tree-sitter-tree:"
           "[*]company"
           "[*]editorconfig"
           "[*]prettier"
           "[*]Local Variables[*]"
           "[*]Kill Ring[*]"  ; From `browse-kill-ring'
           "[*]SPEEDBAR"
           "[*]Flycheck" "[*]Flymake log[*]"
           "[*]httpd[*]"
           "[*]helpful" "[*]suggest[*]"
           "[*]ert[*]" "[*]indent-lint"
           "[*]elfeed-"
           "magit[-]*[[:ascii:]]*[:]"  ; From `magit'
           "[*]Most used words[*]"
           "[*]Test SHA[*]"
           "[*]RE-Builder"
           "[*]define-it: tooltip[*]" "[*]preview-it" "[*]gh-md"
           "[*]wclock[*]"
           "[*]Clippy[*]"
           "[*]CMake Temporary[*]"
           "[*]org-src-fontification"
           "[*]ASCII[*]"
           "[*]npm:" "[*]hexo"
           "[*]Flutter")
        diminish-buffer-mode-list '( "dired-mode"
                                     "shell-mode" "eshell-mode")))

;;
;; (@* "Hook" )
;;

(jcs-add-hook 'Buffer-menu-mode-hook
  (require 'buffer-menu-project)

  (buffer-menu-filter-mode 1)
  (diminish-buffer-mode 1)  ; refresh the menu immediately

  (jcs-key-local
    `(((kbd "C-k"))
      ((kbd "M-K")      . buffer-menu-filter-refresh)
      ;; Searching / Filtering
      ((kbd "<escape>") . (lambda () (interactive) (buffer-menu-filter-refresh)
                            (top-level))))))
