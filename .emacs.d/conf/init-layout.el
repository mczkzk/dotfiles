(load-theme 'manoj-dark' t)

;; for window system
;; 背景透過
(if window-system
    (progn
      (set-frame-parameter nil 'alpha 80)))

;; Ricty フォントの利用
(create-fontset-from-ascii-font "Ricty-14:weight=normal:slant=normal" nil "ricty")
(set-fontset-font "fontset-ricty"
                  'unicode
                  (font-spec :family "Ricty" :size 14)
                  nil
                  'append)
(add-to-list 'default-frame-alist '(font . "fontset-ricty"))

(setq face-font-rescale-alist '((".*Ricty.*" . 1.1)))
