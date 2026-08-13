# DevTools パネルのスクリーンショット

Network の Payload、Console、Performance など **DevTools の画面そのもの**を証拠にしたいときの手順。
「DevTools は撮れない」は誤り。**DevTools ウィンドウは CDP の `page` ターゲットとして並ぶ**ので、
そこに接続すれば `Page.captureScreenshot` がそのまま効く。OS のスクリーンキャプチャも
画面収録権限も、追加ライブラリも不要（**Node 22+ の組み込み `WebSocket`** で CDP を直接話す）。

Playwright MCP / chrome-devtools MCP のブラウザは `--remote-debugging-pipe` で動いていて
ポートを開けていないため、**この用途では自分で Chrome を起動する**。

## 手順

### 1. ポート付き Chrome を起動

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9333 --user-data-dir="$PWD/devtools-profile" \
  --no-first-run --no-default-browser-check --auto-open-devtools-for-tabs \
  --window-size=1680,1000 "<検証したい URL>" &
```

`--auto-open-devtools-for-tabs` が要点。**新規タブごとに DevTools が開き、そのタブに接続済みの状態**になる。

ログインが要るアプリは、Playwright MCP のプロファイルを複製すると引き継げることがある
（セッション cookie が永続化されていれば）:

```bash
rsync -a --delete --exclude 'Cache' --exclude 'Code Cache' --exclude 'GPUCache' \
  ~/Library/Caches/ms-playwright/mcp-chrome-*/ ./devtools-profile/
```

引き継げなければ、起動後に CDP の `Runtime.evaluate` でログインフォームを埋める。

### 2. ブラウザ端点に接続して flat session を張る

```js
const { webSocketDebuggerUrl } = await (await fetch('http://127.0.0.1:9333/json/version')).json();
const ws = new WebSocket(webSocketDebuggerUrl);
await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
let id = 0; const pending = new Map();
ws.onmessage = (e) => { const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { const { res, rej } = pending.get(m.id); pending.delete(m.id);
    m.error ? rej(new Error(JSON.stringify(m.error))) : res(m.result); } };
const raw = (method, params = {}, sessionId) => new Promise((res, rej) => {
  const i = ++id; pending.set(i, { res, rej });
  ws.send(JSON.stringify(sessionId ? { id: i, method, params, sessionId } : { id: i, method, params })); });

const { targetInfos } = await raw('Target.getTargets');
const dtTarget  = targetInfos.find(t => t.url.startsWith('devtools://'));      // DevTools ウィンドウ
const appTarget = targetInfos.find(t => t.type === 'page' && t.url.includes('<app>'));
const { sessionId } = await raw('Target.attachToTarget', { targetId: dtTarget.targetId, flatten: true });
const send = (method, params = {}) => raw(method, params, sessionId);
```

**必ずブラウザ端点 + `flatten: true`** を使う。旧 `/devtools/page/<id>` の WebSocket は
**1 タブ 1 クライアントの排他**で、自分が繋ぐと DevTools 側が
"Debugging connection was closed" で切れる。flat session ならアプリ操作と DevTools が共存する。

### 3. DevTools を操作する

- **パネル切替・タブ・行の選択は実マウスイベントが要る**。`element.click()` は効かない
  ```js
  for (const type of ['mouseMoved', 'mousePressed', 'mouseReleased'])
    await send('Input.dispatchMouseEvent', { type, x, y, button: type === 'mouseMoved' ? 'none' : 'left',
      clickCount: type === 'mouseMoved' ? 0 : 1 });
  ```
  座標は `Runtime.evaluate` で `getBoundingClientRect()` を取ってから渡す。DevTools 内部は
  Shadow DOM が深いので、shadow 貫通 walker（SKILL.md 参照）で要素を探す。
- **ドッキング状態とパネルは host preference**。localStorage ではない
  ```js
  InspectorFrontendHost.setPreference('currentDockState', '"undocked"');
  InspectorFrontendHost.setPreference('panel-selectedTab', '"network"');
  ```
  反映されるのは**次に DevTools が開くタブ**から。既存ウィンドウには効かないので、
  設定してから新しいタブを開く。undocked にしないと DevTools の描画領域が
  ブラウザ幅の一部にしかならず、スクショの大半が余白になる。
- **JSON ツリーの展開はキーボードが確実**。三角の座標クリックは外しやすい
  ```
  行をクリックして選択 → ArrowRight で展開 → ArrowDown で移動
  ```
  `Input.dispatchKeyEvent` は `type:'rawKeyDown'` + `windowsVirtualKeyCode`（ArrowRight=39 /
  ArrowDown=40）で送る。選択行は `li.selected` の textContent で毎回確認しながら進める。

### 4. 撮影と後片付け

撮影は `Page.captureScreenshot`（`clip` で切り取り可）。**切り取りと注釈の方針は
SKILL.md の「Cropping and annotation」に従う**。

終わったら起動した Chrome を落とす（`pkill -f devtools-profile`）。一時プロファイルも消す。
検証対象が共有環境なら、撮影のために実行した操作（アップロード等）の**副作用を報告に書く**。

## 落とし穴まとめ

| 症状 | 原因と対処 |
|---|---|
| "Debugging connection was closed" | 1 タブ 1 クライアント。旧 `/devtools/page/` を使わず flat session にする |
| `http://<port>/devtools/inspector.html?ws=...` を別タブで開いても繋がらない | 同上。auto-open 済みのタブには 2 つ目のフロントエンドを繋げない |
| パネルが切り替わらない | `.click()` ではなく `Input.dispatchMouseEvent` |
| スクショの大半が空白 | DevTools が docked。`currentDockState` を undocked にして**新しいタブ**を開く |
| 設定が localStorage に無い | DevTools の設定は `InspectorFrontendHost.getPreferences` / `setPreference` |
