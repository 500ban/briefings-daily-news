# ソース定義

本ファイルは、デイリーブリーフィングで採用可能なソースを**役割別に限定列挙**するものです。
主要信頼ソースは、通常ニュース本文の事実確認・採用判定の軸として使う。
反応・補助ソースは、`last30days-skill` などで見つけたコミュニティの反応量・現場感・論点確認に使う。

ここに載っていないソース（例：Cybernews、BleepingComputer、Bloomberg、ITmedia 等）は、
件数埋めのためであっても採用しない。定義外ソースの混入は CHECKLIST での失格条件とする。

> **注（機械パース対象）**: 本ファイルは `cowork/scripts/check.sh` が直接パースして
> 許可ドメインを生成する（単一の正）。各テーブルの**最終列（URL列）**からドメインを抽出し、
> 「## 反応・補助ソース」より前を主要信頼ソース、以降を反応補助ソースとして扱う。
> 表のレイアウト（最終列＝URL、見出し名）を変える場合は check.sh の `parse_sources` も合わせて確認すること。
> 読み込みに失敗すると check.sh は exit 2 で停止する（黙って素通ししない）。

## 共通ルール

- **限定リスト**：本ファイルに記載された主要信頼ソース・反応補助ソース以外は採用しない
- **主要信頼ソース**：通常ニュース本文の事実確認、採用判定、元記事リンクに使う
- **反応・補助ソース**：コミュニティ反応や補足に限って使う。反応補助ソースだけで通常ニュース本文の事実を断定しない
- **件数レンジは上限**：各カテゴリの「N〜M本」は上限の目安。下限に届かない場合は無理に埋めず、実数で出すか「本日の更新なし」とする
- **鮮度**：採用時点で公開日が **7日以内**（直近1週間）の記事のみ
- **個別記事URL**：ニュースルーム/一覧/タグ/検索結果ページは不可。個別記事URLに限る
- **公開日の確認**：リンク先ページで公開日が確認できない記事は採用しない
- **重複排除**：同一トピックで複数ソースが取れる場合は、最も情報量の多い1本に絞る
- **AI × ビジネス**：AI関連は原則「AI最新動向」。ただし業界動向・規制・大型資金調達などビジネス文脈が強い場合は「ビジネス・経済」に置いてよい（両カテゴリへの二重掲載はしない）

## last30days-skill の扱い

`last30days-skill` は、主要信頼ソースを置き換えるものではなく、候補トピック発見・反応確認の補助として使う。

- 通常ニュースとして採用する場合: 主要信頼ソース、公式情報、信頼媒体で裏取りする
- 裏取りできないが有用な場合: 「コミュニティ反応」または記事内の「補足」として明示する
- 裏取りできず、反応としても薄い場合: 採用しない
- 有料APIキーやブラウザトークンを前提にしない。まず無料・低設定で使える範囲を優先する

## 主要信頼ソース

以下は通常ニュース本文の事実確認・採用判定に使えるソース。

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

## 反応・補助ソース（コミュニティ反応用）

以下は `last30days-skill` 由来の発見、反応量、現場感、実務ニーズの確認に使える。
通常ニュース本文の事実確認リンクとして単独利用しない。

| ソース | 用途 | URL |
|-------|------|-----|
| Hacker News | 開発者コミュニティの反応、Show HN / Launch HN、技術論点 | news.ycombinator.com |
| Reddit | 利用者・開発者の反応、実務上の困りごと、比較・評判 | reddit.com |
| GitHub | release / issue / discussion / PR など、開発実態や利用者要望 | github.com |
| YouTube | 解説動画・レビュー・カンファレンス・デモの反応確認 | youtube.com |
| YouTube（短縮URL） | youtu.be 形式の共有リンク | youtu.be |
| X | 速報的な反応、専門家・開発者の短文コメント | x.com |
| X（旧Twitter） | 旧 twitter.com ドメインの投稿 | twitter.com |

反応補助ソースを掲載する場合:
- 「コミュニティ反応」「補足」「HNでは」「Redditでは」など、反応であることを明示する
- 個別投稿・個別 issue・個別 discussion・個別動画など、具体的なURLにリンクする
- 反応補助ソースの記述は、事実本文ではなく補足情報として扱う
