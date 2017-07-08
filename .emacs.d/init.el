;; set load paths
(setq load-path (append '(
    "~/.emacs.d/conf"
    "~/.emacs.d/lib"
    "~/.emacs.d/elisp"
    "~/.emacs.d/public_repos"
) load-path))

;; definitions
(load "init-defaults")
(load "init-design")

(load "init-keybinds")
