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
- ユニットテスト実行 (テストランナーの起動)
- コードレビュー観点 (命名、型、パターン)
- 「コードを読んで確認」系
- 純粋にサーバー / DB / API 内部だけを確認するステップ (UI に現れない処理)

**SKIP の範囲は「そもそもブラウザ操作で表現できないステップ」に限る。**
UI で観測できる挙動を、前提条件(フラグ・特定データ・失敗状態など)が未整備という理由だけで
SKIP してはいけない。その場合は次節の手順で前提条件を能動的にセットアップしてから実行する。
なお DB / API は、**UI 操作の前提づくりや結果の裏取り(補助)** としては積極的に使ってよい。
対象外なのはあくまで「UI を介さない単独の確認ステップ」。

## 前提条件の能動的セットアップ(SKIP する前に必ず検討)

検証対象の挙動が、初期状態では踏めない経路にある場合が多い(隠れ機能、特定の初期データ、
エラー時の分岐など)。「環境がそうなっていない」を理由に安易に SKIP せず、**まず自分で
その状態を作り出せないか** を検討する。作り出せるなら実行し、作り出せない/危険な場合のみ SKIP する。

主な手段(いずれも実施後の**原状復帰が必須**):

1. **フラグ / 設定の切替** — 機能フラグや設定値で分岐する挙動は、ローカルの設定・コードを
   **一時的に上書き** して再現する(必要ならサーバー再起動)。テスト手順に「フラグを切り替えて」
   等の記述があれば、それはセットアップ指示であって SKIP 理由ではない。
2. **必要データの作成** — 対象状態のデータが存在しなければ **自分で作る**。
   優先度: できる限り **UI 操作で作成**(実利用に近い) → 難しければ DB / API で直接投入。
   投入前に元の値を記録しておく。
3. **失敗経路の検証** — エラーハンドリングや「途中失敗で不整合が残る」等の経路は、
   ネットワークリクエストのブロック / モック、レスポンス改変などで**意図的に失敗を注入**して再現する。
4. **原状復帰(必須)** — 一時的に変更したコード・設定・データは検証後に**必ず元へ戻す**。
   コード/設定はバージョン管理の差分が消えたこと、データは記録した元値へ戻ったことを**明示的に確認**する。
   復帰できない恐れがある操作は、事前にバックアップ or コピー上で行う。

**本当に SKIP してよいのは**、セットアップが技術的に不可能、または不可逆で安全な復帰手段が無い場合のみ。
その際も出力に「なぜ実施できないか」と「実施するなら必要なセットアップ」を必ず書く(単なる SKIP は不可)。


## 敵対的シナリオを自分で1つ作る(渡された手順=ハッピーパスと疑う)

`review.md` や PR の Test Plan の手順は、**書いた人が「動く」と思っているケース**=ハッピーパス。
それを忠実に再現するだけでは「動く証拠」しか得られず、**普通の入力で結果が返らなくなる不具合**は
すり抜ける(チケットの数値例は必ず成立するよう作られている)。

そこで、渡された手順に加えて **核心出力が壊れる negative シナリオを最低1つ自分で構築して実行する**:

- 対象が **ソルバー / 最適化 / バリデーション / 配分 / 計算**、または入力を**分割・制約する新ルール**
  (カテゴリ・テナント・通貨・単位・地域・ステータス等)を足す変更なら必須。
- 例のカバーしない入力を UI で作る: **分割単位ごとに需給が不均衡**、未設定/未割当メンバー混在、
  ゼロ値、レート違いの混在 など。
- 期待する観測: 「解が得られない」「空表示」「エラー」など**結果が返らない状態が
  不当に起きないか**。起きるなら NG として、それを起こした具体的入力を出力に明記する。
- 前提づくりは前節の「能動的セットアップ」(データ作成・フラグ切替)を使い、**実施後は原状復帰**。

これは前節「失敗経路の検証(失敗注入)」とは別軸。あちらは*エラー処理*の確認、こちらは
*正常入力なのに核心出力が生成されない*ことの確認。


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
4. **Screenshot at key points** — 検証ポイントで撮影。**全画面の素撮りをそのまま証拠にしない。関係する領域だけに切り取る**（下記「Cropping and annotation」）。
5. **Rapid capture** — クリック直後の状態（スピナー等）を撮りたい場合は `browser_run_code` で操作とスクリーンショットを一括実行。
6. **Wait appropriately** — ページ遷移やデータロード後は `browser_wait_for` で 2-5 秒待つ。

### Screenshot output

スクリーンショットはタスクスコープに保存する:

```
filename: ".claude/tasks/{ISSUE-KEY}/screenshots/<step-N>-<description>.png"
```

タスクが特定できない場合 (PR ベース等) は `.playwright-mcp/` にフォールバック。**リポジトリルートにファイルを散らかさない。**

撮影と同じディレクトリに **`README.md`** を必ず置く。スクショだけだと後から「何の画面か」が分からなくなるので、ファイル別の観察事項 + 検証結果サマリ + 未確認/制約 を書く。

### Cropping and annotation — 貼って伝わる証拠にする

**1600×900 の素撮りで関係箇所が 2 割しかない画像は醜い。まず切り取る。** 注釈はその後、
「切り取っただけでは結論が読めないとき」にだけ足す。順序を逆にすると枠とラベルが増殖する。

#### 1. 切り取り（必須）

`browser_take_screenshot` に clip は無いので `browser_run_code_unsafe` から
`page.screenshot({path, clip})` を使う。**clip は対象の外接矩形 + 余白 28px 程度**。
0〜8px だと枠線が画像の縁に接してギリギリに見える。

```js
async (page) => {
  const b = JSON.parse(await page.evaluate(() => { /* 対象の rect を返す */ }));
  const P = 28, vw = 1680, vh = 900;
  const clip = {x: Math.max(0, b.x1-P), y: Math.max(0, b.y1-P),
    width: Math.min(vw, b.x2+P) - Math.max(0, b.x1-P),
    height: Math.min(vh, b.y2+P) - Math.max(0, b.y1-P)};
  await page.screenshot({path: '<abs path>', clip});
}
```

モーダルやダイアログは**そのモーダルの矩形**を clip にする。左パネルの 1 項目なら
その項目 + 数十 px。対象が画面外なら `scrollIntoView({block:'center'})` してから測る。

#### 2. 注釈は「素の画像で結論が出ないとき」だけ

判定: **レビュアーに何を結論させたいかを言葉にして、切り取った画像だけでそれが強制されるか**を問う。

| 状況 | 注釈 |
|---|---|
| 画面の中身がそのまま結論（ファイル名と件数が主張、項目が 1 つだけ変わった） | **枠なし**。切り取りだけ |
| どこを見るかが曖昧（画面内に似た要素が並ぶ） | **枠 1 つ**。ラベルなし（手順の本文が説明している） |
| N 件の対比が主張（3 件 + 1 件、リンクあり/なし） | **枠を N 件すべてに**。1 件だけ囲むと「これが壊れている」に読める。短いタグを添える |

ラベルは長文の凡例ボックスではなく **数語のタグ**（`spreading x3` など）で足りることが多い。
タグは**証拠になっている値（サイズ列・件数・日時など）に被せない**。空いている列や余白に置く。
色: 🔴 変化した主役 / 🟠 対になる別の側 / 🟢 不変の対照。

#### 3. 実装

`browser_evaluate` で **ライブ画面に overlay div を注入 → そのまま撮影**（ピクセル完全一致、
外部ライブラリ不要）。枠は `position:fixed` / `border:3px solid` / `pointerEvents:none` /
大きい `zIndex`、**対象の外周だけ**を囲んで中身を隠さない。撮影後に
`document.querySelectorAll('.__hl').forEach(e=>e.remove())` で必ず片付ける。

**UI の見た目を撮影用に改変しない**（列幅を CSS で広げて省略表示を解除する等）。
レビュアーが実際に見る画面と違うものを見せることになる。名前が省略されて主張が読めないなら、
タグや手順本文の文字で補う。

**before/after は同一フレーミング**で撮る。1 箇所だけ変わる並びにすると差分が刺さる。

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
- (SKIP の場合のみ) **SKIP 理由 / 必要セットアップ**: [なぜ実施できなかったか + 実施するなら何が必要か]

### Summary
- Total: N steps
- OK: N / NG: N / SKIP: N
```

SKIP を出す前に「前提条件の能動的セットアップ」を試したか自問する。試さずに SKIP した項目があれば、
出力前に戻ってセットアップを試みる。SKIP は理由と必要セットアップの明記が無い限り認めない。
