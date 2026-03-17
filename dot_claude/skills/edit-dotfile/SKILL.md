---
name: edit-dotfile
description: "dotfileの編集。~/配下のdotfileを編集する前にchezmoi管理チェックを行う。"
---

## 最初のアクション

dotfile編集要求を受けたら、**必ず最初に** chezmoi管理下かどうかを確認する:

```bash
chezmoi managed | grep <filename>
```

- **管理下の場合**: `~/.local/share/chezmoi/dot_*` のソースファイルを編集する。ホームディレクトリのファイルを直接変更してはいけない
- **管理外の場合**: ホームディレクトリのファイルを直接編集してよい

## パスマッピング

chezmoiのソースパスは `chezmoi source-path <target>` で取得できる。変換ルール:
- `~/.<name>` → `~/.local/share/chezmoi/dot_<name>`
- `~/.config/<path>` → `~/.local/share/chezmoi/dot_config/<path>`

よく使う例:
- `~/.zshrc` → `dot_zshrc`
- `~/.config/zsh/aliases/*.zsh` → `dot_config/zsh/aliases/*.zsh`
- `~/.config/zsh/functions/*.zsh` → `dot_config/zsh/functions/*.zsh`
- `~/.claude/**` → `dot_claude/**`

## Zsh: エイリアス vs 関数

- **引数なし** → `dot_config/zsh/aliases/` 内の適切なファイルに追加
- **引数あり** → `dot_config/zsh/functions/` に新規ファイル作成 + `dot_zshrc` にsource行追加

フォーマット: `name() { ... }` （`function`キーワード省略）

## 削除する場合

chezmoi管理下のファイルを削除するときは `chezmoi forget <target>` を実行してからファイルを削除する。
直接 `rm` だけではchezmoiが次回applyで復元してしまう。

## 最後に

編集後、必ず `chezmoi apply` を実行してホームディレクトリに反映する。
