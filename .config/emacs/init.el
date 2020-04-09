;; Welcome to renzix's second emacs config
;; This one is going to be as vanilla emacs as possible

;;; Garbage Collection for speed
(setq gc-cons-threshold 10000000)
;; Restore after startup
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold 1000000)
            (message "gc-cons-threshold restored to %S"
                     gc-cons-threshold)))
(setq read-process-output-max (* 1024 1024))

;;; Package Stuff
(setq package-enable-at-startup nil
      package-archives
      '(("elpa"     . "https://elpa.gnu.org/packages/")
        ("melpa"        . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("elpa"     . 5) ("melpa"        . 10)))
(package-refresh-contents)

;; Macros

(defmacro use! (package)
  `(unless (package-installed-p ,package)
     (package-install ,package)))

(defmacro before! (package stuff)
  stuff)

(defalias 'after! 'with-eval-after-load)

(use! '0x0)
(use! 'amx)
(use! 'anzu)
(use! 'auctex)
(use! 'avy)
(use! 'browse-kill-ring)
(use! 'command-log-mode)
(use! 'comment-dwim-2)
(use! 'company)
(use! 'company-lsp)
(use! 'crux)
(use! 'dap-mode)
(use! 'deadgrep)
(use! 'doom-themes)
(use! 'easy-kill)
(use! 'emms)
(use! 'erc-hl-nicks)
(use! 'erc-image)
(use! 'expand-region)
(use! 'flycheck)
(use! 'flycheck-perl6)
(use! 'git-gutter)
(use! 'git-timemachine)
(use! 'hl-todo)
(use! 'ido-completing-read+)
(use! 'lsp-java)
(use! 'lsp-mode)
(use! 'lsp-python-ms)
(use! 'lsp-ui)
(use! 'lua-mode)
(use! 'magit)
(use! 'magit-todos)
(use! 'perl6-mode)
(use! 'powershell)
(use! 'projectile)
(use! 'projectile-ripgrep)
(use! 'rainbow-delimiters)
(use! 'rustic)
(use! 'try)
(use! 'vterm)
(use! 'which-key)
(use! 'yasnippet)
(use! 'yasnippet-snippets)

(add-to-list 'load-path "~/Dotfiles/.config/emacs/elisp")
(require 'better-registers)

;;; Config

;; Sane defaults
(setq inhibit-startup-screen t
      initial-buffer-choice nil
      confirm-kill-processes nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Magic that makes only 2 windows spawn max
(setq split-width-threshold (- (window-width) 10))
(setq split-height-threshold nil)
(defun count-visible-buffers (&optional frame)
  "Count how many buffers are currently being shown.  Defaults to selected FRAME."
  (length (mapcar #'window-buffer (window-list frame))))
(defun do-not-split-more-than-two-windows (window &optional horizontal)
  "WINDOW HORIZONTAL."
  (if (and horizontal (> (count-visible-buffers) 1))
      nil
    t))
(advice-add 'window-splittable-p
            :before-while #'do-not-split-more-than-two-windows)

(show-paren-mode 1)
(global-hl-line-mode)
(setq vc-follow-symlinks t)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq-default indent-tabs-mode nil)
(setq tab-width 4)

(setq backup-directory-alist `(("." . "~/.saves"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 10
      kept-old-versions 10
      version-control t
      auto-save-list-file-prefix nil)

(prefer-coding-system 'utf-8)

;; Dired

(setq dired-isearch-filenames 'dwim
      delete-by-moving-to-trash t)

;; Ido
(setq ido-enable-flex-matching t
      ido-everywhere t
      ido-use-filename-at-point 'guess
      ido-create-new-buffer 'always
      ido-file-extensions-order     '(".cc" ".h" ".tex" ".sh" ".org"
                                      ".el" ".tex" ".png")
      completion-ignored-extensions '(".o" ".elc" "~" ".bin" ".bak"
                                      ".obj" ".map" ".a" ".so"
                                      ".mod" ".aux" ".out" ".pyg")
      ido-ignore-extensions t)
(ido-mode t)
(setq magit-completing-read-function 'magit-ido-completing-read)
(ido-ubiquitous-mode 1)
;; Allows spaces for ido mode
(add-hook 'ido-make-file-list-hook
          (lambda ()
            (define-key ido-file-dir-completion-map (kbd "SPC") 'ido-restrict-to-matches)))

;; Org mode

(setq-default initial-major-mode 'org-mode
              initial-scratch-message ""
              org-src-tab-acts-natively t
              org-confirm-babel-evaluate nil
              org-return-follows-link t)
(setq org-log-done 'time
      org-src-window-setup 'current-window
      org-todo-keywords '((sequence "TODO(t)" "SOMEDAY(s)" "NEXT(n)" "|")
                          (sequence "WORKING(w!)" "BLOCKED(B@)" "|")
                          (sequence "REPORT(r)" "BUG(b)" "KNOWN(k)" "|" "FIXED(f!)")
                          (sequence "|" "DONE(d)" "CANCEL(c@)")
                          (sequence "|" "STUDY(y!)")))
(org-babel-do-load-languages
 'org-babel-load-languages
 '((org . t)
   (C . t)
   (latex . t)
   (emacs-lisp . t)
   (sql . t)
   (shell . t)
   (python . t)))

(require 'whitespace)
(setq whitespace-line-column 80) ;; limit line length
(setq whitespace-style '(face lines-tail))
(add-hook 'prog-mode-hook 'whitespace-mode)

;; Package

(global-flycheck-mode)

(before! 'company
         (progn
           (add-hook 'prog-mode-hook 'company-mode)))

(after! 'company
  (progn
    (setq company-minimum-prefix-length 1
          company-idle-delay 0.1) ;; default is 0.2
    (require 'company-lsp)
    (add-to-list 'company-backends 'company-lsp)
    (define-key company-active-map (kbd "<return>") nil)
    (define-key company-active-map (kbd "RET") nil)
    (define-key company-active-map (kbd "C-SPC") 'company-complete-selection)))

(after! 'erc
  (setq renzix-erc-user-colors '())
  (defun my-hl-thing ()
    (put-text-property
     (beginning-of-thing 'word) (end-of-thing 'word)
     'font-lock-face `(:foreground ,(erc-hl-nicks-color-for-nick (word-at-point)))))
  (defun erc-nixhubd-fix ()
    (when (string-prefix-p "<nixhubd>" (buffer-string))
      (goto-char (point-min))
      (delete-char 10)
      (insert "[")
      (skip-chars-forward "^:")
      (delete-char 1)
      (insert "]")
      (skip-chars-backward "^[")
      (forward-char)
      ;; (unless (member (word-at-point) renzix-erc-user-colors)
      ;;   (add-to-list renzix-erc-user-colors (word-at-point))
        ;; (erc-hl-nicks-face-name (word-at-point)))
      (my-hl-thing)))

  (setq ;; erc-autojoin-channels-alist
        ;; '(("freenode.net" "#emacs" "#erc" "#nixhub"
        ;;    "#kisslinux" "#vim" "#neovim" "##linux"
        ;;   "#gentoo" "#gentoo-chat" "#org-mode" "#bash"))
        erc-kill-buffer-on-part t
        erc-kill-server-buffer-on-quit t
        erc-nick "Renzix"
        erc-hide-list '("JOIN" "PART" "QUIT")
        erc-lurker-hide-list '("JOIN" "PART" "QUIT")
        erc-track-exclude-types '("JOIN" "MODE" "NICK" "PART" "QUIT"
                                  "324" "329" "332" "333" "353" "477"))
  (add-hook 'erc-insert-modify-hook 'erc-nixhubd-fix))

(before! 'lsp
         (progn 
           (add-hook 'prog-mode-hook 'lsp)
           (add-hook 'lsp-mode-hook 'company-mode)
           (add-hook 'lsp-mode-hook 'lsp-ui-mode)
           (add-hook 'lsp-mode-hook 'lsp-enable-which-key-integration)))

(after! 'lsp
  (progn
    (setq lsp-ui-sideline-enable t
          lsp-ui-doc-enable t
          lsp-ui-flycheck-enable t
          lsp-ui-imenu-enable t
          lsp-ui-sideline-ignore-duplicate t)))

;; Random Packages
(amx-mode t)
(global-git-gutter-mode +1)
(load-theme 'doom-wilmersdorf t)
(global-git-gutter-mode t)
(setq projectile-enable-caching t
      projectile-file-exists-local-cache-expire (* 5 60)
      projectile-file-exists-remote-cache-expire (* 10 60)
      projectile-sort-order 'recently-active)
(projectile-mode t)
(which-key-mode t)
(yas-global-mode t)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
(setq-default cursor-type 'box)
(set-cursor-color "#43DE43")
(global-hl-todo-mode)
(delete-selection-mode 1)
(pcre-mode t)

;; Useful Functions

(defun dired-dotfiles-toggle ()
  "Show/hide dot-files."
  (interactive)
  (when (equal major-mode 'dired-mode)
    ;; if currently showing
    (if (or (not (boundp 'dired-dotfiles-show-p)) dired-dotfiles-show-p) 
	(progn 
	  (set (make-local-variable 'dired-dotfiles-show-p) nil)
	  (message "h")
	  (dired-mark-files-regexp "^\\\.")
	  (dired-do-kill-lines))
      (progn (revert-buffer) ; otherwise just revert to re-show
	     (set (make-local-variable 'dired-dotfiles-show-p) t)))))

(defun my/switch-to-vterm ()
  "Switch to vterm."
  (if (get-buffer "vterm")
      (switch-to-buffer "vterm")
    (vterm)))

(defun my/vterm-toggle (buf-name)
  "Switch to vterm and save persp.  BUF-NAME is the current buffer name."
  (interactive (list (buffer-name)))
  (if (string-equal buf-name "vterm")
      (set-window-configuration my:window-conf)
    (progn
      (setq my:window-conf (current-window-configuration))
      (delete-other-windows)
      (my/switch-to-vterm))))

(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

;;; Keybinds

;; Global
(global-set-key (kbd "M-x") 'amx)
(global-set-key (kbd "M-X") 'amx-major-mode-commands)
;; Smarter commands which dwim alot more
(global-set-key (kbd "C-a") 'crux-move-beginning-of-line)
(global-set-key (kbd "C-k") 'crux-smart-kill-line)
(global-set-key (kbd "C-o") 'crux-smart-open-line)
(global-set-key (kbd "M-o") 'crux-smart-open-line-above)
(global-set-key (kbd "M-%") 'anzu-query-replace-regexp)
(global-set-key (kbd "M-m") 'kmacro-keymap)
(global-set-key (kbd "M-;") 'comment-dwim-2)
(global-set-key (kbd "C-,") 'kmacro-start-macro-or-insert-counter)
(global-set-key (kbd "C-.") 'kmacro-end-or-call-macro)
(global-set-key (kbd "M-<left>") (lambda () (interactive) (transpose-words -1)))
(global-set-key (kbd "M-<right>") (lambda () (interactive) (transpose-words 1)))
(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-S-<down>") 'crux-duplicate-current-line-or-region)
(global-set-key (kbd "M-S-<up>") (lambda () (interactive)
                                   (crux-duplicate-current-line-or-region 1)
                                   (previous-line)
                                   (scroll-up-line)))
(global-set-key (kbd "C-^") 'crux-top-join-line)
(global-set-key (kbd "C-S-<backspace>") 'crux-kill-whole-line)

;; M-w is now 10x better
(global-set-key [remap kill-ring-save] 'easy-kill)
(global-set-key [remap mark-sexp] 'easy-mark)
;; M-z is forwards so C-z is backwards
(global-set-key (kbd "C-z")
                (lambda (arg char)
                  (interactive "p\ncZap to char: ")
                  (zap-to-char -1 char)))
;; C-M-y should go back 1 in kill ring because M-- M-y is long
(global-set-key (kbd "C-M-y") (lambda () (interactive) (yank-pop -1)))

;; Ibuffer is just better list-buffers and C-x f
;; to be consistant with ibuffer/switch-buffers
(global-set-key (kbd "C-x f") 'dired-jump)
(global-set-key (kbd "C-x C-f") 'find-file)
(global-set-key (kbd "C-x b") 'ibuffer)
(global-set-key (kbd "C-x C-b") 'switch-to-buffer)
;; Move around windows
(global-set-key (kbd "C-x 4 t") 'crux-transpose-windows)

;; Nice functions that should be default but dont exist for ??? reason
(global-set-key (kbd "C-c D") 'crux-delete-file-and-buffer)
(global-set-key (kbd "C-c R") 'crux-rename-file-and-buffer)
(global-set-key (kbd "C-c y") 'browse-kill-ring)
(global-set-key (kbd "C-c v") 'my/vterm-toggle)
(global-set-key (kbd "C-c s") 'deadgrep)
(global-set-key (kbd "C-c c") 'projectile-compile-project)
(global-set-key (kbd "C-c t") 'crux-transpose-windows)
(global-set-key (kbd "C-c k") 'crux-kill-other-buffers)
(global-set-key (kbd "C-c I") 'crux-find-user-init-file)
(global-set-key (kbd "C-c o") 'crux-open-with)

;; Projectile
(global-set-key (kbd "C-c p") 'projectile-command-map)
(global-set-key (kbd "C-c p s") 'projectile-ripgrep)

;; Magit
(global-set-key (kbd "C-c g g") 'magit-status)
(global-set-key (kbd "C-c g t") 'git-timemachine-toggle)
(global-set-key (kbd "C-c g s") 'magit-stage-file)
(global-set-key (kbd "C-c g u") 'magit-unstage-file)
(global-set-key (kbd "C-c g c") 'magit-commit)
(global-set-key (kbd "C-c g p") 'magit-push-current-to-upstream)
(global-set-key (kbd "C-c g P") 'magit-push-current-to-pushremote)

;; Local

(setq lsp-keymap-prefix (kbd "C-c l"))

(after! 'dired
  (define-key dired-mode-map (kbd ".") 'dired-dotfiles-toggle))

(put 'dired-find-alternate-file 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(erc-image erc-hl-nicks try anzu auctex command-log-mode comment-dwim-2 emms yasnippet-snippets which-key vterm rustic rainbow-delimiters projectile-ripgrep powershell perl6-mode md4rd magit-todos lua-mode lsp-ui lsp-python-ms lsp-java ido-completing-read+ git-timemachine git-gutter flycheck-perl6 expand-region easy-kill doom-themes deadgrep dap-mode crux company-lsp browse-kill-ring amx 0x0))
 '(safe-local-variable-values
   '((projectile-project-run-cmd . "./opengl")
     (projectile-project-compilation-cmd . "clang++ -o opengl -lglut -lGLU -lGL -lGLEW main.cpp"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'narrow-to-region 'disabled nil)
