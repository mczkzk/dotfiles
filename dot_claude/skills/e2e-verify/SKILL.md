---
name: e2e-verify
description: "Playwright MCP で PR の UI 変更を視覚的に検証する。E2Eテスト、動作確認、UI確認、スクリーンショット撮影に使う。"
argument-hint: "[verification steps or 'auto' to read from PR testing plan]"
---

# E2E Verification

Playwright MCP を使って UI 変更を視覚的に検証する。

## Setup

1. **設定ファイル読み込み** — `.claude/e2e-verify/config.yaml` を Read ツールで読む。なければユーザーに URL を聞く。テンプレートは `${CLAUDE_SKILL_DIR}/references/config-template.yaml` を参照。
2. **Playwright MCP** — `ToolSearch` で `mcp__playwright__browser_navigate` を取得。なければ中断。
3. **Component Gotchas** — 設定の `component-gotchas` パスがあれば Read ツールで読み込む。
4. **App running** — 設定の `url` にアクセスできること。

## Verification Steps の取得

`$ARGUMENTS` の内容に応じて:

- **`pr`** → PR description の Test Plan を使う (`gh pr view --json body -q .body`)
- **具体的な UI 操作手順が書かれている** → そのまま実行
- **`auto` または空** → 以下の優先順位で取得:
  1. `.claude/tasks/{ISSUE-KEY}/review.md` の Verification Steps
  2. PR description の Test Plan (`gh pr view --json body -q .body`)
  3. 見つからなければユーザーに聞く

### UI ステップのフィルタリング

取得した手順から **ブラウザで実行可能な UI 操作ステップだけ** を抽出する。以下は SKIP:
- ユニットテスト実行 (`pnpm test` 等)
- コードレビュー観点 (命名、型、パターン)
- DB / API / サーバー側の確認
- 「コードを読んで確認」系


## Navigation

### Primary: Snapshot-based

`browser_snapshot` でページ構造を読み、要素を特定して操作する。
設定に `prefer-selector` があれば、その属性を持つ要素を優先的に使う。

### Assist: Navigation recipes

設定の `navigation-recipes` パスにレシピYAMLがある場合、画面への到達手順の参考にする。
レシピはあくまで参考。実際の操作はスナップショットの `ref` を使う。

## Execution

1. **Navigate** — 設定の `url` にアクセス。
2. **Follow steps** — スナップショットで要素を特定 → クリック/入力 → 次のステップ。
3. **Screenshot at key points** — 検証ポイントで `browser_take_screenshot` を撮影。
4. **Rapid capture** — クリック直後の状態（スピナー等）を撮りたい場合は `browser_run_code` で操作とスクリーンショットを一括実行。
5. **Wait appropriately** — ページ遷移やデータロード後は `browser_wait_for` で 2-5 秒待つ。

### Screenshot output

スクリーンショットは `.playwright-mcp/` ディレクトリに保存する。`filename` パラメータに必ずディレクトリを含める:

```
filename: ".playwright-mcp/e2e-step1-description.png"
```

リポジトリルートにファイルを散らかさないこと。

### On failure

- `ref` が stale → スナップショット再取得
- 要素が intercept → `browser_evaluate` にフォールバック
- 手順が不明確で進めない → 現在画面のスクリーンショットを撮り、ユーザーに報告

## Post-verification

**Component Gotchas の更新** — 操作中に新しい gotcha を発見した場合（要素クリックの intercept、disabled 判定の特殊な方法、Shadow DOM の問題など）、`component-gotchas` ファイルに追記する。結果レポートを出す前にこのステップを必ず実行する。

## Output

```markdown
## E2E Verification Result

### Step 1: [手順の説明]
- **Status**: OK / NG / SKIP
- **Screenshot**: [path]
- **Note**: [観察事項]

### Summary
- Total: N steps
- OK: N / NG: N / SKIP: N
```
