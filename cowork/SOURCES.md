# ソース定義

本ファイルは、デイリーブリーフィングで採用可能なソースを**限定列挙**するものです。
ここに載っていないソース（例：Cybernews、BleepingComputer、Bloomberg、ITmedia 等）は、
件数埋めのためであっても採用しない。定義外ソースの混入は CHECKLIST での失格条件とする。

## 共通ルール

- **限定リスト**：本ファイルに記載されたソース以外は採用しない
- **件数レンジは上限**：各カテゴリの「N〜M本」は上限の目安。下限に届かない場合は無理に埋めず、実数で出すか「本日の更新なし」とする
- **鮮度**：採用時点で公開日が **7日以内**（直近1週間）の記事のみ
- **個別記事URL**：ニュースルーム/一覧/タグ/検索結果ページは不可。個別記事URLに限る
- **公開日の確認**：リンク先ページで公開日が確認できない記事は採用しない
- **重複排除**：同一トピックで複数ソースが取れる場合は、最も情報量の多い1本に絞る
- **AI × ビジネス**：AI関連は原則「AI最新動向」。ただし業界動向・規制・大型資金調達などビジネス文脈が強い場合は「ビジネス・経済」に置いてよい（両カテゴリへの二重掲載はしない）

## 📰 ビジネス・経済（3〜5本）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| 日経新聞 | JP | `site:nikkei.com 経済 OR 企業 OR 政治` | nikkei.com |
| NewsPicks | JP | `site:newspicks.com 最新` | newspicks.com |
| Reuters | EN | `site:reuters.com business OR economy` | reuters.com |
| TechCrunch | EN | `site:techcrunch.com funding OR acquisition` | techcrunch.com |

対象トピック：国内経済、海外経済、産業・企業動向、政治・規制・法律

## 🤖 AI最新動向（3〜5本）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| OpenAI Blog | EN | `site:openai.com/blog` | openai.com/blog |
| Google Research Blog | EN | `site:research.google/blog` | research.google/blog |
| Anthropic Blog | EN | `site:anthropic.com/news OR site:anthropic.com/engineering` | anthropic.com/news |
| Hacker News（AIフィルタ） | EN | `site:news.ycombinator.com AI OR LLM OR GPT` | news.ycombinator.com |

対象トピック：新モデル・新機能リリース、AI研究の進展、AI規制・ガバナンス、AI活用事例

## 🚀 新サービス・ローンチ（3〜5本）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| Hacker News | EN | `site:news.ycombinator.com Show HN OR Launch` | news.ycombinator.com |
| Product Hunt | EN | `site:producthunt.com` | producthunt.com |

対象トピック：新しいSaaS・ツール、スタートアップの**製品ローンチ**、開発者向けツール・ライブラリ

※ 資金調達・IPO・M&A のニュースは本カテゴリではなく「📰 ビジネス・経済」へ入れる（`cowork/SELECTION_RULES.md` 参照）。

## 🇯🇵 国内技術・ツール（2〜3本）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| DevelopersIO | JP | `site:dev.classmethod.jp` | dev.classmethod.jp |
| 窓の杜 | JP | `site:forest.watch.impress.co.jp` | forest.watch.impress.co.jp |

対象トピック：国内で話題の技術記事・ハウツー、新しいソフトウェア・ツールの紹介・レビュー

## 📋 EM/PM（1〜2本、更新があれば）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| LeadDev | EN | `site:leaddev.com` | leaddev.com |

対象トピック：ピープルマネジメント・組織論、プロダクト戦略・フレームワーク

## 🔒 セキュリティ（2〜3本）

| ソース | 言語 | 検索クエリ例 | URL |
|-------|------|------------|-----|
| The Hacker News | EN | `site:thehackernews.com` | thehackernews.com |
| IPA | JP | `site:ipa.go.jp/security` | ipa.go.jp |

対象トピック：脆弱性情報（CVE、ゼロデイ等）、情報漏洩・インシデント事例、ベストプラクティス、規制・コンプライアンス
