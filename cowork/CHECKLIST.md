# CHECKLIST.md

最終保存前に、以下をすべて確認する。1つでも失敗があれば `_posts/` 保存・`git add`・`commit`・`push` を行わない。

## 0. 機械検証スクリプトを最初に実行する（★必須）

`cowork/scripts/check.sh` で以下を一括検証できる：
- ソースホワイトリスト照合（SOURCES.md）
- DENYLIST ドメイン・パターン照合
- 個別記事URL パターン検証
- クロス日重複（他の `_posts/*.md` との URL 突き合わせ）

```bash
bash cowork/scripts/check.sh drafts/tmp/YYYY-MM-DD-briefing.md
```

`PASS` が出るまで `_posts/` に保存しない。`FAIL:` の各行が具体的な違反箇所。

**以下の B〜E 項目はこのスクリプトが自動検証する。人間（またはモデル）が手動で確認するのは A・D・F・G・H の人手判断が必要な項目**に限定できる。

## A. ファイル・構造

- [ ] ファイル名が `YYYY-MM-DD-briefing.md` になっている
- [ ] `_posts/` に置く正式版と `drafts/tmp/` の下書きが混同していない
- [ ] front matter がある（`title` `date` `layout`）
- [ ] 6カテゴリ順が固定順になっている（ビジネス → AI → 新サービス → 国内技術 → EM/PM → セキュリティ）
- [ ] `## 🎯 今日のまとめ` セクションがある
- [ ] `<details markdown="block">` の構造が壊れていない
- [ ] `<details>` の `summary` に書いた件数カウント（例：「3件」）が実際の記事数と一致している
- [ ] 0件カテゴリはまとめに `本日の更新なし` と書き、details セクションを**省略**している

## B. ソース照合（SOURCES.md ホワイトリスト）

- [ ] すべての記事URLのドメインが `cowork/SOURCES.md` の限定リストに含まれる
  - 許可ドメイン（15エントリ）: `nikkei.com`, `newspicks.com`, `reuters.com`, `techcrunch.com`, `openai.com`, `research.google`, `anthropic.com`, `news.ycombinator.com`, `producthunt.com`, `dev.classmethod.jp`, `forest.watch.impress.co.jp`, `leaddev.com`, `thehackernews.com`, `ipa.go.jp`
- [ ] `cowork/DENYLIST.md` に記載のNGドメインが**含まれていない**
  - 既知NG: `cybernews.com`, `fortune.com`, `theregister.com`, `news.crunchbase.com`, `bloomberg.com`, `markets.financialcontent.com`
- [ ] 類似ドメイン（例: `reuters.com` に対する `markets.financialcontent.com`）を誤認して採用していない

## C. 個別記事URL検証

- [ ] すべてのURLが**個別記事URL**である。以下のパターンは**不可**：
  - `anthropic.com/news`（末尾スラッシュ有無問わず、個別スラグなし）
  - `openai.com/blog`、`openai.com/news`（個別スラグなし）
  - `producthunt.com/leaderboard/*`（ランキングページ）
  - `*/tag/*`, `*/category/*`, `*/topics/*`, `*/search?*`, `*/?s=*`
  - `news.ycombinator.com`, `/news`, `/newest`（`/item?id=...` のないもの）
  - ドメイン直下（例: `https://techcrunch.com/`）
- [ ] OKパターン例: `anthropic.com/news/{slug}`, `openai.com/index/{slug}`, `techcrunch.com/YYYY/MM/DD/{slug}/`, `news.ycombinator.com/item?id={id}`

## D. 鮮度（7日以内）

- [ ] すべての記事の公開日が、実行日から**7日以内**
- [ ] 公開日を確認できない記事は含まれていない

## E. クロス日重複チェック（★最重要 / check.sh が自動検証）

- [ ] `cowork/scripts/check.sh` が `PASS` を返している（クロス日重複を含む全項目）
- [ ] 同一トピックを別ソースで繰り返していない（情報量の多い1本に絞られている ※手動判断）

## F. 記述品質

- [ ] 全記事に元記事リンクがある
- [ ] 見出しが具体的で、日本語として自然（「〇〇について」のような曖昧見出しはNG）
- [ ] 要約が1〜2文で事実ベース（推測・意見なし）
- [ ] 全文転載になっていない

## G. カテゴリ境界

- [ ] 資金調達・IPO・M&A は **ビジネス・経済** に分類されている（新サービス・ローンチではない）
- [ ] 「新サービス・ローンチ」は**製品・サービスの新規公開**に限定されている
- [ ] AI × ビジネスは AI最新動向 か ビジネス・経済のどちらか一方のみ（二重掲載なし）

## H. 差分・公開基盤

- [ ] 意図しないファイル差分が混ざっていない
- [ ] レイアウト・GitHub Actions・`cowork/*` など公開基盤ファイルを誤って変更していない
