# TASK_PROMPT.md

Cowork の Scheduled Tasks の本文に貼る、毎朝のブリーフィング生成プロンプト。

---

## Cowork UI に貼る本文（短縮版）

以下の3行をそのまま Scheduled Tasks の本文に貼る。

```
このリポジトリの CLAUDE.md と cowork/SKILL.md に従い、本日分のデイリーニュース
ブリーフィングを生成して GitHub に push してください。
git 作業は /tmp/work/briefings-dairy-news で行ってください。
```

これ以上のことは書かない。手順・bashコード・ルールはすべて `cowork/SKILL.md` 側に
集約されているため、scheduled task 本文にコピーする必要はない。

---

## 設計メモ

過去は本ファイルに6KB以上の手順を書き、それを毎朝 scheduled task 本文として送信
していた。`cowork/SKILL.md` と内容が約7割重複し、毎朝1500トークン前後を浪費して
いたため、3行版に短縮した。

scheduled task は次のような流れで動く想定：

1. Cowork が3行プロンプトを Claude に送信
2. Claude は `CLAUDE.md`（imported_knowledge で常時注入）と `cowork/SKILL.md` を読む
3. `cowork/SKILL.md` の Step 0〜6 に従って実行する
4. Step 1.5 は必ず `general-purpose` サブエージェントで WebSearch を回す
5. `cowork/scripts/check.sh` で PASS を確認してから `_posts/` に保存し push する

詳細は `cowork/SKILL.md` を参照。
