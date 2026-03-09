---
name: codex-review
description: Pass context to OpenAI Codex CLI for code review, then process the results back in Claude Code
argument-hint: "[file path | diff description | feature name] (empty = use conversation context)"
disable-model-invocation: true
allowed-tools: Bash(codex *), Bash(cat *), Bash(git *), Read, Write, Edit, Grep, Glob
---

# Codex Review — Claude Code ↔ Codex bridge

## CRITICAL RULE

**あなた自身がレビューしてはいけない。必ず Codex CLI を実行してレビューを委譲すること。**

## Step 1: $ARGUMENTS をそのまま Codex に渡す

`$ARGUMENTS` の内容全体（ファイルパス、指示文、追加コンテキスト含む）をそのまま codex exec に渡す。
加工・整形・フォーマット変換は不要。ファイルの事前読み込みも不要。
Codex 自身がファイルを読んでレビューする。

## Step 2: Codex 実行（スキップ厳禁）

**即座に** Bash ツールで実行する。事前のファイル読み込みや情報収集は一切しない。

```bash
codex exec --full-auto --ephemeral -o /tmp/codex-review-output.txt "$ARGUMENTS"
```

Bash の timeout は 600000 を指定。引数なしの場合は会話の文脈から指示文を組み立てて渡す。

Codex が失敗した場合はエラー内容をユーザーに報告して終了。

## Step 3: 結果の読み取りと処理

1. `/tmp/codex-review-output.txt` を Read で読み取る
2. Codex の指摘を解析し、妥当性を判断する
3. 妥当な指摘は修正を提案または実行する

## Step 4: レポート

**Codex の指摘:** severity 付きで列挙
**Claude Code の判断:** 同意/不同意と理由
**対応済み:** 修正サマリー
**残タスク:** ユーザー判断が必要な項目
