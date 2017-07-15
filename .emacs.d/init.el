(require 'cask)
(cask-initialize)
(package-initialize)

(setq load-path (append '(
    "~/.emacs.d/conf"
    "~/.emacs.d/lib"
    "~/.emacs.d/progmodes"
    "~/.emacs.d/elisp"
    "~/.emacs.d/public_repos"
    "~/.emacs.d/yasnippets"
) load-path))

;; definitions
(load "init-defaults")
(load "init-layout")

(load "init-highlight")
(load "init-frame")
(load "init-screen")
(load "init-tree")

(load "init-indent")
(load "init-search")
(load "init-auto-complete")
(load "init-snippets")

(load "init-backup")
(load "init-history")

(load "init-keybinds")

;; progmodes
(load "init-js2-mode")
