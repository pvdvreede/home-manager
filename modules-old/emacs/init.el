(blink-cursor-mode -1)

(setq initial-scratch-message "")
(setq inhibit-startup-message t)

(setq visible-bell nil)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(set-frame-font "Source Code Pro 16")

;; (setq-default mode-line-format nil)

;; (set-fringe-mode
  ;; (/ (- (frame-pixel-width)
  ;;       (* 120 (frame-char-width)))

;; (set-face-attribute
;;   'fringe nil
;;   :foreground (face-foreground 'default)
;;   :background (face-background 'default))

(setq pop-up-windows nil)
(setq x-select-enable-clipboard t)

;; remove all ctrl keybinds
;; (global-unset-key (kbd "C"))

(keymap-global-set "C-k" 'kill-whole-line)
(keymap-global-set "C-S-d" 'duplicate-line)
(keymap-global-set "C-p" 'find-file)
(keymap-global-set "C-S-p" 'M-x)

(ivy-mode 1)
