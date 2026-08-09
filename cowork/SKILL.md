---
name: daily-briefing-generator
description: "Generates a daily news briefing by validating facts against trusted sources across 6 categories (business, AI, new services, domestic tech, dev org & career, security), summarizing them in Japanese, and outputting a structured Markdown file with category summaries and collapsible details. Triggers when asked to create a daily briefing, morning news summary, or news digest."
---

# デイリーブリーフィング生成スキル

## 概要

毎朝のニュースブリーフィングを生成するスキル。ローカルの Claude Code スケジュールタスク
（`daily-news-briefing`、毎朝07:02 JST）から実行される。主要信頼ソースで裏取りした記事を
6カテゴリに分類・日本語要約し、check.sh の PASS 後に `_posts/` へ保存して GitHub へ push する。

> **旧環境注記**: 2026-07-13 以前の Cowork（クラウドVM）向け手順（clone・トークンURL・マウント探索）は
> 廃止済み。現環境で使わないこと。旧手順は git 履歴参照（`RUNBOOK.md` 末尾にコマンド記載）。

## ワークフロー

### Step 0: 前提（ローカル実行）

- リポジトリフォルダで直接作業する（clone 不要）
- `git pull --rebase origin main` で最新化する
- `_posts/` に本日分 `YYYY-MM-DD-briefing.md` が既に存在すれば何もせず終了（二重生成防止。ログに SKIPPED を記録）

### Step 1: 主要信頼ソースでの収集・裏取り（必ずサブエージェントで実行）

**このステップは、必ず `general-purpose` サブエージェント（Task tool）で実行する。**
WebSearch の生テキストを親コンテキストに乗せないことが、本リポジトリのトークン
効率化方針の核心である（親で20回検索すると毎朝1万トークン以上が浪費される）。

サブエージェントへの指示は以下の固定テンプレートを使う。

```
SOURCES.md に定義されたソースから、本日（YYYY-MM-DD）から直近7日以内に
公開された記事候補を集めてください。

返答は次の表形式のみ。前置き・要約・所感は一切書かないこと。

| カテゴリ | ソース | 公開日 | URL | 1行要約 |

ルール:
- 個別記事URLのみ。一覧/トップ/タグ/ランキングは含めない
- 公開日が確認できない記事は含めない
- DENYLIST のドメイン（cybernews.com, fortune.com, theregister.com,
  news.crunchbase.com, bloomberg.com, markets.financialcontent.com）は含めない
- 各カテゴリ 上限5本、合計30本以内
- 1ソースにつき WebSearch は最大2回まで
```

サブエージェントの戻り値（表）に対して、親側では以下のみを行う：

1. 表中の URL が `cowork/cache/past_urls.txt` に含まれていれば除外する（`comm -23` を使う。1本ずつの手動 grep 禁止）。
   このキャッシュは gitignore 対象のローカル専用ファイルで、check.sh が毎回再生成する（無ければ一度 check.sh を実行して生成）
2. カテゴリ境界の判断（`SELECTION_RULES.md` 準拠）
3. 重複トピックを最も情報量の多い1本に絞る

**過去URLとの重複を収集時に手動確認しない**。最終検証は check.sh が担う。

### Step 1.5: WebSearch が使えない時のフォールバック

週次レート上限・障害時は、中止する前に Chrome MCP による直接ブラウジングを試みる。
手順・URL抽出パターン・制約は **`RUNBOOK.md` Step 2.6** を参照。
完走時のログは `SUCCESS (via Chrome MCP)`、不可なら `ABORTED` を記録して中止する。

### Step 2: カテゴリ分類と選定

| カテゴリ | 件数 |
|---------|------|
| 📰 ビジネス・経済 | 3〜5本 |
| 🤖 AI最新動向 | 2〜4本 |
| 🚀 新サービス・ローンチ | 3〜5本 |
| 🇯🇵 国内技術・ツール | 2〜4本 |
| 📋 開発組織・キャリア | 1〜2本（更新があれば） |
| 🔒 セキュリティ | 2〜4本 |

レンジは上限目安。下限未達なら無理に埋めず「本日の更新なし」。境界判断は `SELECTION_RULES.md`（正本）。

### Step 3: 要約・整形

各記事: 日本語見出し ＋ 1〜2文の事実ベース要約 ＋ 元記事リンク ＋ 行末の `<!-- pub:YYYY-MM-DD -->` マーカー（必須）。
英語ソースには「📖 詳しく読む」（200字以内・最大3文）を付ける。
まとめ冒頭に「⭐ 今日の1本」を1本選ぶ。形式・制約はすべて `TEMPLATE.md` に従う。

### Step 4: ブリーフィング生成

`TEMPLATE.md` のフォーマットで `drafts/tmp/YYYY-MM-DD-briefing.md` に下書きを作る。

### Step 4.5: 機械検証（★必須）

```bash
bash cowork/scripts/check.sh drafts/tmp/$(date +%Y-%m-%d)-briefing.md
```

構造・ソース照合・DENYLIST・個別URL・鮮度・件数整合・クロス日重複・📖字数/文数・評価語WARNを一括検証する。
`FAIL` があれば修正して再実行。**`PASS` 後のみ** `_posts/YYYY-MM-DD-briefing.md` へ保存する。
機械検証で担保される項目を手動で再確認しない（`CHECKLIST.md` は人手判断項目のみ）。

### Step 5: git commit & push

```bash
git pull --rebase origin main
TODAY=$(date +%Y-%m-%d)
git add "_posts/${TODAY}-briefing.md"
git commit -m "${TODAY} briefing"
git push origin main
```

認証は Windows 資格情報マネージャーに保存済みのものを使う。push 後の Jekyll ビルドは GitHub Actions が行う。
**push 成功後、当日の `drafts/tmp/` 下書きを削除する**（公開済み下書きの残骸を溜めない。gitignore 対象のためローカル削除のみ）。

### Step 6: 実行ログの記録

```bash
LOG="drafts/logs/briefing.log"
mkdir -p "$(dirname "$LOG")"
echo "[$(date '+%Y-%m-%d %H:%M JST')] ${TODAY} briefing — SUCCESS" >> "$LOG"
```

スキップ時は `— SKIPPED (already exists)`、中断時は `— ABORTED (理由)`。ログは gitignore 対象で commit 不要。

## ルール（正本への参照）

- 出力形式・📖詳しく読む・⭐今日の1本: `TEMPLATE.md`
- 選定・分類・鮮度・カテゴリ境界: `SELECTION_RULES.md`
- 採用可能ソースの限定リスト: `SOURCES.md`
- コミュニティ反応（任意）: Hacker News スレッド等の個別URLで確認し、「補足:」「コミュニティ反応:」明示。単独で事実断定しない

## 参照ファイル

- `SOURCES.md` - ソース定義（カテゴリ・件数・URL）
- `TEMPLATE.md` - 出力テンプレート
- `SELECTION_RULES.md` - 選定・分類の正本
- `DENYLIST.md` - NGドメイン・NGパターン（check.sh が機械照合）
- `CHECKLIST.md` - 保存前の人手判断項目
- `RUNBOOK.md` - フォールバック手順・障害時対応・旧環境アーカイブ
