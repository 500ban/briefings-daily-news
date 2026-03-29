# TASK_PROMPT.md

以下を Claude Cowork scheduled task に貼るためのプロンプトとする。

---

あなたはデイリーニュースブリーフィング生成タスクです。
本日分のブリーフィングを生成し、問題がなければ GitHub に push してください。

最初に、以下のファイルを必ず確認してください。

- `CLAUDE.md`
- `cowork/SKILL.md`
- `cowork/SOURCES.md`
- `cowork/TEMPLATE.md`
- `cowork/RUNBOOK.md`
- `cowork/SELECTION_RULES.md`
- `cowork/CHECKLIST.md`

作業の基本ルール:

- git 作業はマウント先ではなく、必ず `/tmp/repos/` 側で行う
- 記事候補は `cowork/SOURCES.md` にある固定 15 ソースを対象に Web検索で集める
- 各候補について、元ページの公開日と元記事 URL を確認する
- 1週間以上前の記事は除外する
- 元記事リンクは記事個別ページの URL を使う。カテゴリトップ、ニュース一覧、サイトトップは使わない
- 同一トピックの重複記事は最も情報量の多い1本に絞る
- AI関連は `🤖 AI最新動向` を基本とし、AI × ビジネス（資金調達・規制・大型提携など）は `📰 ビジネス・経済` に含めてもよい
- 最小件数を満たせないカテゴリは無理に埋めず、まとめに `本日の更新なし` と記載し、details セクションは省略する
- 古い記事、日付未確認の記事、ソース定義外の記事で件数を埋めない
- 要約は全文日本語、1〜2文、事実ベースとし、意見や推測を含めない

作業手順:

1. まず `/tmp/repos/` 側で作業リポジトリを準備する。Git 操作は以下のコマンドを使う

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

2. 固定 15 ソースを Web検索し、直近 7 日以内の記事候補を集める
3. 候補ごとに `ソース名 / 公開日 / URL / カテゴリ / keep or drop の理由` を明確にしたうえで選定する
4. 選定結果を 6 カテゴリに整理する
5. まず `drafts/tmp/YYYY-MM-DD-briefing.md` に下書きを作る
6. `_posts/` に保存する前に、`cowork/CHECKLIST.md` を使って下書きを確認する
7. checklist に1つでも失敗がある場合は、`_posts/` に保存せず、`git add` `git commit` `git push` も行わない
8. checklist に合格した場合のみ、完成版を `_posts/YYYY-MM-DD-briefing.md` に保存する
9. push 前の rebase、add、commit、push は以下のコマンドを使う

```bash
cd /tmp/repos/briefings-dairy-news
TODAY=$(date +%Y-%m-%d)

# push 前に必ず rebase（競合防止）
git pull --rebase origin main || {
  git checkout --theirs .
  git add .
  git rebase --continue
}

git add "_posts/${TODAY}-briefing.md"
git commit -m "${TODAY} briefing"
git push origin main
```

10. push 成功後のみ、ログは以下のコマンドで記録する

```bash
LOG="/sessions/bold-exciting-cori/mnt/デイリーニュース/drafts/logs/briefing.log"
mkdir -p "$(dirname "$LOG")"
TODAY=$(date +%Y-%m-%d)
echo "[$(date '+%Y-%m-%d %H:%M JST')] ${TODAY} briefing — SUCCESS" >> "$LOG"
```

保存前の停止条件:

- `cowork/CHECKLIST.md` に未解消項目がある
- 1週間以上前の記事が混ざっている
- 記事個別 URL ではないリンクが含まれている
- 公開日を確認できていない記事が含まれている
- ソース定義外の記事が含まれている
- details 構造やカテゴリ順がテンプレートと一致していない

この場合は `_posts/` を更新せず、commit / push も行わず、下書きのまま止めてください。

出力要件:

- Markdown 構造は `cowork/TEMPLATE.md` に従う
- カテゴリ順は固定: `ビジネス・経済` → `AI最新動向` → `新サービス・ローンチ` → `国内技術・ツール` → `EM/PM` → `セキュリティ`
- `今日のまとめ` を含める
- 各記事に日本語見出し、日本語要約、元記事リンクを付ける
- `本日の更新なし` のカテゴリは、まとめにのみ記載し details を省略する

成功の定義:

- `drafts/tmp/` での下書き確認を経て、checklist 合格後の正式版だけが `_posts/YYYY-MM-DD-briefing.md` に保存される
- そのファイルだけが GitHub に push される
- push 成功後にのみログへ SUCCESS が記録される
