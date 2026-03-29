---
name: chezmoi-edit
description: "~/配下のchezmoi管理ファイルの編集。~/.claude/配下のスキル・設定・スクリプト、~/.config/配下の設定ファイル、~/.zshrcなど、chezmoi管理下のファイルを新規作成・編集・削除する時に使う。「スキル作成」「設定変更」「エイリアス追加」「関数追加」などで発動。"
---

## 最初のアクション

~/配下のファイルを編集・新規作成する要求を受けたら、**必ず最初に** chezmoi管理下かどうかを確認する:

```bash
chezmoi managed | grep <filename>
```

- **管理下の場合**: `~/.local/share/chezmoi/` のソースファイルを編集する。ホームディレクトリのファイルを直接変更してはいけない
- **管理外の場合**: ホームディレクトリのファイルを直接編集してよい
- **新規作成で親ディレクトリが管理下の場合**: ソース側に作成する（例: `~/.claude/skills/` が管理下なら、新スキルも `dot_claude/skills/` に作る）

## パスマッピング

chezmoiのソースパスは `chezmoi source-path <target>` で取得できる。変換ルール:
- `~/.<name>` → `~/.local/share/chezmoi/dot_<name>`
- `~/.config/<path>` → `~/.local/share/chezmoi/dot_config/<path>`

よく使う例:
- `~/.zshrc` → `dot_zshrc`
- `~/.config/zsh/*.zsh` → `dot_config/zsh/*.zsh`
- `~/.claude/**` → `dot_claude/**`

## Zsh: エイリアス・関数の追加

`dot_config/zsh/` にトピック別のファイルがある（chezmoi.zsh, git.zsh, general.zsh など）。
関連するトピックのファイルに追加する。新トピックなら新ファイルを作成。
.zshrc は `~/.config/zsh/*.zsh` を glob で読み込むので source行の追加は不要。

フォーマット: `name() { ... }` （`function`キーワード省略）

## 削除する場合

chezmoi管理下のファイルを削除するときは `chezmoi forget <target>` を実行してからファイルを削除する。
直接 `rm` だけではchezmoiが次回applyで復元してしまう。

## 最後に

編集後、必ず `chezmoi apply` を実行してホームディレクトリに反映する。
