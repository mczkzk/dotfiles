---
name: new-repo
description: GitHubリポジトリの新規作成を対話的にサポートする。ローカルのプロジェクトをGitHubに上げたい時、新しいリポジトリを作りたい時、リポジトリ名を相談したい時に使う。「リポ作りたい」「GitHubに上げたい」「pushしたい」「新しいプロジェクト始めたい」「リポジトリ名どうしよう」などで発動。リポジトリ作成に少しでも関係しそうなら積極的に使うこと。
---

# new-repo

GitHubリポジトリの新規作成を対話的にサポートするスキル。

## フロー

### 1. 状況確認

カレントディレクトリの状態を確認する:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
git remote -v 2>/dev/null
```

### 2. フロー分岐を確認

ユーザーに聞く:

- **ローカル先行**: 「手元にあるプロジェクトをGitHubに上げたい」
- **GitHub先行**: 「まず空のリポジトリを作ってから始めたい」

既にgit repoがあってremoteが未設定ならローカル先行を提案する。git repoがなければどちらか聞く。

### 3. リポジトリ名の相談

ユーザーと一緒にリポジトリ名を決める。以下を参考に提案する:

- ディレクトリ名（ローカル先行の場合）
- プロジェクトの目的や内容
- 簡潔で分かりやすい命名（kebab-case推奨）

2-3個の候補を出して、ユーザーに選んでもらう。

### 4. 実行

#### ローカル先行の場合

```bash
# git initがまだなら
git init
git add -A
git commit -m "initial commit"

# GitHubにリポジトリ作成 & push
gh repo create <repo-name> --private --source=. --push
```

#### GitHub先行の場合

```bash
gh repo create <repo-name> --private --clone --add-readme
```

### デフォルト設定

- visibility: **private**（publicにしたい場合はユーザーが明示的に言った時だけ）
- GitHub先行の場合は `--add-readme` を付ける

### 注意

- `git add -A` する前に、`.gitignore` が適切に設定されているか確認する。なければプロジェクトの種類に応じて作成を提案する
- リポジトリ作成前に、同名のリポジトリが既に存在しないか `gh repo view <repo-name>` で確認する
