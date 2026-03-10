---
name: jira-fetch
description: JIRAチケット情報を取得して .claude/plans/{ISSUE_KEY}/ に保存
disable-model-invocation: true
allowed-tools:
  - Bash(${CLAUDE_SKILL_DIR}/jira-fetch.sh:*)
---

JIRAチケット情報を取得する。

## 引数の正規化

$ARGUMENTS をスペース区切りに正規化。

番号のみの場合、プロジェクトルートの `.claude/jira-prefix` からプレフィックスを読んで補完する:
- `830,831,832` -> `{PREFIX}-830 {PREFIX}-831 {PREFIX}-832`
- `XXX-830,831,832` -> `XXX-830 XXX-831 XXX-832`（先頭のプレフィックスを後続にも適用）
- `XXX-830,XXX-831` -> `XXX-830 XXX-831`
- フルキー指定時（`XXX-830`形式）はプレフィックスファイル不要

`.claude/jira-prefix` が無く、番号のみが渡された場合はエラーとし案内する:
「プロジェクトルートに `.claude/jira-prefix` を作成してください（例: `echo XXX > .claude/jira-prefix`）」

## 実行

```bash
${CLAUDE_SKILL_DIR}/jira-fetch.sh <正規化した引数>
```

## 実行後

取得した `.claude/plans/{ISSUE_KEY}/jira.md` を読んで概要を報告。
