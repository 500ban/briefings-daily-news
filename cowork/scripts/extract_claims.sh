#!/usr/bin/env bash
# cowork/scripts/extract_claims.sh
# 週次ファクトチェック（高リスク抽出）の前処理スクリプト。
#
# 目的:
#   公開済み _posts/*.md から「高リスクな事実主張」を含む記事ブロックだけを
#   オフラインで抽出し、検証対象を機械的に絞り込む。LLM による Web 照合は
#   ここで抽出された記事のみに対して行うことで、トークン消費を最小化する。
#
# 高リスク（フィルタ強度=現行/最も網羅）= 金額(億/万/兆 ドル・円)、パーセント、
#            件数(件/人/社/台/名/株/カ国)、CVE-ID、CVSS スコア。
#            数値の取り違え・捏造が起きやすい箇所を広くカバーする。
#   ※ 固有名詞(人名・社名)の捏造はオフラインでは判定できないため、抽出された
#      記事については LLM 側で本文(数値＋固有名詞)を出典と突き合わせること。
#
# Usage:
#   bash cowork/scripts/extract_claims.sh _posts/2026-06-15-briefing.md [...]
#   bash cowork/scripts/extract_claims.sh            # 直近7日を自動選択
#
# 出力(stdout, TSV): <file>\t<source_url>\t<行番号>\t<該当行>
# 出力(stderr): SUMMARY 行（対象記事数 / 全記事数 / 対象ファイル数）

set -u

# フィルタ強度=現行（金額/%/件数/CVE/CVSS、最も網羅）。コストを下げる場合は
# 件数系 (件|人|社|台|名|株|カ国|か国) を外す（厳しめ＝金額/%/CVE/CVSS）。
RISK='(CVE-[0-9][0-9][0-9][0-9]-[0-9]|CVSS *[0-9]|[0-9]%|[0-9０-９][0-9０-９,，.]*(億|万|兆)?(ドル|円|件|人|社|台|名|株|カ国|か国))'

FILES=("$@")
if [ "${#FILES[@]}" -eq 0 ]; then
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")
  mapfile -t FILES < <(ls "$REPO_ROOT"/_posts/*-briefing.md 2>/dev/null | tail -7)
fi
if [ "${#FILES[@]}" -eq 0 ]; then
  echo "ERROR: 対象ファイルがありません" >&2
  exit 2
fi

awk -v RISK="$RISK" '
  function flush(  i) {
    if (!inblock) return
    total++
    if (n > 0) {
      flagged++
      for (i = 1; i <= n; i++) print fname "\t" url "\t" lno[i] "\t" txt[i]
    }
    inblock = 0; n = 0; url = "-"
  }
  FNR == 1 { flush(); fname = FILENAME; files++ }
  /^- \*\*/ { flush(); inblock = 1; n = 0; url = "-" }
  /^</ { flush() }   # カテゴリ見出し<summary>や</details>等のHTML境界で記事ブロックを終端
  {
    if (inblock && $0 ~ /→ \[[^]]*\]\(https?:\/\//) {
      s = $0; sub(/^.*\]\(/, "", s); sub(/\).*$/, "", s); url = s
    }
    if (inblock && $0 ~ RISK) { n++; lno[n] = FNR; txt[n] = $0 }
  }
  END {
    flush()
    printf("SUMMARY: 対象記事=%d / 全記事=%d（全%dファイル）\n",
           flagged, total, files) > "/dev/stderr"
  }
' "${FILES[@]}"
