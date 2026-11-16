# Chrome DevTools MCP fallback

Playwright MCP が無いセッションでは Chrome DevTools MCP (`mcp__chrome-devtools__*`) で同じ手順を実行する。
SKILL.md の `browser_*` は以下に読み替える。全ツールに `pageId` が必須（`new_page` / `list_pages` の結果に出る）。

| SKILL.md の記述 | Chrome DevTools MCP |
|---|---|
| `browser_navigate` | 初回は `new_page`、以降は `navigate_page` (`type: "url"`) |
| `browser_snapshot` / `ref` | `take_snapshot` / `uid` |
| クリック / 入力 | `click` / `fill` / `type_text`（`uid` 指定） |
| `browser_wait_for` | `wait_for` |
| `browser_evaluate` / `browser_run_code` | `evaluate_script`（`function` に関数ソース、`args` に uid を渡せる） |
| `browser_take_screenshot` | `take_screenshot`（`filePath` は絶対パスでそのまま保存される） |
| `browser_console_messages` | `list_console_messages`（`types: ["error","warn"]` で絞れる） |
| ビューポートサイズ | `resize_page` |

## 切り取り

`page.screenshot({clip})` に相当する API は無い。`take_screenshot` に対象要素の `uid` を渡すと**その要素の矩形で切り取られる**（余白なし）。
余白を付けたい場合は、対象の rect + 28px のサイズで `role="img"` を付けた透明な `position:fixed` の div を `evaluate_script` で注入し、`take_snapshot` し直してその uid を撮り、撮影後に消す（この余白付きの手順は未検証。uid 指定での切り取り自体はツール仕様どおり）。

## 操作をまとめて実行する

`evaluate_script` は DOM 操作と状態の読み取りを 1 回の関数で行える。クリック → 値の取得 → 次のクリックを 1 関数にまとめると往復が減る。
返り値は JSON 化できるものに限る。`waitForStableDom` は既定で有効。

## 検証済み

2026-11-16: `new_page` / `navigate_page` / `resize_page` / `evaluate_script` / `take_screenshot`（全画面）/ `list_console_messages` を Tauri アプリのフロントエンド（モックサーバー経由）で使用して確認。
