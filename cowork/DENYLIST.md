# DENYLIST.md

本ファイルは、過去のブリーフィング監査で実際に混入した **NGソース** と
**NG URLパターン** を記録するものです。

`SOURCES.md` が「採用可能なもの」の正リストであるのに対し、
このファイルは「絶対に採用してはいけないもの」の逆引きリストとして機能します。

Cowork は保存前に本ファイルを参照し、ここに挙がるドメイン・パターンが
ドラフトに混入していないかを必ず確認すること。

---

## NGドメイン（ソース定義外、過去に混入した実例）

以下のドメインは `SOURCES.md` の限定リストに含まれておらず、採用不可。

| ドメイン | 検出時期 | 混入経緯 |
|---------|---------|---------|
| `cybernews.com` | 2026-03-29 | AI最新動向に LiteLLM 記事として混入 |
| `fortune.com` | 2026-04-02 | AI最新動向に Claude Mythos 記事として混入 |
| `theregister.com` | 2026-04-02 | AI最新動向に Claude Code 記事として混入 |
| `news.crunchbase.com` | 2026-04-02 | ビジネス・経済に Q1 VC投資記事として混入 |
| `bloomberg.com` | 2026-04-03 | ビジネス・経済に米雇用統計記事として混入 |
| `markets.financialcontent.com` | 2026-04-03 | Reuters と誤認、ビジネス・経済に混入 |

**新たなNGドメインを検出した場合、本ファイルに追記すること。**

---

## NG URLパターン（一覧・ランキング・トップページ）

以下は個別記事URLではないため、採用不可。

### トップ・ニュース一覧
- `https://www.anthropic.com/news`（末尾スラッシュ有無問わず、個別スラグなし）
- `https://openai.com/blog`（個別スラグなし）
- `https://openai.com/news`（個別スラグなし）
- ドメイン直下（例: `https://techcrunch.com/`）

### ランキング・リーダーボード
- `https://www.producthunt.com/leaderboard/daily/*`
- `https://www.producthunt.com/leaderboard/weekly/*`
- `https://www.producthunt.com/leaderboard/*`

### タグ・カテゴリ・検索結果
- `*/tag/*`
- `*/category/*`
- `*/topics/*`
- `*/search?*`
- `*/?s=*`

### Hacker News のトップ
- `https://news.ycombinator.com`（`/item?id=...` がないもの）
- `https://news.ycombinator.com/news`
- `https://news.ycombinator.com/newest`

---

## OKパターン（対応する正しい個別記事URL）

参考として、上記NGパターンに対する正しい個別記事URLの形を示す。

| NGパターン | OKパターン |
|----------|-----------|
| `anthropic.com/news` | `anthropic.com/news/{slug}` |
| `anthropic.com/engineering` | `anthropic.com/engineering/{slug}` |
| `openai.com/blog` | `openai.com/index/{slug}` |
| `producthunt.com/leaderboard/*` | `producthunt.com/products/{slug}` |
| `news.ycombinator.com` | `news.ycombinator.com/item?id={id}` |
| `nikkei.com/` | `nikkei.com/article/{id}/` |
| `techcrunch.com/` | `techcrunch.com/YYYY/MM/DD/{slug}/` |
| `thehackernews.com/` | `thehackernews.com/YYYY/MM/{slug}.html` |

---

## 運用ルール

- 本ファイルは `CHECKLIST.md` の検証対象。保存前に必ず突き合わせる
- 監査で新しいNG事例を検出したら、このファイルに追記してから `_posts/` を修正する
- `SOURCES.md` はホワイトリスト、`DENYLIST.md` はブラックリスト。両者は独立に保守する
