# WEEKLY_FACTCHECK.md

過去1週間に公開したブリーフィングの「高リスクな事実主張」を出典と照合し、
**明確な誤りだけを対象箇所のみ修正**する週次ジョブの手順書。

日次の生成・公開は従来どおり（`SKILL.md` / `RUNBOOK.md`）。本ジョブはそれと独立した
**週次の事後監査＋補修**であり、公開ゲート（`check.sh`）の代替ではない。

---

## 目的と方針

- 日次の `check.sh` は構造・鮮度・ソース・重複を機械検証するが、**digest 内の数値や
  固有名詞が出典と一致するか**は検証できない（2026-06-10 に資金額の誤りと CEO 名の
  捏造が発生した実績がある）。本ジョブがその層を事後に補う。
- **公開→修正に時間差が出る**（最大7日）ことを許容する設計。日次の予防ルールは入れない。
- 自動修正は**高信頼の明確な誤りに限定**し、**該当箇所だけ**を最小編集する。曖昧なものは
  直さずレポートに残す。

## 実行頻度

- **週1回**（推奨: 毎週日曜の午前）。Cowork scheduled task として登録する（末尾「スケジュール設定」）。

## スコープ（フィルタ強度=現行/最も網羅）

- 検証対象は `cowork/scripts/extract_claims.sh` が抽出した**高リスク記事のみ**。
- 現行＝**金額（億/万/兆 ドル・円）・パーセント・件数（件/人/社/台/名/株/カ国）・CVE-ID・CVSS**
  を含む記事。数値を含むニュースを広くカバーする。
- 実測の目安: **約39記事/週**（全約71記事中）。コスト概算 月〜0.5〜0.6M tokens。
- コストを下げたい場合は `extract_claims.sh` の `RISK` から件数系を外す（厳しめ＝約25記事/週）。

---

## 手順

### Step 0: リポジトリ準備
`RUNBOOK.md` Step 0 と同様に `/tmp/repos/` で作業（`git clone --depth` または `pull --rebase`）。

### Step 1: 高リスク記事の抽出（オフライン）
```bash
cd /tmp/repos/briefings-daily-news
bash cowork/scripts/extract_claims.sh     # 引数なし=直近7日を自動選択
```
出力(TSV): `<file>\t<source_url>\t<行番号>\t<該当行>`。`SUMMARY` 行で対象記事数を確認する。

### Step 2: 出典との照合
抽出された記事ごとに、その `source_url`（および必要なら記事タイトルでの Web 検索）で出典を取得し、
**digest 全体（数値だけでなく人名・社名・製品名も）**を突き合わせる。
- 取得は Web検索 / WebFetch を基本とし、使えない場合は `RUNBOOK.md` Step 2.6 の
  Chrome MCP フォールバックを用いる。
- 抽出は「どの記事を見るか」の絞り込み。**見るときは記事の digest を丸ごと確認**する
  （固有名詞の捏造は抽出器では拾えないため）。

### Step 3: 判定（3分類）
各記事の各主張を次に分類する。
- **OK**: 出典と一致。
- **WRONG**: 出典が明確に矛盾（数値違い・存在しない人物/社名など）。**かつ正しい値が出典から確定できる**。
- **UNCERTAIN**: 出典が取得できない／曖昧で確定できない。

### Step 4: 修正（対象箇所のみ・WRONG のみ）
- **WRONG と判定した箇所だけ**を、`_posts/<日付>-briefing.md` 上で最小編集する。
  - 例: 「ARR2.5億ドル」→ 出典の「ARR4億ドル」に置換。捏造された一文は削除または訂正。
- **記事や digest を丸ごと書き直さない。** OK / UNCERTAIN は触らない。
- UNCERTAIN はレポートに「要手動確認」として残す（自動では直さない）。

### Step 5: 構造の再検証
修正したファイルごとに `check.sh` を実行し、`PASS`（構造・鮮度・ソース・重複が壊れていない）を確認する。
```bash
bash cowork/scripts/check.sh _posts/<修正した日付>-briefing.md
```

### Step 6: レポート記録
`drafts/logs/factcheck/` に週次レポートを残す（VMリセット後も残るワークスペース側にも記録）。
- ファイル名: `drafts/logs/factcheck/YYYY-Www.md`
- 内容: 対象記事数、各記事の判定（OK/WRONG/UNCERTAIN）、修正した箇所の before→after、UNCERTAIN一覧。

### Step 7: commit & push（変更があれば）
```bash
git pull --rebase origin main
git add _posts/ drafts/logs/factcheck/
git commit -m "weekly factcheck YYYY-Www"
git push origin main
```
WRONG がゼロなら `_posts/` は無変更。レポートのみ commit してよい。push 後に GitHub Actions が再ビルドする。

---

## 修正ルール（安全側）

- **直すのは「明確な誤り」かつ「正しい値が出典で確定できる」場合のみ。**
- **該当箇所だけ**を最小編集する（blast radius を最小化）。
- 出典が取れない・判断が割れるものは**直さずレポート**（推測で書き換えない）。
- 記事の削除はしない（誤りは訂正、捏造文は該当文のみ削除）。
- 修正後は必ず `check.sh` で PASS を確認してから commit する。

## 避けること

- 公開ゲートとして使わない（日次の `check.sh` が引き続き公開前検証を担う）。
- digest の全面リライト・トーン変更。
- フィルタ対象外（件数のみ等）の記事を無理に検証してコストを膨らませること。
- UNCERTAIN を「たぶん正しい/誤り」と推測で確定すること。

---

## スケジュール設定（Cowork scheduled task）

日次タスクと同様に、週次の scheduled task を作成し、タスクプロンプトに以下を据える。

> このリポジトリ（briefings-daily-news）で `cowork/WEEKLY_FACTCHECK.md` に従い、
> 過去7日のブリーフィングの高リスク事実主張を出典と照合し、明確な誤りのみ該当箇所を
> 修正して、週次レポートを `drafts/logs/factcheck/` に記録し、変更があれば commit & push する。

頻度: 毎週日曜 09:00 JST（例）。
