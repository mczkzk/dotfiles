---
name: edit-dotfile
description: dotfileの編集・修正を依頼されたとき、ホームディレクトリのファイルではなくchezmoiで管理されているファイルを優先的に確認・編集する。~/.bashrc、~/.zshrc、~/.vimrcなどのdotfile関連の変更要求時に使用。
---

# CRITICAL: 必ずchezmoi配下のファイルを変更する

**ホームディレクトリ（`~/.zshrc`など）を直接読んだり変更してはいけない。**

## 最初のアクション

dotfile編集要求を受けたら、**必ず最初に** `/Users/mczkzk/.local/share/chezmoi/` 配下のファイルを検索・確認する。

## パスマッピング

- `~/.zshrc` → `/Users/mczkzk/.local/share/chezmoi/dot_zshrc`
- `~/.config/zsh/aliases/*.zsh` → `/Users/mczkzk/.local/share/chezmoi/dot_config/zsh/aliases/*.zsh`
- `~/.config/zsh/functions/*.zsh` → `/Users/mczkzk/.local/share/chezmoi/dot_config/zsh/functions/*.zsh`

## Zsh: エイリアス vs 関数

- **引数なし** → `dot_config/zsh/aliases/` 内の適切なファイルに追加
- **引数あり** → `dot_config/zsh/functions/` に新規ファイル作成 + `dot_zshrc` にsource行追加

フォーマット: `name() { ... }` （`function`キーワード省略）

## 最後に

編集後、必ず `chezmoi apply` をユーザーに案内する。
