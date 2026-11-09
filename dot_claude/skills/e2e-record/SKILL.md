---
name: e2e-record
description: "Playwright MCP で UI 操作を動画 (mp4) に録画する。バグの再現動画、操作手順の動画、PR に貼る動画が欲しいときに使う。「動画撮って」「録画して」「再現動画」で発動。/e2e-verify の video オプションからも呼ばれる。"
argument-hint: "[env] <録画したい手順 | review.md のシナリオ名>"
---

# E2E Record

Playwright MCP のブラウザで UI 操作を通しで録画し、mp4 にして保存する。
**手順の決め方は持たない**。何を撮るかは引数（または呼び出し元の `/e2e-verify`）が決める。
撮る手順が曖昧なら、録画を始める前にユーザーに確認する。

## Setup

1. **設定** — `/e2e-verify` と同じ `.claude/e2e-verify/config.yaml` を読む（URL、アカウント、`component-gotchas`）。環境トークンの扱いも `/e2e-verify` と同じ。
2. **Playwright MCP** — `ToolSearch` で `mcp__playwright__browser_run_code_unsafe` を取得。なければ中断。
3. **ffmpeg (変換用)** — `which ffmpeg ffprobe`。なければ webm のまま渡し、mp4 にできないことを報告する。
4. **ffmpeg (録画用)** — Playwright は録画に**自分の版の** ffmpeg を使う。版が合わないと、エラーも出ずに動画ファイルが空のまま終わる。MCP が使う playwright-core が要求する版を調べ、無ければその playwright-core で入れる。
   ```bash
   pid=$(pgrep -f 'node_modules/.bin/playwright-mcp' | head -1)
   core="$(dirname "$(ps -o command= -p "$pid" | awk '{print $2}')")/../playwright-core"
   rev=$(node -e "console.log(require('$core/browsers.json').browsers.find(b=>b.name==='ffmpeg').revision)")
   ls ~/Library/Caches/ms-playwright/ffmpeg-$rev/ffmpeg-mac || (cd "$core" && node cli.js install ffmpeg)
   ```
   - 別の版のフォルダをコピーして代用しない。`INSTALLATION_COMPLETE` があると正規の install がスキップされ、空の動画のままになる
   - 不安なら 3 秒だけの録画を撮り、`dir` にファイルができるか確かめてから本番に入る
5. **Component Gotchas** を読む。画面の開き方やクリックの癖はそこにある。`verified:` が 6 か月以上前の項目と `unverified` の項目は、頼る前に今の DOM と照合する。

## 録画の前に必ずやること

### 1. 使い捨てのデータで撮る

録画は**撮り直しが前提**（1 回で撮れることは少ない）。2 回目以降は前回の操作で作ったデータが残る。

- 破壊的な操作（リセット、一括更新、削除）を含むなら、**コピーを作ってそれを使う**。元のデータには触らない
- 撮り直す前に、**データを録画前の状態に戻す**。戻す内容（元の値、消す行）は最初に記録しておく
- 最後にコピーを削除し、元のデータが変わっていないことを確認する

### 2. 手順を録画なしで 1 回通す

各操作の要素（セレクタ）と、クリックで反応するかを**先に録画なしで確かめる**。保存はしない（キャンセルで閉じる）。
録画中に要素探しで止まると、動画が無駄になるうえ撮り直しのたびにデータを戻す手間が増える。

- `page.locator('親タグ 子セレクタ')` の CSS は Shadow DOM を貫通する。`fill` / `type` / `check` / `click` はこれで足りることが多い
- 部品ごとに効くクリック方法が違う（JS の `.click()` で効くもの、内側の要素を押す必要があるもの、合成イベントでは反応しないもの）。component-gotchas に書かれていればそれに従う

## 録画

### 3. 全手順を 1 回の `browser_run_code_unsafe` で流す

**呼び出しをまたいで変数は残らない**（`globalThis` も消える）。録画用の画面を 1 回目で作って 2 回目で使う、はできない。
新しい画面の作成から `ctx.close()` まで、1 つのコードに入れる。

```js
async (page) => {
  const state = await page.context().storageState(); // ログイン状態を引き継ぐ
  const browser = page.context().browser();
  const dir = '<scratchpad の絶対パス>/video';        // 撮り直すたびに別のフォルダにする
  const ctx = await browser.newContext({
    storageState: state,
    viewport: { width: 1280, height: 800 },
    recordVideo: { dir, size: { width: 1280, height: 800 } },
  });
  const vp = await ctx.newPage();
  const log = [];
  const CAP_LEFT = '24px'; // 操作する部分に被るなら、その右端より右へずらす
  const cap = (t) => vp.evaluate((t) => {
    let d = document.getElementById('__cap');
    if (!d) {
      d = document.createElement('div'); d.id = '__cap';
      Object.assign(d.style, { position: 'fixed', left: CAP_LEFT, right: '24px', bottom: '24px',
        padding: '12px 16px', background: 'rgba(0,0,0,0.85)', color: '#fff',
        font: '600 18px sans-serif', borderRadius: '8px', zIndex: 2147483647,
        pointerEvents: 'none', border: '1px solid #888' });
      document.body.appendChild(d);
    }
    d.textContent = t;
  }, t);
  try {
    // ここに手順。各場面の頭で cap('Step 1: ...')、結果を見せる場面は waitForTimeout(5000) 以上止める
    // 画面上の値は vp.evaluate で読み、log.push() して後で報告に使う
  } catch (e) {
    log.push('ERROR: ' + e.message.split('\n')[0]);
  }
  const video = vp.video();
  await ctx.close();                 // 閉じるまで動画ファイルは書き出されない
  return { log, path: video ? await video.path() : null };
}
```

- **字幕**は操作する部分や結果の表示に被らない位置に置く。録画なしで通したときの画面で、被らない左端を決めて `CAP_LEFT` に入れる。英語で、場面ごとに「Step N」「Result N」と書く
- **ページ遷移**（`goto`、再読み込み）で字幕は消える。遷移のあとは `cap()` を呼び直す
- 送信内容が証拠になるなら `vp.on('request', ...)` で `postData()` を `log` に入れる
- 実行が **120 秒を超えるとバックグラウンドに回る**。完了の通知を待つ。途中で状態を推測して報告しない
- `log` に `ERROR:` があれば、`ctx.close()` 済みの動画は途中までしか撮れていない。原因を直し、データを戻してから撮り直す。途中で終わった前回の画面が残っていたら `browser.contexts()` から閉じる

## 録画のあと

### 4. mp4 に変換する

GitHub での互換性のため H.264 にする（GitHub は .mp4 / .mov / .webm を受け付け、H.264 を推奨している）。

```bash
ffmpeg -v error -y -i <in.webm> -c:v libx264 -pix_fmt yuv420p -crf 23 -movflags +faststart <out.mp4>
```

**10MB を超えたら縮める**（無料プランの上限。有料プランは 100MB）。`-crf 28` に上げる、`-vf scale=960:-2` で縮める、待ち時間の場面を `-ss` / `-t` で切る、の順に試す。

### 5. 中身を確認してから報告する（必須）

`log` に `ERROR:` が無くても、**撮れたつもりで途中の画面のまま止まっていることがある**。数秒おきのフレームを並べた一覧画像を作り、Read で見る。

```bash
ffmpeg -v error -y -i <out.mp4> -vf fps=1/6 <scratchpad>/frames/f%02d.png
ffmpeg -v error -y -i <scratchpad>/frames/f%02d.png -vf "scale=320:-1,tile=7x3" <scratchpad>/frames/contact.png
```

結論になる場面（エラー表示、数値）は 1 枚ずつ拡大して、主張どおりの表示が映っていることを確かめる。

### 6. 保存と記録

- 保存先は `/e2e-verify` のスクリーンショットと同じ `.claude/tasks/{ISSUE-KEY}/screenshots/`。ファイル名は `e2e-<シナリオ>-<内容>.mp4`
- 途中経過の webm、フレーム、失敗した録画は scratchpad に置き、リポジトリに入れない
- 同じディレクトリの `README.md` に追記する: 何の動画か、長さと解像度、手順の要約、`log` で取れた値、**字幕は録画用に重ねたものでアプリの表示ではないこと**、使ったデータと片付けの結果
- 操作の癖は `component-gotchas` に同期する。やり方は `/e2e-verify` の Post-verification と同じ（同じ見出しがあれば書き換え、通用した項目は `verified:` を更新、合わなかった項目は修正か削除、座標は書かない）

## Output

```markdown
## E2E Recording Result

- **Video**: [path]（長さ、解像度、サイズ）
- **手順**: 撮った場面の一覧
- **確認した値**: log から（画面の文言、送信内容）
- **撮り直し**: N 回（理由）
- **片付け**: 使ったデータと戻した結果
```
