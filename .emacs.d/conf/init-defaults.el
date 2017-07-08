;; おまじない
(require 'cl)
;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)

;; 日本語の設定（UTF-8）
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)

;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))


;; 現在行を目立たせる
(global-hl-line-mode)
;; 対応するカッコを強調表示
(show-paren-mode t)
;; 時間を表示
(display-time)


(setq-default indent-tabs-mode nil)
(setq-default transient-mark-mode t)


;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" , (expand-file-name "~/.emacs.d/backups/") t)))


;; バッファの同一ファイル名を区別する
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)



;; バックアップファイルを作らないようにする
(setq make-backup-files nil)
;;; 終了時にオートセーブファイルを消す
(setq delete-auto-save-files t)
