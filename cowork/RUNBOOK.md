# RUNBOOK.md

## 目的

この Runbook は、Claude Cowork が毎朝のデイリーブリーフィングを安定して生成し、
`_posts/` に保存して `git push` するための実行手順をまとめたものです。

このファイルは、実行時の具体的な進め方を定義します。
記事のカテゴリやテンプレートの仕様そのものは、以下を参照してください。

- `cowork/SKILL.md`
- `cowork/SOURCES.md`
- `cowork/TEMPLATE.md`
- `cowork/SELECTION_RULES.md`
- `cowork/CHECKLIST.md`
- `cowork/RUNBOOK.md`

---

## 実行前提

- このリポジトリはローカルに clone 済みである
- Claude Desktop / Cowork が起動している
- scheduled task がこのリポジトリを対象に実行される
- GitHub Pages 公開用の Git リポジトリとして正しく初期化されている
- push 可能な Git 設定が済んでいる

---

## 毎朝の実行フロー

### 1. 参照ファイルを確認する

最初に以下を確認する。

- `cowork/SKILL.md`
- `cowork/SOURCES.md`
- `cowork/TEMPLATE.md`
- `cowork/RUNBOOK.md`
- `cowork/SELECTION_RULES.md`
- `cowork/CHECKLIST.md`
- `cowork/DENYLIST.md`

ルールが曖昧なときは、独自判断で仕様を増やさず既存ファイルを優先する。

---

### 1.5. 過去の掲載URLを把握しておく（★重複防止）

収集の**前**に、直近の `_posts/*.md` に目を通し、**前日以前に掲載済みの記事URLを本日の候補から除外する**方針を徹底する。

- 収集時点で候補URLが既に `_posts/*.md` に存在する場合は採用しない
- 同じ話題でも別URLなら採用可だが、新しい事実が加わっていることを要約で明示する
- 最終的な機械検証は Step 6 の `cowork/scripts/check.sh` が担当するため、ここでは人間（モデル）判断で早めに弾く

背景: 過去の監査で、前日と完全に同じ記事URLが複数カテゴリで重複掲載される事故が13件発生したため、
このステップを必須化する。

---

### 2. last30days で候補トピックを発見する（補助）

利用可能な環境では、`last30days-skill` を発見エンジンとして使い、直近30日の反応量・現場感・新しい論点を拾う。

基本方針:
- `last30days-skill` は主要信頼ソースを置き換えない
- Reddit / Hacker News / GitHub / YouTube / X などは、候補発見と反応確認のために使う
- 有料APIキーやブラウザトークンを必須にしない。無料・低設定で使える範囲を優先する
- 反応補助ソースだけで通常ニュース本文の事実を断定しない

カテゴリ別の例:
- AI: `AI model releases`, `AI coding tools`, `LLM agents`
- 新サービス: `developer tools launched`, `Product Hunt developer tools`, `Show HN`
- セキュリティ: `security vulnerabilities`, `supply chain attacks`
- EM/PM: `engineering management`, `product management AI`

扱い:
- 裏取りできた候補は通常ニュースとして採用候補にする
- 裏取りできないが有用な反応は「コミュニティ反応」または「補足」として扱う
- 裏取りできず、反応としても薄いものは採用しない

---

### 2.5. 主要信頼ソースを Web検索で収集・裏取りする

`cowork/SOURCES.md` に定義された主要信頼ソースについて、
Web検索を使って直近1週間の最新記事候補を集める。Step 2 で見つけた候補も、通常ニュースにする場合は主要信頼ソース・公式情報・信頼媒体で裏取りする。

基本方針:
- 既存固有ソースを信頼できる事実確認・採用判定の軸として追う
- 取得は Web検索で統一する
- 各カテゴリの目標件数を意識する
- 英語ソースも含める
- 最新性と信頼性を優先する

注意:
- 1週間以上前の記事は除外する
- 同じ話題の重複記事は絞る
- 過去の `_posts/*.md` に既掲載のURLは採用しない（Step 1.5）
- `cowork/DENYLIST.md` のNGドメイン・NG URLパターンに該当する候補は最初から外す
- 有料記事は見出しと公開部分から判断し、全文前提で扱わない
- Reddit / GitHub / YouTube / X などの反応補助ソースは通常ニュース本文の裏取りリンクとして単独利用しない

---

### 2.6. WebSearch が利用できない時のフォールバック（Chrome MCP）

WebSearch がレート上限・障害などで使えない場合は、収集を諦めて中止するのではなく、以下の優先順で代替手段を試みる。

#### 優先順位

1. **Chrome MCP（`mcp__Claude_in_Chrome__*`）** — 最優先のフォールバック
2. `mcp__workspace__web_fetch` — 会話に URL が出現済みの場合のみ使える補助
3. `last30days-skill` — 候補トピック発見のための補助
4. それでも候補が集まらない場合のみ、`drafts/tmp/` で止め、`drafts/logs/briefing.log` に `ABORTED` を記録する

#### Chrome MCP フォールバック手順

1. `mcp__Claude_in_Chrome__list_connected_browsers` で接続済みブラウザを確認
   - 結果が空の場合、`switch_browser` で接続待機。それでも繋がらない場合は中止
2. `mcp__Claude_in_Chrome__select_browser` で deviceId を指定
3. `mcp__Claude_in_Chrome__tabs_context_mcp` で `createIfEmpty: true` を渡し作業用タブを作成
4. 各ソースの一覧ページ（例: `https://techcrunch.com/category/artificial-intelligence/`, `https://www.nikkei.com/`, `https://www.anthropic.com/news`, `https://openai.com/news/`, `https://thehackernews.com/`, `https://dev.classmethod.jp/`, `https://forest.watch.impress.co.jp/`, `https://leaddev.com/`, `https://news.ycombinator.com/show`, `https://www.producthunt.com/` 等）に `navigate` し、`javascript_tool` で個別記事 URL・見出し・日付を抽出する
5. 採用候補ごとに、必要なら個別記事へ `navigate` して `get_page_text` を取り、公開日と本文の要点を確認する
6. 以降は Step 3 以降（カテゴリ分類・要約・下書き）に通常どおり進む

#### 各ソースの URL 抽出パターン例

- **TechCrunch / Anthropic / OpenAI / LeadDev**: `document.querySelectorAll('a[href*="/2026/"]')` または `a[href*="/news/"], a[href*="/index/"]`
- **日経新聞**: `a[href*="/article/"]`（個別記事 ID パターン `DGXZQ...`）
- **The Hacker News**: `a[href*="thehackernews.com/2026/"]`
- **DevelopersIO**: `a[href*="/articles/"]`
- **窓の杜**: `a[href*="/docs/news/"]`, `a[href*="/docs/digest/"]`
- **Hacker News (Show HN)**: `tr.athing` を走査して `id` を取り、`https://news.ycombinator.com/item?id={id}` を URL とする
- **Product Hunt**: `a[href*="/products/"]`

#### Chrome MCP フォールバック時の制約

- 接続が必要なため、scheduled task では「ブラウザ未接続」で停止する可能性がある。その場合は無理に推測埋めをせず、`ABORTED` ログを書き、ユーザー再実行を待つ
- ブラウザは tier "read" のため、`navigate` と `javascript_tool` による DOM 読み取りはできるが、フォーム送信や追加クリックが必要なソース（ログインゲート等）は採用を諦める
- 取得した内容は AI 推定ではなく、ページ DOM に存在した事実のみを採用する。日付が DOM 上で確認できない記事は採用しない

#### ログ表記

- WebSearch を使った通常ルート → `briefing — SUCCESS`
- Chrome MCP フォールバック経由で完走 → `briefing — SUCCESS (via Chrome MCP)`
- どちらも不可で中止 → `briefing — ABORTED: <理由>`


### 3. 6カテゴリに分類する

カテゴリ順は固定。

1. ビジネス・経済
2. AI最新動向
3. 新サービス・ローンチ
4. 国内技術・ツール
5. EM/PM
6. セキュリティ

件数目安:
- ビジネス・経済: 3〜5本
- AI最新動向: 3〜5本
- 新サービス・ローンチ: 3〜5本
- 国内技術・ツール: 2〜3本
- EM/PM: 1〜2本（更新があれば）
- セキュリティ: 2〜3本

補足:
- カテゴリ振り分け（AI集約・AI×ビジネス境界・資金調達の扱い等）は `SELECTION_RULES.md`（正本）に従う
- 該当が薄い記事を無理に入れない

---

### 4. 日本語で要約する

各記事について以下を作る。

- 日本語の具体的な見出し
- 1〜2文の日本語要約
- 元記事リンク
- 各リンク行末尾の公開日マーカー `<!-- pub:YYYY-MM-DD -->`（check.sh が7日以内をオフライン検証。`TEMPLATE.md` 参照）

要約ルール:
- 事実ベース
- 簡潔
- 全文転載しない
- 誇張しない
- 推測を混ぜない
- 見出しは「〇〇について」のように曖昧にしない
- 反応補助ソースを使う場合は、`補足:` または `コミュニティ反応:` として通常ニュース本文から分ける

---

### 5. まず `drafts/tmp/` に下書きを作る

原則として、まず `drafts/tmp/` に下書きファイルを作る。
正式版を先に `_posts/` に置かない。

推奨ファイル名:
- `drafts/tmp/YYYY-MM-DD-briefing.md`

用途:
- テンプレ適用前の確認
- 記事の並び順調整
- details セクションの整合確認
- リンクの抜け漏れ確認

下書きで問題が解消したら、チェックを行ったうえで正式版を `_posts/` に作成する。

---

### 6. 下書きに対して保存前チェックを行う

`cowork/CHECKLIST.md` を使って、`drafts/tmp/` の下書き段階で確認する。

必須ルール:
- **最初に `cowork/scripts/check.sh` を実行し `PASS` を確認する**
  ```bash
  bash cowork/scripts/check.sh drafts/tmp/$(date +%Y-%m-%d)-briefing.md
  ```
  このスクリプトが以下を一括検証する：主要信頼ソース/反応補助ソース照合、DENYLIST照合、個別記事URL、クロス日重複
- スクリプトが `FAIL` を返した場合、`_posts/` に保存しない・`git add/commit/push` しない
- スクリプトが `WARN: 反応補助ソース` を返した場合、該当URLが反応欄・補足欄として妥当か手動確認する
- 問題が残る場合は `drafts/tmp/` のまま止め、修正後に再実行する
- スクリプトで検知できない項目（日本語の品質、7日以内ルール、details件数カウント整合、カテゴリ境界、反応欄の妥当性）は `cowork/CHECKLIST.md` の残り項目で手動確認する

---

### 7. チェック合格後のみ正式ファイルを `_posts/` に保存する

正式な保存先:
- `_posts/YYYY-MM-DD-briefing.md`

必須条件:
- front matter がある
- タイトルと日付が実行日に一致する
- カテゴリ順が固定順になっている
- 「今日のまとめ」がある
- details セクションが正しい
- 0件カテゴリは「本日の更新なし」をまとめに書き、details は省略する
- 反応補助ソースがある場合は、通常ニュース本文ではなく「補足」「コミュニティ反応」として区別されている

---

### 8. Git差分を確認する

以下を確認する。

- 変更対象が主に当日の `_posts/` である
- 意図しないファイル変更が混ざっていない
- レイアウトや workflow など公開基盤のファイルを誤って変えていない

問題がある場合は修正し、不要変更は commit しない。

---

### 9. commit / push する

下書きチェックに合格し、正式版が `_posts/` に保存されている場合のみ以下を行う。

1. `git status`
2. `git add`
3. `git commit -m "YYYY-MM-DD briefing"`
4. `git push`

原則:
- 差分がなければ commit しない
- エラー時は中途半端な状態で push しない
- push 成功まで確認する
- `cowork/CHECKLIST.md` に未解消項目がある場合は commit / push しない

---

### 10. 公開反映の前提

push 後は GitHub Actions が起動し、Jekyll をビルドして GitHub Pages に反映する。

この Runbook では、公開処理そのものは GitHub Actions 側に委ねる。
Cowork の役割は、調査・要約・Markdown 生成・git push まで。

---

## 失敗時の扱い

### ケース1: 十分な記事が集まらない
- 無理に埋めない
- 取得できた記事だけで構成する
- 必要なカテゴリには「本日の更新なし」を使う

### ケース2: 一部カテゴリだけ空振り
- そのカテゴリのみ「本日の更新なし」
- details セクションは省略する

### ケース3: リンクや構造に不安がある
- いったん `drafts/tmp/` に戻す
- `_posts/` の正式版を急いで更新しない

### ケース3b: checklist に1つでも失敗がある
- `_posts/` に保存しない
- `git add` `git commit` `git push` をしない
- `drafts/tmp/` の下書きを修正し、再チェックする

### ケース4: git push に失敗する
- エラーを確認する
- リトライ可能なら再試行する
- 中途半端な state のまま別ファイルを触らない

### ケース5: テンプレと実際の出力が衝突する
- `cowork/TEMPLATE.md` を優先する
- 迷う場合はテンプレ準拠に寄せる

---

## 1回の実行で達成すべきこと

- 当日のブリーフィング下書きが `drafts/tmp/` で確認されている
- `cowork/CHECKLIST.md` の項目を満たしたものだけが `_posts/YYYY-MM-DD-briefing.md` として保存されている
- 内容がテンプレート準拠である
- GitHub に push 済みである

---

## 達成しなくてよいこと

- 全ソースを完全網羅すること
- 毎回すべてのカテゴリで最大件数を満たすこと
- `last30days-skill` の全ソースを有効化すること
- 有料APIキーやブラウザトークンを必須にすること
- RSS/API 実装に切り替えること
- GitHub Actions 側の設計を変更すること

---

## 最後の判断基準

迷ったら次を優先する。

1. 公開ページを壊さない
2. 既存テンプレートを崩さない
3. 主要信頼ソースで事実を確認する
4. 事実ベースで簡潔に書く
5. 無理に埋めない
