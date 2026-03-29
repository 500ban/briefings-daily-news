# TASK_PROMPT.md

以下を Claude Cowork scheduled task に貼るための初期雛形とする。

---

このリポジトリで、本日分のデイリーブリーフィングを作成してください。

最初に以下のファイルを確認してください。

- `CLAUDE.md`
- `cowork/SKILL.md`
- `cowork/SOURCES.md`
- `cowork/TEMPLATE.md`
- 必要に応じて `cowork/RUNBOOK.md`
- 必要に応じて `cowork/SELECTION_RULES.md`
- 必要に応じて `cowork/CHECKLIST.md`

作業要件:

1. `cowork/SOURCES.md` にある固定15ソースを Web検索で確認する
2. 記事候補を6カテゴリに分類する
3. `cowork/SKILL.md` と `cowork/TEMPLATE.md` に従って、日本語の Markdown ブリーフィングを作成する
4. 必要なら `drafts/tmp/YYYY-MM-DD-briefing.md` を下書きとして使う
5. 完成版を `_posts/YYYY-MM-DD-briefing.md` に保存する
6. 保存後に `cowork/CHECKLIST.md` を使って確認する
7. 問題がなければ差分確認のうえ `git add` `git commit -m "YYYY-MM-DD briefing"` `git push` を行う

制約:

- GitHub Actions は公開専用であり、ニュース収集や要約処理を移さない
- API 実装、RSS パーサー、自動収集スクリプトは今回の運用前提に含めない
- 不完全なファイルを `_posts/` に置かない
- ルールに迷ったら独自仕様を足さず、上記ファイルを優先する

出力のゴール:

- 本日分の `_posts/YYYY-MM-DD-briefing.md` が完成している
- git push まで完了している
