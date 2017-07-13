;; スクリーンの最大化
;; (set-frame-parameter nil 'fullscreen 'maximized)
;; フルスクリーン
;; (set-frame-parameter nil 'fullscreen 'fullboth)

(require 'elscreen)
(elscreen-start)
(bind-key* "C-<tab>" 'elscreen-next)
