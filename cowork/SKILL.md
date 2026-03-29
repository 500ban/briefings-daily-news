---
name: daily-briefing-generator
description: "Generates a daily news briefing by collecting articles from 15 fixed sources across 6 categories (business, AI, new services, domestic tech, EM/PM, security), summarizing them in Japanese, and outputting a structured Markdown file with category summaries and collapsible details. Triggers when asked to create a daily briefing, morning news summary, or news digest."
---

# デイリーブリーフィング生成スキル

## 概要

毎朝のニュースブリーフィングを自動生成するスキル。固定された15ソースからWeb検索で最新記事を収集し、6カテゴリに分類・日本語要約してMarkdownファイルを出力する。

## ワークフロー

### Step 1: ソース別の最新記事収集

SOURCES.md に定義された15ソースについて、Web検索で直近24時間の最新記事を収集する。

- 各ソースにつき、サイト名を含む検索クエリを使用（例: `site:nikkei.com 最新ニュース`）
- 英語ソースの記事も収集対象に含める
- 各カテゴリの目標件数に達するまで収集する

### Step 2: カテゴリ分類と選定

収集した記事を6カテゴリに分類し、各カテゴリの目標件数に絞り込む。

| カテゴリ | 件数 |
|---------|------|
| 📰 ビジネス・経済 | 3〜5本 |
| 🤖 AI最新動向 | 3〜5本 |
| 🚀 新サービス・ローンチ | 3〜5本 |
| 🇯🇵 国内技術・ツール | 2〜3本 |
| 📋 EM/PM | 1〜2本（更新があれば） |
| 🔒 セキュリティ | 2〜3本 |

### Step 3: 要約・整形

各記事について以下を生成する：

- **見出し**：記事の内容を端的に表す日本語タイトル（原文が英語でも日本語に翻訳）
- **1行要約**：記事の要点を1〜2文の日本語で記述
- **元記事リンク**：元記事のURL

### Step 4: ブリーフィング生成

TEMPLATE.md のフォーマットに従い、以下の構造でMarkdownファイルを生成する：

1. **🎯 今日のまとめ**（カテゴリごとに2〜3行の要約、常時表示）
2. **折りたたみ詳細**（`<details markdown="block">` で各カテゴリの全記事を格納）

### Step 5: ファイル保存とgit push

1. 生成したMarkdownを `_posts/YYYY-MM-DD-briefing.md` として保存
2. Jekyll用のYAMLフロントマターを付与（title, date, layout）
3. `git add` → `git commit -m "📰 YYYY-MM-DD briefing"` → `git push`

## ルール

### 記述ルール
- **全文日本語**：英語ソースの記事も日本語で要約する
- **簡潔さ**：1記事あたり見出し＋1〜2文の要約に収める
- **リンク必須**：すべての記事に元記事URLを付与する

### 除外ルール
- AI関連のニュースは「🤖 AI最新動向」カテゴリに集約する。ただしAI × ビジネス（業界動向・規制・大型資金調達等）は「📰 ビジネス・経済」にも含めてよい
- 1週間以上前の古い記事は除外する
- 同じトピックの重複記事は最も情報量の多い1本に絞る

### 品質ルール
- 各カテゴリの最小件数を満たせない場合、無理に埋めず「本日の更新なし」と記載する
- 見出しは具体的に。「〇〇について」のような曖昧な見出しは避ける
- 要約は事実ベースで。意見や推測は含めない

## 参照ファイル

- `SOURCES.md` - ソース定義（15ソースの一覧、カテゴリ、URL）
- `TEMPLATE.md` - ブリーフィングのMarkdownテンプレート
