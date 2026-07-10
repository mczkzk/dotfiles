---
name: e2e-verify
description: "Playwright MCP で PR の UI 変更を視覚的に検証する。E2Eテスト、動作確認、UI確認、スクリーンショット撮影に使う。"
argument-hint: "[env] [pr | auto | verification steps]"
---

# E2E Verification

Playwright MCP を使って UI 変更を視覚的に検証する。

## Setup

1. **設定ファイル読み込み** — `.claude/e2e-verify/config.yaml` を Read ツールで読む。なければユーザーに URL を聞く。テンプレートは `${CLAUDE_SKILL_DIR}/references/config-template.yaml` を参照。
2. **Playwright MCP** — `ToolSearch` で `mcp__playwright__browser_navigate` を取得。なければ中断。
3. **Component Gotchas** — 設定の `component-gotchas` パスがあれば Read ツールで読み込む。
4. **ターゲット環境決定** — `$ARGUMENTS` のトークンが `environments` のキー（例 `dev`）と一致すればその環境を選び、**そのトークンを `$ARGUMENTS` から除去**する（残りが検証手順の指定）。一致が無ければ top-level `url`（既定=ローカル）。決まった URL にアクセスできること。
5. **認証情報（ログイン必須アプリのみ）** — 使う account は、選んだ環境の `account`、無ければ top-level `account`。`.claude/config.yaml` の `accounts.<key>`（email/password）を Read で取得。`accounts` が無ければスキップ。

## Verification Steps の取得

`$ARGUMENTS`（環境トークン除去後）の内容に応じて:

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

1. **Navigate** — Setup 4 で決めたターゲット URL にアクセス。
2. **Login** — ログインフォームが出たら email/password を入力して送信、`browser_wait_for` で遷移を待つ。出なければスキップ。
3. **Follow steps** — スナップショットで要素を特定 → クリック/入力 → 次のステップ。
4. **Screenshot at key points** — 検証ポイントで `browser_take_screenshot` を撮影。差分の核心（変わった箇所・状態）は素撮りで終わらせず、**注釈版（枠 + 凡例）も撮る**（下記「Annotated screenshots」）。
5. **Rapid capture** — クリック直後の状態（スピナー等）を撮りたい場合は `browser_run_code` で操作とスクリーンショットを一括実行。
6. **Wait appropriately** — ページ遷移やデータロード後は `browser_wait_for` で 2-5 秒待つ。

### Screenshot output

スクリーンショットはタスクスコープに保存する:

```
filename: ".claude/tasks/{ISSUE-KEY}/screenshots/<step-N>-<description>.png"
```

タスクが特定できない場合 (PR ベース等) は `.playwright-mcp/` にフォールバック。**リポジトリルートにファイルを散らかさない。**

撮影と同じディレクトリに **`README.md`** を必ず置く。スクショだけだと後から「何の画面か」が分からなくなるので、ファイル別の観察事項 + 検証結果サマリ + 未確認/制約 を書く。

### Annotated screenshots（枠 + 凡例）— 差分が一目でわかる証拠にする

素の全画面スクショは「どこがポイントか」が伝わらない。**注目箇所を色枠で囲み、空きスペースに凡例を置いた注釈版**を撮る。ボタン・入力・トグル・バッジ・グラフ・表など UI の種類を問わず、変化した部分・確認した部分に使える。これを PR に貼れば「どこがどう変わるか」が自明になる。

やり方（`browser_evaluate` で **ライブ画面に overlay div を注入 → そのまま撮影**。ピクセル完全一致で、外部画像ライブラリ不要）:

1. 対象要素を `getBoundingClientRect()` で測り、`position:fixed` の枠 div（`border:3px solid <color>` / `pointerEvents:none` / 大きい `zIndex`）を `document.body` に足す。**枠は中身を隠さないよう対象の外周だけ**。
2. 説明ラベルは**対象に被せない**。余白（空きパネル等）に凡例ボックス（色チップ + 一言）を置く。対象そのものを隠すのは NG。
3. `browser_take_screenshot` で撮る。後片付けに `document.querySelectorAll('.__hl').forEach(e=>e.remove())`。
4. 色の使い分け例: 🔴 変化した主役 / 🟠 消えた・無効化された箇所 / 🟢 対照（不変・別軸）の箇所。
5. **before/after は同一フレーミング**で撮る（対象が画面外なら `scrollIntoView({block:'center'})` してから枠を描く）。1箇所だけ変わる並びにすると差分が刺さる。

再利用スニペット:

```js
() => {
  const box=(el,color)=>{const r=el.getBoundingClientRect();const d=document.createElement('div');d.className='__hl';
    Object.assign(d.style,{position:'fixed',left:(r.x+2)+'px',top:(r.y+2)+'px',width:(r.width-6)+'px',height:(r.height-6)+'px',
      border:'3px solid '+color,borderRadius:'4px',boxSizing:'border-box',zIndex:2147483647,pointerEvents:'none'});
    document.body.appendChild(d);};
  const legend=(x,y,html)=>{const l=document.createElement('div');l.className='__hl';
    Object.assign(l.style,{position:'fixed',left:x+'px',top:y+'px',width:'345px',background:'rgba(0,0,0,0.82)',
      border:'1px solid #555',borderRadius:'6px',padding:'12px 14px',zIndex:2147483647,pointerEvents:'none',
      font:'13px sans-serif',color:'#fff',lineHeight:'1.5'});l.innerHTML=html;document.body.appendChild(l);};
  // 例: box(targetEl,'#ff2d2d'); legend(15,470,'<b>...</b>');
}
```

対象要素の特定は snapshot の `ref` でも、`browser_evaluate` 内で探してもよい。Shadow DOM を貫通するには
`function* walk(root){for(const el of root.querySelectorAll('*')){yield el; if(el.shadowRoot) yield* walk(el.shadowRoot);}}`
を使う（詳細は component-gotchas 参照）。

凡例に値や状態を書くときは、見た目の読み取りでなく `browser_evaluate` で DOM やコンポーネントの内部プロパティから実値を取る。**PR に載せる値は撮影時に抽出した実値**を使う。

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
