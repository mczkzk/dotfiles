;; 現在行を目立たせる
(global-hl-line-mode)
;; 対応するカッコを強調表示
(show-paren-mode t)
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(setq show-paren-style 'expression)

;; フェイスを変更する
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "gray")
