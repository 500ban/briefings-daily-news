# デイリーブリーフィング

このリポジトリは、個人向けのデイリーニュースブリーフィングを生成し、GitHub Pages で公開するための土台です。

日々の実行主体は Claude Cowork scheduled task です。Cowork が必要に応じて `last30days-skill` を候補発見・コミュニティ反応確認の補助として使い、既存の主要信頼ソースで事実確認したうえで、6カテゴリに分類し、日本語の Markdown ブリーフィングを生成して `_posts/` に保存し、`git commit && git push` まで担当します。

GitHub Actions は push 後の Jekyll build / GitHub Pages deploy だけを担当します。ニュース収集・分類・要約の主体にはしません。

## この repo の役割分担

- `cowork/`
  Cowork が参照する運用知識です。`SKILL.md` `SOURCES.md` `TEMPLATE.md` `RUNBOOK.md` と、補助ルールを配置します。
- `_posts/`
  本番公開するデイリーブリーフィングの保存先です。成果物は `YYYY-MM-DD-briefing.md` で置きます。
- `drafts/tmp/`
  下書きや確認用の一時ファイル置き場です。未完成の原稿を直接 `_posts/` に置かないために使います。
- `docs/`
  背景設計、技術検証、調査メモをまとめる場所です。運用の一次参照は `cowork/` と `CLAUDE.md` を優先します。
- `.github/workflows/deploy.yml`
  GitHub Pages 向けの deploy 専用 workflow です。収集処理や要約処理は入れません。

## 運用イメージ

1. Claude Cowork scheduled task がこのリポジトリを開く
2. `cowork/SKILL.md` `cowork/SOURCES.md` `cowork/TEMPLATE.md` を参照する
3. `last30days-skill` で候補トピックや反応量を補助的に確認する
4. 既存の主要信頼ソースを Web検索で収集・裏取りし、6カテゴリに整理する
5. 日本語の Markdown ブリーフィングを作り、`_posts/YYYY-MM-DD-briefing.md` に保存する
6. 差分確認後に `git commit && git push` を行う
7. push を受けて GitHub Actions が Jekyll build と GitHub Pages deploy を行う

`last30days-skill` はこのリポジトリに vendoring せず、外部 skill として利用します。Reddit / Hacker News / GitHub / YouTube / X などの反応は、通常ニュース本文と混ぜず「補足」または「コミュニティ反応」として扱います。

## 参照優先順

迷った場合は次を優先します。

1. `CLAUDE.md`
2. `cowork/SKILL.md`
3. `cowork/SOURCES.md`
4. `cowork/TEMPLATE.md`
5. `cowork/RUNBOOK.md`
6. `cowork/SELECTION_RULES.md`
7. `cowork/CHECKLIST.md`
8. `docs/` 配下の背景資料

`docs/deep-research-report.md` には代替案や周辺調査も含まれますが、この repo の正式な日次運用ルールは `CLAUDE.md` と `cowork/` を基準にします。
