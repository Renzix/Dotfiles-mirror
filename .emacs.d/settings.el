(use-package apropospriate-theme
  :ensure t
  :config (load-theme 'apropospriate-dark t))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode)
(setq-default display-line-numbers-type 'relative
	      display-line-numbers-current-absolute t
	      display-line-numbers-width 4
	      display-line-numbers-widen t)

;; @TODO(automatically get use-package

(use-package quelpa
  :init '(setq quelpa-upgrade-p t
	       quelpa-stable-p t))
(use-package quelpa-use-package)
(use-package general
  :config (general-evil-setup t))
(defvar HOME (getenv "HOME"))
(defvar WM nil)

(defun eshell/clear ()
  "Clear the eshell buffer."
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))
(defun kill-other-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))

(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "New name: ")
  (let ((name (buffer-name))
	(filename (buffer-file-name)))
    (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
	  (message "A buffer named '%s' already exists!" new-name)
	(progn
	  (rename-file filename new-name 1)
	  (rename-buffer new-name)
	  (set-visited-file-name new-name)
	  (set-buffer-modified-p nil))))))

(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
	  (vc-delete-file filename)
	(progn
	  (delete-file filename)
	  (message "Deleted file %s" filename)
	  (kill-buffer))))))

(defun sudo-edit (&optional arg)
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
			 (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun reset-erc-track-mode ()
  (interactive)
  (setq erc-modified-channels-alist nil)
  (erc-modified-channels-update))
(global-set-key (kbd "C-c C-r") 'reset-erc-track-mode)

(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
 If there is no split, ie now window above the current one, an
 error is signaled."
  ;;  "Switches between the current buffer, and the buffer above the
  ;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
	(error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun buf-move-down ()
  "Swap the current buffer and the buffer under the split.
 If there is no split, ie now window under the current one, an
 error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
	    (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
	(error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
 If there is no split, ie now window on the left of the current
 one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
	(error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
 If there is no split, ie now window on the right of the current
 one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (error "No right split")
    ;; swap top with this one
    (if (null other-win)
	(set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))
(defun get-string-from-file (filePath)
  "Return filePath's file content."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))
(defun app-launcher (command)
  "Launches an application in your PATH.
 Can show completions at point for COMMAND using helm or ido"
  (interactive (list (read-shell-command "$ ")))
  (start-process-shell-command command nil command))

(use-package helm
  :config 
  (helm-autoresize-mode t)
  (setq helm-autoresize-max-height 30)
  (setq helm-display-header-line nil)
  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
  (helm-mode t))

(use-package evil
  :config 
  (evil-mode t)
  (setq evil-cross-lines t) ; For being able to use f and t across multiple lines of code making it 10x more 
  )

(general-define-key 
 :states '(normal insert motion)
 (kbd "S-<escape>") 'evil-execute-in-movement-state)
;; @TODO(renzix): Make a movement state which toggles all buffers
;;(kbd "~") 'evil-movement-state) @KEYBIND(renzix): Maybe make this better keybind

(evil-define-state movement
  "Movement state. Moves and opens windows"
  :tag " <MV> "
  :message "-- MOVEMENT --"
  :input-method t
  :entry-hook (evil-movement-start-hook)
  :exit-hook (evil-movement-exit-hook)

  (general-define-key
   :states 'movement
   (kbd "ESC") 'evil-normal-state
   (kbd "q") 'delete-window
   (kbd "Q") 'kill-emacs
   (kbd "h") 'evil-window-left
   (kbd "j") 'evil-window-down
   (kbd "k") 'evil-window-up
   (kbd "l") 'evil-window-right
   (kbd "b") 'helm-buffers-list
   (kbd "d") 'delete-file-and-buffer
   (kbd "e") 'helm-find-files
   (kbd "H") 'evil-window-move-far-left
   (kbd "L") 'evil-window-move-far-right
   (kbd "J") 'evil-window-move-very-bottom
   (kbd "K") 'evil-window-move-very-top
   (kbd "v") 'evil-window-vsplit
   (kbd "s") 'evil-window-split
   (kbd "-") 'evil-window-decrease-height
   (kbd "=") 'evil-window-increase-height
   (kbd "_") 'evil-window-decrease-width
   (kbd "+") 'evil-window-increase-width
   (kbd "'") 'eshell
   (kbd "\"") 'term
   (kbd "g") 'magit-status
   (kbd "p") 'projectile-command-map))

(defun evil-movement-start-hook ()
  (message "Entering movement mode"))


(defun evil-movement-exit-hook ()
  (message "Leaving movement mode"))

(defvar evil-execute-in-movement-state-buffer nil)

(defvar evil-movement-last-command nil)

(defun evil-movement-fix-last-command ()
  "Change `last-command' to be the command before `evil-execute-in-movement-state'."
  (setq last-command evil-movement-last-command))

(defun evil-stop-execute-in-movement-state ()
  "Switch back to previous evil state."
  (unless (or (eq this-command #'evil-execute-in-movement-state)
	      (eq this-command #'universal-argument)
	      (eq this-command #'universal-argument-minus)
	      (eq this-command #'universal-argument-more)
	      (eq this-command #'universal-argument-other-key)
	      (eq this-command #'digit-argument)
	      (eq this-command #'negative-argument)
	      (minibufferp))
    (remove-hook 'pre-command-hook 'evil-movement-fix-last-command)
    (remove-hook 'post-command-hook 'evil-stop-execute-in-movement-state)
    (when (buffer-live-p evil-execute-in-movement-state-buffer)
      (with-current-buffer evil-execute-in-movement-state-buffer
	(if (and (eq evil-previous-state 'visual)
		 (not (use-region-p)))
	    (progn
	      (evil-change-to-previous-state)
	      (evil-exit-visual-state))
	  (evil-change-to-previous-state))))
    (setq evil-execute-in-movement-state-buffer nil)))

(defun evil-execute-in-movement-state ()
  "Execute the next command in movement state."
  (interactive)
  (add-hook 'pre-command-hook #'evil-movement-fix-last-command t)
  (add-hook 'post-command-hook #'evil-stop-execute-in-movement-state t)
  (setq evil-execute-in-movement-state-buffer (current-buffer))
  (setq evil-movement-last-command last-command)
  (cond
   ((evil-visual-state-p)
    (let ((mrk (mark))
	  (pnt (point)))
      (evil-movement-state)
      (set-mark mrk)
      (goto-char pnt)))
   (t
    (evil-movement-state)))
  (evil-echo "Switched to Movement state for the next command ..."))

(general-define-key
 :states '(movement)
 :prefix "c"
 (kbd "c") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file (concat HOME "/.emacs.d/settings.org") t) ))
 (kbd "i") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file (concat HOME "/.emacs.d/init.el"))))
 (kbd "b") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file (concat HOME "/.config/bspwm/bspwmrc"))))
 (kbd "s") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file (concat HOME "/.config/sxhkd/sxhkdrc_bspwm"))))
 (kbd "h") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file (concat HOME "/.config/herbstluftwm/autostart"))))
 (kbd "m") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file "/sudo::/etc/portage/make.conf")))
 (kbd "n") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file "/sudo::/etc/nixos/configuration.nix")))
 (kbd "d") (lambda() (interactive) (let ((default-directory (concat HOME "/Dotfiles"))(magit-pull-from-upstream "master")) (find-file "/sudo::/etc/portage/savedconfig/x11-wm/dwm-6.1-r1.h"))))

;;     (general-define-key
;;      :states 'insert
;;      (kbd "C-n") 'previous-buffer)

(use-package which-key)
(which-key-mode)
(evil-define-key '(normal movement) global-map (kbd ";") 'helm-M-x)
(evil-define-key '(normal movement) global-map (kbd "SPC") 'app-launcher)
(evil-define-key '(normal) global-map (kbd "gc") 'comment-line)

(use-package helm-projectile)
(projectile-mode t)

(use-package evil-magit)

(use-package rust-mode)
(use-package cargo)
(use-package racer)
(use-package clippy)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'rust-mode-hook 'cargo-minor-mode)
(setq rust-format-on-save t)

(general-define-key
 :states '(normal)
 :keymaps 'rust-mode-map
 :prefix "," 
 (kbd "f") 'cargo-process-fmt
 (kbd "r") 'cargo-process-run
 (kbd "d") 'cargo-process-doc
 (kbd "o") 'cargo-process-doc-open
 (kbd "t") 'cargo-process-test
 (kbd "c") 'cargo-process-check
 (kbd "R") 'cargo-process-clean
 (kbd "n") 'cargo-process-new
 (kbd "u") 'cargo-process-update
 (kbd "b") 'cargo-process-build)

(use-package anaconda-mode
  :config 
  (add-hook 'python-mode-hook 'anaconda-mode)
  (add-hook 'python-mode-hook 'anaconda-eldoc-mode))
(general-define-key
 :states '(normal)
 :keymaps 'python-mode-map
 :prefix "," 
 (kbd "d") 'python-eldoc-get-doc
 (kbd "l") 'python-check)

(use-package company-c-headers)
(use-package irony
  :ensure t
  :defer t
  :init
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  :config
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))
;;(general-define-key ;;C/CPP keys
;; :states '(normal motion)
;; :keymaps 'irony-mode-map
;; :prefix ",")

(setq inferior-lisp-program "/usr/bin/sbcl")
(use-package slime)
(use-package slime-company)
(require 'slime-autoloads)
(slime-setup '(slime-fancy))

(use-package company
  :ensure t
  :defer t
  :init (add-hook 'after-init-hook 'global-company-mode)
  :config
  (use-package company-irony :ensure t :defer t)
  (use-package company-racer)
  (use-package company-anaconda)
  (setq company-idle-delay        2
	company-minimum-prefix-length   2
	company-show-numbers            t
	company-tooltip-limit           20
	company-dabbrev-downcase        nil
	company-backends                '((company-irony company-gtags company-anaconda company-racer company-elisp company-nixos-options)))
  :bind ("C-<tab>" . company-indent-or-complete-common))
(setq tab-always-indent 'complete)

(use-package autopair
  :config (autopair-global-mode t))
(use-package comment-tags
  :config
  (setq comment-tags-keyword-faces
	`(("TODO" . ,(list :weight 'bold :foreground "#28ABE3"))
	  ("FIXME" . ,(list :weight 'bold :foreground "#DB3340"))
	  ("BUG" . ,(list :weight 'bold :foreground "#DB3340"))
	  ("HACK" . ,(list :weight 'bold :foreground "#E8B71A"))
	  ("KLUDGE" . ,(list :weight 'bold :foreground "#E8B71A"))
	  ("XXX" . ,(list :weight 'bold :foreground "#F7EAC8"))
	  ("INFO" . ,(list :weight 'bold :foreground "#F7EAC8"))
	  ("DONE" . ,(list :weight 'bold :foreground "#1FDA9A"))))
  (setq comment-tags-comment-start-only t
	comment-tags-require-colon t
	comment-tags-case-sensitive t
	comment-tags-show-faces t
	comment-tags-lighter nil)
  (add-hook 'prog-mode-hook 'comment-tags-mode))

(setq default-major-mode 'text-mode)
(add-hook 'text-mode-hook 'text-mode-hook-identify)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

(use-package erc-twitch)
(use-package erc-image)
(add-to-list 'erc-modules 'image)
(use-package erc-tweet)
(add-to-list 'erc-modules 'tweet)
(erc-twitch-enable)
(erc-update-modules)
(setq erc-hide-list '("JOIN" "PART" "QUIT" "ROOT"))
(setq erc-lurker-hide-list '("JOIN" "PART" "QUIT"))
(setq erc-kill-buffer-on-part t)
(setq erc-kill-queries-on-quit t)
(setq erc-kill-server-buffer-on-quit t)

(defmacro erc-connect (command server port nick ssl pass)
  "Create interactive command `command', for connecting to an IRC server. The
		command uses interactive mode if passed an argument."
  (fset command
	`(lambda (arg)
	   (interactive "p")
	   (if (not (= 1 arg))
	       (call-interactively 'erc)
	     (let ((erc-connect-function ',(if ssl 'erc-open-ssl-stream 'open-network-stream)))
	       (erc :server ,server :port ,port :nick ,nick :password ,pass))))))
(erc-connect bitlbee-erc "127.0.0.1" 6667 "Renzix" nil "Akeyla10!") ;;@TODO(renzix): Put this on my server i guess??
(erc-connect twitch-erc "irc.chat.twitch.tv" 6667 "TheRenzix" nil (get-string-from-file (concat HOME "/.config/twitch-oauth")))
(general-define-key
 :states '(normal)
 :prefix "\\"
 (kbd "d") 'bitlbee-erc
 (kbd "t") 'twitch-erc
 (kbd "b") 'erc-switch-to-buffer
 (kbd "q") 'erc-quit-server
 (kbd "p") 'erc-part-from-channel
 (kbd "j") 'erc-join-channel
 (kbd "\\") 'erc-track-switch-buffer)
;;(general-define-key @TODO(renzix): Make this a search function for irc?
;; :states '(normal)
;; :prefix ","
;; (kbd "p") 'erc-part-from-channel
;; (kbd "\\") 'erc-track-switch-buffer)

;; For Rich presence
(use-package elcord)
;;(use-package emojify)
;;(add-hook 'after-init-hook #'global-emojify-mode)
(elcord-mode)

(defun youtube-dl-url (&optional url)
  "Run 'youtube-dl' over the URL.
If URL is nil, use URL at point."
  (interactive)
  (setq url (or url (thing-at-point-url-at-point)))
  (let ((eshell-buffer-name "*youtube-dl*")
	(directory (expand-file-name (or (file-directory-p "~/Media/Videos")
					 (file-directory-p "~/Downloads")
					 "."))))
    (eshell)
    (when (eshell-interactive-process)
      (eshell t))
    (eshell-interrupt-process)
    (insert (format "cd '%s' && youtube-dl " directory) url)
    (eshell-send-input)))

;;(use-package matrix-client ;; @TODO(renzix): Hopfully this gets fixed???
;;  :quelpa (matrix-client :fetcher github :repo "jgkamat/matrix-client-el"))

(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((org . t)
   (latex . t)
   (emacs-lisp . t)
   (sql . t)
   (python . t)))
(general-define-key
 :states '(normal movement)
 :keymaps 'org-mode-map
 :prefix ","
 (kbd ",") 'org-export-dispatch
 (kbd "t") 'org-time-stamp
 (kbd "s") 'org-babel-execute-src-block
 (kbd "e") 'org-babel-execute-buffer
 (kbd "'") 'org-edit-special)
(use-package ox-pandoc)

(use-package kdeconnect)

(use-package nix-mode)
(use-package helm-nixos-options)
(use-package company-nixos-options)
(general-define-key
 :states '(normal)
 :keymaps 'nix-mode-map
 :prefix "," 
 (kbd "s") 'helm-nixos-options)
;; (general-define-key
;;       :states '(normal)
;;       :keymaps 'nix-mode-map
;;       (kbd "S-TAB") 'company-indent-or-complete-common)

(add-to-list 'load-path (concat HOME "/Projects/emacs-libvterm"))
(let (vterm-install)
  (require 'vterm))
(setq vterm-shell "ion")

(use-package system-packages)
(use-package helm-system-packages
  :after (sysetem-packages))

(setq backup-directory-alist `(("." . "~/.saves"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

(setq inhibit-startup-screen t)
(setq initial-buffer-choice 'eshell)
;; Theme stuff for emacs --daemon idk why it works  @TODO(renzix): Make this work
(defvar my:theme 'apropospriate-dark)
(defvar my:theme-window-loaded nil)
(defvar my:theme-terminal-loaded nil)

(if (daemonp)
    (add-hook 'after-make-frame-functions(lambda (frame)
					   (select-frame frame)
					   (if (window-system frame)
					       (unless my:theme-window-loaded
						 (if my:theme-terminal-loaded
						     (enable-theme my:theme)
						   (load-theme my:theme t))
						 (setq my:theme-window-loaded t))
					     (unless my:theme-terminal-loaded
					       (if my:theme-window-loaded
						   (enable-theme my:theme)
						 (load-theme my:theme t))
					       (setq my:theme-terminal-loaded t)))))

  (progn
    (load-theme my:theme t)
    (if (display-graphic-p)
	(setq my:theme-window-loaded t)
      (setq my:theme-terminal-loaded t))))
(setq org-src-tab-acts-natively t)
;; Need to wait till after everything for to start uwu
