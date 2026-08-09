# CLAUDE.md

## このリポジトリの目的

個人向けデイリーニュースブリーフィングを生成し、GitHub Pages で公開する。
毎朝の生成はローカルの Claude Code スケジュールタスク（`daily-news-briefing`）が行う：

1. 主要信頼ソースを Web検索で収集・裏取り（サブエージェント実行）
2. 6カテゴリに分類し日本語で要約 → `_posts/YYYY-MM-DD-briefing.md` に保存
3. `git commit && git push`（Jekyll ビルドと Pages 反映は GitHub Actions が担当）

ニュース収集・要約・分類を GitHub Actions では行わない。

## 最優先ルール

- 毎日のブリーフィング生成は `cowork/SKILL.md` のワークフローに従う
- **正本の分担**: 選定・分類・鮮度・カテゴリ境界＝`cowork/SELECTION_RULES.md` /
  ソース限定リスト＝`cowork/SOURCES.md` / 出力形式（📖詳しく読む・⭐今日の1本含む）＝`cowork/TEMPLATE.md`
- 下書きは `drafts/tmp/`、`cowork/scripts/check.sh` の **PASS 後のみ** `_posts/` へ保存する
- 不完全なファイルを `_posts/` に置かない。公開対象を壊さないことを最優先する
- ルールに迷ったら、推測で独自仕様を増やさず既存ファイルを優先する

## カテゴリ（順序固定）

1. ビジネス・経済
2. AI最新動向
3. 新サービス・ローンチ
4. 国内技術・ツール
5. 開発組織・キャリア
6. セキュリティ

AI関連は原則「AI最新動向」、AI×ビジネス（資金調達・規制等）は「ビジネス・経済」でもよい（二重掲載不可）。
件数レンジは上限目安。満たせない場合は無理に埋めず「本日の更新なし」とする。

## 生成の基本原則

- 全文日本語・事実ベース・1記事1〜2文要約・元記事リンクと `<!-- pub:YYYY-MM-DD -->` マーカー必須
- 反応補助ソース（HN/Reddit/GitHub/YouTube/X）は「補足:」「コミュニティ反応:」明示。単独で事実を断定しない
- 全文転載しない。1週間より古い記事・過去掲載URLは採用しない
- 詳細な選定・記述ルールは正本ファイル参照（本ファイルに再掲しない）

## ファイル・Git運用

- 公開記事は `_posts/YYYY-MM-DD-briefing.md` のみ。既存記事の上書きは日付をよく確認する
- レイアウト・GitHub Actions ファイルは明示的な依頼がない限り変更しない。不要なファイル削除はしない
- commit message は `YYYY-MM-DD briefing`。check.sh 未通過・エラー時は中途半端な commit/push をしない

## 参照ファイル

- `cowork/SKILL.md` — ワークフロー
- `cowork/SOURCES.md` — ソース定義（check.sh のパース元）
- `cowork/TEMPLATE.md` — 出力テンプレート
- `cowork/SELECTION_RULES.md` — 選定・分類の正本
- `cowork/CHECKLIST.md` — 保存前の人手判断
- `cowork/RUNBOOK.md` — フォールバック・障害時・旧環境アーカイブ

## 避けること

- GitHub Actions をニュース収集主体にしない / API 実装前提に設計を書き換えない
- `_posts/` に未完成原稿を置かない / カテゴリ順・テンプレートを勝手に変えない
- 有料記事の全文・長文転載をしない
