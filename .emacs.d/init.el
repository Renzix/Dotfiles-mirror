;; Keep track of loading time
(defconst emacs-start-time (current-time))
;; initalize all ELPA packages
(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/"))
(add-to-list 'package-archives '("GNU" . "https://elpa.gnu.org/packages/"))
(package-refresh-contents)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
;;(setq package-enable-at-startup nil)
;;(let ((elapsed (float-time (time-subtract (current-time)
;;					  emacs-start-time))))
;;  (message "Loaded packages in %.3fs" elapsed))

(require 'use-package)
;; Load use-package, used for loading packages
(require 'use-package-ensure)
(setq use-package-always-ensure t)
(setq vc-follow-symlinks t)
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package org-evil
  :after evil
  :init
  (setq evil-want-keybinding nil))
(org-babel-load-file
 (expand-file-name "settings.org"
		   user-emacs-directory))

;; Message how long it took to load everything (minus packages)
(let ((elapsed (float-time (time-subtract (current-time)
					  emacs-start-time))))
  (message "Loading settings...done (%.3fs)" elapsed))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#424242" "#EF9A9A" "#C5E1A5" "#FFEE58" "#64B5F6" "#E1BEE7" "#80DEEA" "#E0E0E0"])
 '(beacon-color "#7fff00007fff")
 '(custom-safe-themes
   '("bf390ecb203806cbe351b966a88fc3036f3ff68cd2547db6ee3676e87327b311" "5a0eee1070a4fc64268f008a4c7abfda32d912118e080e18c3c865ef864d1bea" default))
 '(delete-selection-mode nil)
 '(evil-emacs-state-cursor '("#E57373" hbar) t)
 '(evil-insert-state-cursor '("#E57373" bar) t)
 '(evil-insert-state-modes
   '(comint-mode geiser-repl-mode gud-mode inferior-apl-mode inferior-caml-mode inferior-emacs-lisp-mode inferior-j-mode inferior-python-mode inferior-scheme-mode inferior-sml-mode internal-ange-ftp-mode prolog-inferior-mode reb-mode shell-mode slime-repl-mode wdired-mode))
 '(evil-normal-state-cursor '("#FFEE58" box) t)
 '(evil-visual-state-cursor '("#C5E1A5" box) t)
 '(highlight-indent-guides-auto-enabled nil)
 '(highlight-symbol-colors
   '("#FFEE58" "#C5E1A5" "#80DEEA" "#64B5F6" "#E1BEE7" "#FFCC80"))
 '(highlight-symbol-foreground-color "#E0E0E0")
 '(highlight-tail-colors '(("#7fff00007fff" . 0) ("#424242" . 100)))
 '(package-selected-packages
   '(mu4e-alert evil-mu4e go-mode go lsp-mode emms evil-magit which-key tracking system-packages slime-company request racer quelpa-use-package ox-pandoc org-evil nord-theme nix-mode magit-popup kdeconnect htmlize helm-system-packages helm-rg helm-projectile helm-nixos-options helm-circe git-commit general forge flylisp erc-twitch erc-tweet erc-image elcord company-racer company-nixos-options company-irony company-c-headers company-anaconda comment-tags clippy cargo autopair apropospriate-theme))
 '(pos-tip-background-color "#000000000000")
 '(pos-tip-foreground-color "#9E9E9E")
 '(tabbar-background-color "#000000000000"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
