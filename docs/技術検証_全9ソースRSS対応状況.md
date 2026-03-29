# 全9ソース 技術検証結果

## 検証サマリー

| # | ソース | RSS対応 | 取得方法 | 難易度 | 備考 |
|---|-------|---------|---------|-------|------|
| 1 | 日経新聞 | ✕ 公式なし | Web検索 or 非公式RSS | ⚠️ やや難 | 公式RSSは提供終了。非公式サービス（RSS愛好会等）か、CoworkのWeb検索で代替 |
| 2 | NewsPicks | ✕ 公式なし | Web検索 or スクレイピング | ⚠️ やや難 | 公式RSS/APIなし。非公式RSSジェネレーターが存在するが安定性に不安 |
| 3 | Reuters | ✕ 公式廃止 | Web検索 or Feed Creator | ⚠️ やや難 | 2020年にRSS公式提供を終了。Feed Creator等のワークアラウンドは2026年3月時点で動作不安定との報告あり |
| 4 | TechCrunch | ✅ 公式あり | RSS | ✅ 簡単 | `https://techcrunch.com/feed/` で全記事取得可能。カテゴリ別フィードも充実 |
| 5 | Hacker News | ✅ 公式あり | RSS | ✅ 簡単 | 公式: `https://news.ycombinator.com/rss`（フロントページ）。hnrss.org でポイント数フィルタ等のカスタムフィードも可能（例: `https://hnrss.org/frontpage?points=100`） |
| 6 | Product Hunt | ✅ 公式あり | RSS | ✅ 簡単 | 公式RSSフィードあり。日次の注目プロダクトを取得可能 |
| 7 | LeadDev | △ 未確認 | Web検索 or ニュースレター | ⚠️ 中程度 | 公式RSSフィードの存在を確認できず。週刊ニュースレターは提供あり。CoworkのWeb検索で `leaddev.com` の最新記事を取得する方が現実的 |
| 8 | The Hacker News | ✅ 公式あり | RSS | ✅ 簡単 | `https://feeds.feedburner.com/TheHackersNews` で全記事取得可能 |
| 9 | IPA | ✅ 公式あり | RSS | ✅ 簡単 | 重要なセキュリティ情報: `https://www.ipa.go.jp/security/rss/alert.rdf`、一般セキュリティ情報: `https://www.ipa.go.jp/security/rss/info.rdf` |

---

## 判定

**RSS取得が簡単なソース（5/9）：**
TechCrunch, Hacker News, Product Hunt, The Hacker News, IPA

**RSS取得が困難 or 不安定なソース（4/9）：**
日経新聞, NewsPicks, Reuters, LeadDev

---

## 取得方法の方針

### 方針A：RSSベースで統一
RSS対応の5ソースのみRSSで取得し、残り4ソースはCoworkのWeb検索（スクレイピング）で補完する。

### 方針B：全てCoworkのWeb検索で統一
Coworkスケジュールでは、ClaudeがWeb検索を使って各ソースの最新記事を収集する。RSSパーサーを自前で実装する必要がなく、スキルのプロンプトで「このサイトの最新記事を探して」と指示するだけ。

### 推奨：方針B

**理由：**
- Coworkスケジュールタスクの中でClaudeがWeb検索を実行できるため、RSS非対応サイトの問題が解消される
- RSSパーサーの実装・メンテナンスが不要
- スキルのプロンプトを変えるだけでソースの追加・変更が可能
- 「信頼できるソースを固定して追う」方針とも整合する（検索時にサイトを指定する）

**トレードオフ：**
- Web検索結果の安定性はRSSより劣る可能性がある
- 同じ検索でも日によって拾える記事が変わるリスク
- RSSのように「確実に全件取得」はできない

---

## 確定したRSS URL一覧（方針A採用時の参考）

```
# TechCrunch（全記事）
https://techcrunch.com/feed/

# Hacker News（フロントページ、100ポイント以上）
https://hnrss.org/frontpage?points=100

# Product Hunt（注目プロダクト）
https://www.producthunt.com/feed

# The Hacker News（セキュリティニュース）
https://feeds.feedburner.com/TheHackersNews

# IPA 重要なセキュリティ情報
https://www.ipa.go.jp/security/rss/alert.rdf

# IPA 情報セキュリティ新着情報
https://www.ipa.go.jp/security/rss/info.rdf
```

---

## 設計への影響

この検証結果を踏まえ、Coworkスケジュールのスキル設計時に以下を考慮する：

1. **基本はWeb検索ベース**で全ソースを統一的に扱う
2. RSSが使えるソースは**信頼性の高いバックアップ手段**として活用可能
3. 日経・Reuters・NewsPicksは有料記事が多いため、**見出しと公開部分の要約**に留まる前提で設計
4. LeadDevは更新頻度が週1程度のため、**該当なしの日が多い**ことを許容する
