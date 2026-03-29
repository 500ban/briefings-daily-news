# AGENTS.md

## この repo で Codex が守ること

- この repo は Claude Cowork 主体のデイリーブリーフィング運用を前提とする
- 日々の収集・分類・要約・Markdown 生成・`git push` は Cowork 側の役割として尊重する
- GitHub Actions は Jekyll build / GitHub Pages deploy のみを担当し、ニュース収集主体にしない
- API ベース設計や RSS パーサー中心の設計へ勝手に書き換えない
- 今回の基盤整備では scaffold のみを作成し、ニュース収集ロジック・要約ロジック・自動収集スクリプトは実装しない
- 既存の `cowork/*.md` と `CLAUDE.md` を優先し、迷ったら独自仕様を増やさない
- 背景資料の `docs/*.md` は参考情報として扱い、運用ルールの上書きに使わない
- `_posts/` は本番成果物の置き場であり、未完成ファイルや検証途中の原稿を直接置かない
- `drafts/tmp/` は下書き用として使い、本番公開との差分を分ける
- 公開サイトを壊さないことを優先し、レイアウト・workflow・公開導線の変更は最小限にする

## 変更時の実務ルール

- 既存方針を変える変更は、明示的な依頼がない限り行わない
- `cowork/SKILL.md` `cowork/SOURCES.md` `cowork/TEMPLATE.md` の整合を崩さない
- カテゴリ順は固定する
- ブリーフィングの正式出力先は必ず `_posts/YYYY-MM-DD-briefing.md` とする
- 日本語で読んで自然な説明とドキュメントを保つ
- 意図しない差分を混ぜない

## 優先順位

この repo 内で判断に迷う場合の優先順位は以下とする。

1. ユーザーの明示的な依頼
2. `CLAUDE.md`
3. `cowork/SKILL.md`
4. `cowork/SOURCES.md`
5. `cowork/TEMPLATE.md`
6. `cowork/RUNBOOK.md`
7. `cowork/SELECTION_RULES.md`
8. `cowork/CHECKLIST.md`
9. `docs/` 配下の背景資料
