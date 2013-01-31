;; Customize stuff... 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Linum-format "%7i ")
 '(ansi-term-color-vector [unspecified "#110F13" "#d13120" "#81af34" "#deae3e" "#7e9fc9" "#7878b5" "#7e9fc9" "#dcdddd"] t)
 '(auto-install-save-confirm nil)
 '(autopair-global-mode t)
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(current-language-environment "UTF-8")
 '(custom-safe-themes t)
 '(custom-theme-load-path (quote (
"~/.emacs.d/elpa/cyberpunk-theme-20121015.1228/" "~/.emacs.d/elpa/inkpot-theme-20120505.908/" "~/.emacs.d/elpa/molokai-theme-20120503.1929/" "~/.emacs.d/elpa/monokai-theme-0.0.8/" "~/.emacs.d/elpa/subatomic-theme-20121226.1934/" "~/.emacs.d/elpa/tango-2-theme-20120312.1325/" "~/.emacs.d/elpa/underwater-theme-20120615.1149/" "~/.emacs.d/elpa/zen-and-art-theme-20120622.937/" "~/.emacs.d/elpa/zenburn-theme-20130110.1020/" custom-theme-directory t "~/.emacs.d/vendor/emacs-soothe-theme/")))
 '(display-time-mode nil)
 '(display-time-world-time-format "%A %d %B %R %Z (%z)")
 '(ediff-custom-diff-program "diff")
 '(ediff-diff-program "diff")
 '(ediff-diff3-program "diff3")
 '(fci-rule-character-color "#202020")
 '(fci-rule-color "#202020")
 '(fringe-mode 4 nil (fringe))
 '(global-hl-line-mode nil)
 '(global-visual-line-mode t)
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote right))
 '(inhibit-startup-screen t)
 '(initial-buffer-choice nil)
 '(initial-scratch-message nil)
 '(ispell-dictionary nil)
 '(js3-indent-level 4)
 '(linum-delay nil)
 '(linum-eager t)
 '(linum-format "%7d")
 '(make-backup-files nil)
 '(markdown-command "redcarpet")
 '(markdown-css-path "~/.emacs.d/markdown.css")
 '(safe-local-variable-values (quote ((eval ignore-errors "Write-contents-functions is a buffer-local alternative to before-save-hook" (add-hook (quote write-contents-functions) (lambda nil (delete-trailing-whitespace) nil)) (require (quote whitespace)) "Sometimes the mode needs to be toggled off and on." (whitespace-mode 0) (whitespace-mode 1)) (whitespace-line-column . 80) (whitespace-style face trailing lines-tail) (require-final-newline . t))))
 '(scroll-bar-mode nil)
 '(scss-compile-at-save nil)
 '(tab-width 4)
 '(tabbar-background-color "grey20")
 '(tabbar-separator (quote (0.2)))
 '(truncate-lines t)
 '(visible-bell t)
 '(window-left-margin 0)
 '(yas/prompt-functions (quote (yas/dropdown-prompt yas/x-prompt yas/completing-prompt yas/ido-prompt yas/no-prompt)))
 '(zoneinfo-style-world-list (quote (("Australia/Sydney" "Sydney") ("Europe/London" "London") ("Thailand/Bangkok" "Bangkok") ("America/Vancouver" "Vancouver") ("America/Los_Angeles" "San Fransisco") ("America/New_York" "New York") ("Asia/Shanghai" "Shanghai") ("Asia/Tokyo" "Tokyo")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(markdown-header-face ((t (:inherit font-lock-function-name-face :weight bold :family "Helvetica Neue"))) t)
 '(markdown-header-face-1 ((t (:inherit markdown-header-face :height 2.0))) t)
 '(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.9))) t)
 '(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.8))) t)
 '(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.7))) t)
 '(markdown-header-face-5 ((t (:inherit markdown-header-face :height 1.6))) t)
 '(markdown-header-face-6 ((t (:inherit markdown-header-face :height 1.5))) t))

