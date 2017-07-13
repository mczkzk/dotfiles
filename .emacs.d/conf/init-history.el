(when (require 'undohist nil t)
  (undohist-initialize))

(when (require 'undo-tree nil t)
  (global-undo-tree-mode))
