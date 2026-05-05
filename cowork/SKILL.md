---
name: daily-briefing-generator
description: "Generates a daily news briefing by using last30days as a discovery aid, validating facts against trusted sources across 6 categories (business, AI, new services, domestic tech, EM/PM, security), summarizing them in Japanese, and outputting a structured Markdown file with category summaries and collapsible details. Triggers when asked to create a daily briefing, morning news summary, or news digest."
---

# デイリーブリーフィング生成スキル

## 概要

毎朝のニュースブリーフィングを自動生成するスキル。既存の固有ソースを信頼できる事実確認・採用判定の軸として維持しつつ、外部の `last30days-skill` を発見エンジンとして補助利用する。直近の反応量・現場感・新しい論点を拾い、6カテゴリに分類・日本語要約してMarkdownファイルを出力し、GitHubへ自動pushする。

`last30days-skill` はこのリポジトリに vendoring しない。利用可能な環境では外部 skill として呼び出し、有料APIキーやブラウザトークンは必須にしない。

## ワークフロー

### Step 0: リポジトリの準備（/tmp/repos/ に shallow clone）

マウント先フォルダへのgit操作はロックファイル制約で失敗するため、必ず `/tmp/repos/` で作業する。

```bash
# .env からトークン読み込み
WORKSPACE="/sessions/bold-exciting-cori/mnt/デイリーニュース"
ENV_FILE="$WORKSPACE/.env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
fi

REPO="briefings-dairy-news"
OWNER="500ban"
WORK="/tmp/repos/$REPO"

# ディスク残量チェック（500MB 未満は中止）
FREE_MB=$(df /tmp --output=avail -m 2>/dev/null | tail -1 | tr -d ' ')
if [ "${FREE_MB:-0}" -lt 500 ]; then
  echo "⛔ ディスク残量不足: ${FREE_MB}MB — 中止"
  exit 1
fi

# shallow clone または pull
if [ -d "$WORK/.git" ]; then
  cd "$WORK"
  git pull --rebase origin main
else
  rm -rf "$WORK"
  git clone --depth 1 --branch main \
    "https://${GITHUB_TOKEN}@github.com/${OWNER}/${REPO}.git" "$WORK"
  cd "$WORK"
fi
```

### Step 1: last30days による候補トピック発見（補助）

利用可能な環境では、主要信頼ソース検索の前段または並行で `last30days-skill` を使い、各カテゴリの候補トピックを拾う。

目的:
- 公式ニュースや検索結果だけでは見えにくい、開発者・利用者コミュニティの反応量を把握する
- Reddit / Hacker News / GitHub / YouTube / X などで直近30日に議論されている論点を発見する
- 新サービス、AIツール、セキュリティ、EM/PM などで「実務上役に立つ」候補を増やす

例:
- AI: `AI model releases`, `AI coding tools`, `LLM agents`
- 新サービス: `developer tools launched`, `Product Hunt developer tools`, `Show HN`
- セキュリティ: `security vulnerabilities`, `supply chain attacks`
- EM/PM: `engineering management`, `product management AI`

注意:
- `last30days-skill` の結果は「発見・反応確認」のために使う
- 反応補助ソースだけで、通常ニュース本文の事実を断定しない
- 通常ニュースとして採用する場合は、Step 1.5 の主要信頼ソース・公式情報・信頼媒体で裏取りする
- 裏取りできないが有用な反応は、テンプレート上の「コミュニティ反応」として明示して掲載してよい

### Step 1.5: 主要信頼ソースでの最新記事収集・裏取り

SOURCES.md に定義された主要信頼ソースについて、Web検索で直近1週間の最新記事を収集する。`last30days-skill` で見つけた候補も、通常ニュースとして扱う場合はここで裏取りする。

- 各ソースにつき、サイト名を含む検索クエリを使用（例: `site:nikkei.com 最新ニュース`）
- 英語ソースの記事も収集対象に含める
- 各カテゴリの目標件数に達するまで収集する
- 1週間以上前の記事は除外する
- **過去の `_posts/*.md` に既掲載のURLは採用しない**（最終的に check.sh が機械検証する）
- `cowork/DENYLIST.md` のNGドメイン（`cybernews.com`, `fortune.com`, `theregister.com`, `news.crunchbase.com`, `bloomberg.com`, `markets.financialcontent.com` ほか）および NG URLパターン（`/news` トップ、`leaderboard/*`, `/tag/*` 等）は最初から除外する

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
- **コミュニティ反応（任意）**：反応補助ソースを使う場合は、事実ニュースと区別して「補足」または「コミュニティ反応」と明示する

### Step 4: ブリーフィング生成

TEMPLATE.md のフォーマットに従い、以下の構造でMarkdownファイルを生成する：

1. **🎯 今日のまとめ**（カテゴリごとに2〜3行の要約、常時表示）
2. **折りたたみ詳細**（`<details markdown="block">` で各カテゴリの全記事を格納）

まず `drafts/tmp/YYYY-MM-DD-briefing.md` に下書きを作る。

### Step 4.5: 機械検証（★必須）

下書きに対して `cowork/scripts/check.sh` を実行し、`PASS` を確認する。

```bash
cd /tmp/repos/briefings-dairy-news
bash cowork/scripts/check.sh drafts/tmp/$(date +%Y-%m-%d)-briefing.md
```

このスクリプトが以下を一括検証する：
- 主要信頼ソース / 反応補助ソース照合（SOURCES.md）
- 反応補助ソースの別枠許可と手動確認警告
- DENYLIST ドメイン・パターン照合
- 個別記事URL パターン（一覧・ランキング・タグ・HNトップを検出）
- クロス日重複（他の `_posts/*.md` との URL 重複）

`FAIL` が1つでもあれば下書きを修正して再実行する。`PASS` 後のみ `_posts/YYYY-MM-DD-briefing.md` へ正式保存する。

### Step 5: git commit & push

```bash
cd /tmp/repos/briefings-dairy-news

# push 前に必ず rebase（競合防止）
git pull --rebase origin main || {
  git checkout --theirs .
  git add .
  git rebase --continue
}

TODAY=$(date +%Y-%m-%d)
git add "_posts/${TODAY}-briefing.md"
git commit -m "${TODAY} briefing"
git push origin main
```

### Step 6: 実行ログの記録

実行結果をワークスペースフォルダに記録する（VMリセット後も残る）。

```bash
WORKSPACE="/sessions/bold-exciting-cori/mnt/デイリーニュース"
LOG="$WORKSPACE/drafts/logs/briefing.log"
mkdir -p "$(dirname "$LOG")"
echo "[$(date '+%Y-%m-%d %H:%M JST')] ${TODAY} briefing — SUCCESS" >> "$LOG"
```

## ルール

### 記述ルール
- **全文日本語**：英語ソースの記事も日本語で要約する
- **簡潔さ**：1記事あたり見出し＋1〜2文の要約に収める
- **リンク必須**：すべての記事に元記事URLを付与する
- **反応の明示**：Reddit / Hacker News / GitHub / YouTube / X などの反応は、通常ニュース本文と混ぜず「コミュニティ反応」または「補足」として書く

### 除外ルール
- AI関連のニュースは「🤖 AI最新動向」カテゴリに集約する。ただしAI × ビジネス（業界動向・規制・大型資金調達等）は「📰 ビジネス・経済」にも含めてよい
- 1週間以上前の古い記事は除外する
- 同じトピックの重複記事は最も情報量の多い1本に絞る
- **過去の `_posts/*.md` に既に掲載された URL は二度と採用しない**（Step 0.5 の除外リストで機械的に検査する）
- `cowork/SOURCES.md` の主要信頼ソース / 反応補助ソース外のドメインは件数埋めであっても採用しない
- ただし `cowork/SOURCES.md` の「反応・補助ソース」は、反応欄・補足欄に限り採用できる
- 反応補助ソースだけを根拠に、未確認の事実・数字・発表内容を通常ニュースとして断定しない
- 資金調達・IPO・M&A は「📰 ビジネス・経済」に入れる。「🚀 新サービス・ローンチ」は製品・サービスの新規公開に限定する

### 品質ルール
- 各カテゴリの最小件数を満たせない場合、無理に埋めず「本日の更新なし」と記載する
- 見出しは具体的に。「〇〇について」のような曖昧な見出しは避ける
- 要約は事実ベースで。意見や推測は含めない

## 参照ファイル

- `SOURCES.md` - ソース定義（15ソースの一覧、カテゴリ、URL）
- `TEMPLATE.md` - ブリーフィングのMarkdownテンプレート
- `DENYLIST.md` - 過去に混入したNGドメイン・NG URLパターンの逆引きリスト
- `CHECKLIST.md` - 保存前の検証項目（ソース照合・個別URL・7日以内・クロス日重複など）
