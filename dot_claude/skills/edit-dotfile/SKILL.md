---
name: edit-dotfile
description: dotfileの編集・修正を依頼されたとき、ホームディレクトリのファイルではなくchezmoiで管理されているファイルを優先的に確認・編集する。~/.bashrc、~/.zshrc、~/.vimrcなどのdotfile関連の変更要求時に使用。
---

# Edit Dotfile (Chezmoi管理優先)

## Instructions

dotfile編集要求を受けたとき、以下の手順に従ってください：

1. **chezmoi管理ファイルを検索**
   - `~/.local/share/chezmoi` 内をGlob/Grepで検索
   - 命名規則: `~/.bashrc` → `dot_bashrc`, `~/.config/nvim/init.vim` → `dot_config/nvim/init.vim`, `~/.ssh/config` → `private_dot_ssh/config`

2. **ファイルが見つかった場合**
   - chezmoi管理下のファイル（例: `~/.local/share/chezmoi/dot_bashrc`）を編集
   - 編集後、ユーザーに `chezmoi apply` コマンドの実行が必要なことを通知

3. **ファイルが見つからない場合**
   - 通常のホームディレクトリのファイルを編集
   - または、chezmoi管理下に追加するか確認

## Examples

ユーザー: `.bashrc` にエイリアスを追加して

対応:
1. Globで `~/.local/share/chezmoi/**/*bashrc*` を検索
2. `~/.local/share/chezmoi/dot_bashrc` を編集
3. 通知: 「`~/.local/share/chezmoi/dot_bashrc` を編集しました。`chezmoi apply` で反映してください」
