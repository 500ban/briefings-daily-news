#!/usr/bin/env bash
# cowork/scripts/check.sh
# ブリーフィング下書き/正式版の機械検証スクリプト
#
# Usage:
#   bash cowork/scripts/check.sh drafts/tmp/2026-04-05-briefing.md
#   bash cowork/scripts/check.sh _posts/2026-04-05-briefing.md
#
# 検証内容:
#   0. 構造検証（front matter 日付一致 / サマリー6カテゴリの固定順 / 件数整合 / 鮮度7日以内
#      / 📖詳しく読むの200字以内・最大3文）
#   1. ソース照合（SOURCES.md を直接パースして主要信頼ソース / 反応補助ソースを判定）
#   2. DENYLIST ドメイン照合（DENYLIST.md を直接パース。読込失敗時は exit 2 で停止）
#   3. 個別記事URL パターン検証（一覧・ランキング・タグ等を検出）
#   4. クロス日重複（他の _posts/*.md と URL の重複を検出）
#   5. 評価語チェック（DENYLIST.md の「NG評価語」をパースして WARN）
#
# 出力:
#   PASS → 全検証合格。exit 0
#   FAIL → 1件以上失敗。理由を stderr に列挙して exit 1
#
# NOTE:
#   - 鮮度（7日以内）は各記事の <!-- pub:YYYY-MM-DD --> マーカー（TEMPLATE.md 準拠）を
#     基準日（front matter / ファイル名の日付）と突き合わせてオフライン検証する。
#     マーカーが無い場合は WARN にとどめる（移行期。安定後に FAIL へ昇格予定）。
#   - 元記事リンクの死活（URLが生きているか）は、ネット取得が必要なため本スクリプトでは検証しない。
#   - URL の抽出は Markdown リンク `→ [text](url)` 形式と生URLの両方をカバー。
#   - 構造検証は TEMPLATE.md の出力フォーマットを前提とする。フォーマットを変えたら
#     本スクリプトの構造検証セクションも合わせて更新すること。

set -u

DRAFT="${1:-}"
if [ -z "$DRAFT" ]; then
  echo "Usage: bash cowork/scripts/check.sh <draft-file>" >&2
  exit 2
fi
if [ ! -f "$DRAFT" ]; then
  echo "FAIL: file not found: $DRAFT" >&2
  exit 1
fi

FAILED=0
fail() { echo "FAIL: $1" >&2; FAILED=1; }
warn() { echo "WARN: $1" >&2; }

# -----------------------------------------------------------------------------
# 0. 構造検証（オフライン・TEMPLATE.md 準拠を前提）
# -----------------------------------------------------------------------------
# 0-1. front matter の date がファイル名の日付と一致するか
FNAME_DATE=$(basename "$DRAFT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
FM_DATE=$(grep -m1 '^date:' "$DRAFT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
if [ -z "$FM_DATE" ]; then
  fail "front matter に date がありません"
elif [ -n "$FNAME_DATE" ] && [ "$FM_DATE" != "$FNAME_DATE" ]; then
  fail "front matter の date ($FM_DATE) がファイル名の日付 ($FNAME_DATE) と一致しません"
fi

# 0-2. サマリーの6カテゴリ見出しが固定順で揃っているか
EXPECTED_CATS=$(printf '%s\n' \
  "📰 ビジネス・経済" \
  "🤖 AI最新動向" \
  "🚀 新サービス・ローンチ" \
  "🇯🇵 国内技術・ツール" \
  "📋 EM/PM" \
  "🔒 セキュリティ")
ACTUAL_CATS=$(grep -oE '^\*\*[^*]+\*\*' "$DRAFT" \
  | sed -E 's/^\*\*//; s/\*\*$//' \
  | grep -E '(📰|🤖|🚀|🇯🇵|📋|🔒)')
if [ "$ACTUAL_CATS" != "$EXPECTED_CATS" ]; then
  fail "サマリーの6カテゴリ見出しが固定順（ビジネス→AI→新サービス→国内技術→EM/PM→セキュリティ）で揃っていません"
fi

# 0-3. 件数整合: 各カテゴリ details の （N件） == 直下の記事バレット(^- **)数
COUNT_REPORT=$(awk '
  function emit() {
    if (cat == "") return
    if (has_cnt && decl+0 != cnt) print "MISMATCH\t" line "\t" cat "\t" decl "\t" cnt
    else if (!has_cnt)           print "NOCOUNT\t"  line "\t" cat
  }
  /^<summary>(📰|🤖|🚀|🇯🇵|📋|🔒)/ {
    emit()
    cat=$0; line=NR; cnt=0
    has_cnt = ($0 ~ /（[0-9]+件）/) ? 1 : 0
    decl=$0; gsub(/[^0-9]/, "", decl)
    next
  }
  /^- \*\*/ { if (cat != "") cnt++ }
  END { emit() }
' "$DRAFT")
if [ -n "$COUNT_REPORT" ]; then
  while IFS=$'\t' read -r kind line cat decl cnt; do
    [ -z "$kind" ] && continue
    case "$kind" in
      MISMATCH) fail "件数不一致(L$line): $cat 表記=${decl}件 実記事数=${cnt}件" ;;
      NOCOUNT)  warn "件数表記なしのカテゴリブロック(L$line): $cat — 「本日の更新なし」は details セクションを省略するのが原則" ;;
    esac
  done <<< "$COUNT_REPORT"
fi

# 0-4. 鮮度検証（オフライン）: 記事の公開日マーカー <!-- pub:YYYY-MM-DD --> が
#      基準日（front matter / ファイル名の日付）から7日以内か。
#      マーカーは TEMPLATE.md の形式に従い各記事リンク行末に付与する。
BASE_DATE="${FM_DATE:-$FNAME_DATE}"
PUB_DATES=$(grep -oE '<!--[[:space:]]*pub:[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*-->' "$DRAFT" \
  | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
LINK_COUNT=$(grep -cE '^[[:space:]]*→ \[' "$DRAFT")
if [ -z "$PUB_DATES" ]; then
  if [ "${LINK_COUNT:-0}" -gt 0 ]; then
    warn "公開日マーカー(<!-- pub:YYYY-MM-DD -->)が無いため鮮度を機械検証できません（移行期はWARN。TEMPLATE.md 参照）"
  fi
else
  base_epoch=$(date -d "$BASE_DATE" +%s 2>/dev/null || echo "")
  if [ -z "$base_epoch" ]; then
    warn "基準日を解釈できず鮮度検証をスキップ: $BASE_DATE"
  else
    PUB_COUNT=0
    while IFS= read -r pd; do
      [ -z "$pd" ] && continue
      PUB_COUNT=$((PUB_COUNT + 1))
      pe=$(date -d "$pd" +%s 2>/dev/null || echo "")
      if [ -z "$pe" ]; then
        fail "公開日マーカーの日付が不正: $pd"
        continue
      fi
      diff_days=$(( (base_epoch - pe) / 86400 ))
      if [ "$diff_days" -gt 7 ]; then
        fail "鮮度逸脱: 記事公開日 $pd は基準日 $BASE_DATE から ${diff_days}日前（7日超）"
      elif [ "$diff_days" -lt 0 ]; then
        fail "公開日が基準日より未来: $pd（基準日 $BASE_DATE）"
      fi
    done <<< "$PUB_DATES"
    if [ "${LINK_COUNT:-0}" -gt 0 ] && [ "$PUB_COUNT" -lt "$LINK_COUNT" ]; then
      warn "公開日マーカーが一部記事で欠落の可能性（記事リンク ${LINK_COUNT} / マーカー ${PUB_COUNT}）"
    fi
  fi
fi

# 0-5. 📖詳しく読むブロック検証: 本文200字以内・最大3文（TEMPLATE.md「厳守」）
#      文字数は空白除去後。awk がバイトモードの場合はバイト数/3 で近似する
#      （ダイジェスト本文はほぼ日本語＝3バイト/字のため。BEGIN の ratio で自動判定）。
#      文数は「。」の個数で数える。ロケールは環境既定のまま使う
#      （LC_ALL の明示指定は環境にないロケール名だと絵文字を含む行のマッチが壊れるため避ける）。
DIGEST_REPORT=$(awk '
  BEGIN { ratio = (length("あ") == 1) ? 1 : 3 }
  function emit(  text, chars, sents) {
    text = body
    gsub(/[ \t\r]/, "", text)
    chars = int(length(text) / ratio)
    sents = gsub(/。/, "。", text)
    if (chars > 200) printf "CHARS\t%d\t%d\n", start, chars
    if (sents > 3)   printf "SENT\t%d\t%d\n",  start, sents
    body = ""
  }
  /<details><summary>.*詳しく読む<\/summary>/ {
    inblk = 1; start = NR; body = $0
    sub(/.*詳しく読む<\/summary>/, "", body)
    if (body ~ /<\/details>/) { sub(/<\/details>.*/, "", body); inblk = 0; emit() }
    next
  }
  inblk {
    line = $0
    if (line ~ /<\/details>/) { sub(/<\/details>.*/, "", line); body = body line; inblk = 0; emit(); next }
    body = body line
  }
' "$DRAFT")
if [ -n "$DIGEST_REPORT" ]; then
  while IFS=$'\t' read -r kind line val; do
    [ -z "$kind" ] && continue
    case "$kind" in
      CHARS) fail "📖詳しく読む 文字数超過(L$line): 約${val}字（上限200字・TEMPLATE.md）" ;;
      SENT)  fail "📖詳しく読む 文数超過(L$line): ${val}文（上限3文・TEMPLATE.md）" ;;
    esac
  done <<< "$DIGEST_REPORT"
fi

# -----------------------------------------------------------------------------
# 定義の読み込み（単一の正: SOURCES.md / DENYLIST.md から動的に生成）
# -----------------------------------------------------------------------------
# ハードコードを廃し、SOURCES.md（主要信頼ソース/反応補助ソース）と
# DENYLIST.md（NGドメイン）を直接パースして配列を構築する。
# パース失敗時は「黙って素通し」を避けるため、番兵チェックで exit 2（設定エラー）で止める。
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
SOURCES_MD="$SCRIPT_DIR/../SOURCES.md"
DENYLIST_MD="$SCRIPT_DIR/../DENYLIST.md"

# SOURCES.md のテーブルURL列（最終データ列）からドメインを抽出。パスは除去。
# region=primary は「## 反応・補助ソース」より前、reaction はそれ以降のテーブル。
parse_sources() {
  local file="$1" want="$2"
  [ -f "$file" ] || return 0
  awk -v want="$want" '
    /^## 反応・補助ソース/ { sect="reaction"; next }
    /^## / { if (sect != "reaction") sect="primary" }
    /^\|/ {
      n = split($0, a, "|")
      url = a[n-1]
      gsub(/^[ \t]+|[ \t]+$/, "", url)
      if (url ~ /^[a-z0-9.-]+\.[a-z][a-z]+(\/.*)?$/) {
        sub(/\/.*$/, "", url)
        if (sect == want) print url
      }
    }
  ' "$file" | sort -u
}

# DENYLIST.md の「NGドメイン」セクションのバッククォート囲みドメインを抽出。
parse_denylist() {
  local file="$1"
  [ -f "$file" ] || return 0
  awk '/^## NGドメイン/{f=1; next} /^## /{f=0} f' "$file" \
    | grep -oE '`[a-z0-9.-]+\.[a-z][a-z]+`' | tr -d '`' | sort -u
}

mapfile -t PRIMARY_SOURCES  < <(parse_sources  "$SOURCES_MD" primary)
mapfile -t REACTION_SOURCES < <(parse_sources  "$SOURCES_MD" reaction)
mapfile -t DENYLIST         < <(parse_denylist "$DENYLIST_MD")

# 番兵チェック: パース崩れ/ファイル移動を検知したら設定エラーで停止（exit 2）。
# 黙ってソース定義外を素通しさせない安全装置。
contains() { local x; for x in "${@:2}"; do [ "$x" = "$1" ] && return 0; done; return 1; }
if ! contains nikkei.com "${PRIMARY_SOURCES[@]}" \
   || ! contains thehackernews.com "${PRIMARY_SOURCES[@]}" \
   || ! contains reddit.com "${REACTION_SOURCES[@]}" \
   || ! contains bloomberg.com "${DENYLIST[@]}"; then
  echo "FAIL: ソース定義の読み込みに失敗しました（SOURCES.md / DENYLIST.md の形式・場所を確認）" >&2
  echo "  読込結果: PRIMARY=${#PRIMARY_SOURCES[@]} REACTION=${#REACTION_SOURCES[@]} DENY=${#DENYLIST[@]}" >&2
  exit 2
fi

domain_matches() {
  local domain="$1"
  local allowed="$2"
  case "$domain" in
    "$allowed"|*".$allowed") return 0 ;;
    *) return 1 ;;
  esac
}

is_primary_source() {
  local domain="$1"
  local src
  for src in "${PRIMARY_SOURCES[@]}"; do
    domain_matches "$domain" "$src" && return 0
  done
  return 1
}

is_reaction_source() {
  local domain="$1"
  local src
  for src in "${REACTION_SOURCES[@]}"; do
    domain_matches "$domain" "$src" && return 0
  done
  return 1
}

# -----------------------------------------------------------------------------
# URL 抽出
# -----------------------------------------------------------------------------
URLS=$(grep -oE 'https?://[^)[:space:]]+' "$DRAFT" | sed 's/[.,;]*$//' | sort -u)

if [ -z "$URLS" ]; then
  echo "FAIL: no URLs found in draft" >&2
  exit 1
fi

# -----------------------------------------------------------------------------
# 1. ソース照合 & 2. DENYLIST照合
# -----------------------------------------------------------------------------
while IFS= read -r url; do
  [ -z "$url" ] && continue
  domain=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|' | sed 's|^www\.||')

  for dl in "${DENYLIST[@]}"; do
    domain_matches "$domain" "$dl" && fail "DENYLISTドメイン: $url"
  done

  if is_primary_source "$domain"; then
    continue
  fi

  if is_reaction_source "$domain"; then
    warn "反応補助ソース（補足/コミュニティ反応として手動確認）: $url"
    continue
  fi

  fail "ソース定義外ドメイン($domain): $url"
done <<< "$URLS"

# -----------------------------------------------------------------------------
# 3. 個別記事URL パターン検証
# -----------------------------------------------------------------------------
while IFS= read -r url; do
  [ -z "$url" ] && continue

  # Anthropic 一覧
  case "$url" in
    https://www.anthropic.com/news|https://www.anthropic.com/news/|\
https://anthropic.com/news|https://anthropic.com/news/|\
https://www.anthropic.com/engineering|https://www.anthropic.com/engineering/)
      fail "一覧ページURL(Anthropic): $url" ;;
  esac

  # OpenAI 一覧
  case "$url" in
    https://openai.com/blog|https://openai.com/blog/|\
https://openai.com/news|https://openai.com/news/|\
https://openai.com/index|https://openai.com/index/)
      fail "一覧ページURL(OpenAI): $url" ;;
  esac

  # Product Hunt ランキング
  case "$url" in
    *producthunt.com/leaderboard*) fail "ランキングURL(ProductHunt): $url" ;;
  esac

  # Reddit 一覧・検索・サブレディットトップ
  case "$url" in
    https://reddit.com|https://reddit.com/|\
https://www.reddit.com|https://www.reddit.com/|\
https://old.reddit.com|https://old.reddit.com/)
      fail "RedditトップURL: $url" ;;
    *reddit.com/r/*)
      case "$url" in
        *"/comments/"*) ;;
        *) fail "Reddit一覧URL（個別comments URLではない）: $url" ;;
      esac ;;
  esac

  # GitHub は repo トップではなく issue/discussion/pull/release/commit 等に限定
  case "$url" in
    https://github.com|https://github.com/)
      fail "GitHubトップURL: $url" ;;
    https://github.com/*/*)
      case "$url" in
        *"/issues/"*|*"/discussions/"*|*"/pull/"*|*"/releases/"*|*"/commit/"*|*"/compare/"*|*"/blob/"*)
          ;;
        *) fail "GitHubリポジトリトップURL（個別ページではない）: $url" ;;
      esac ;;
  esac

  # YouTube は個別動画URLに限定
  case "$url" in
    https://youtube.com|https://youtube.com/|\
https://www.youtube.com|https://www.youtube.com/|\
*youtube.com/@*|*youtube.com/channel/*|*youtube.com/c/*|*youtube.com/results*)
      fail "YouTube一覧/チャンネルURL: $url" ;;
    *youtube.com/watch*)
      case "$url" in
        *"v="*) ;;
        *) fail "YouTube動画IDなしURL: $url" ;;
      esac ;;
  esac

  # X / Twitter は個別投稿に限定
  case "$url" in
    https://x.com|https://x.com/|https://twitter.com|https://twitter.com/)
      fail "X/TwitterトップURL: $url" ;;
    https://x.com/*|https://twitter.com/*)
      case "$url" in
        *"/status/"*) ;;
        *) fail "X/TwitterプロフィールURL（個別投稿ではない）: $url" ;;
      esac ;;
  esac

  # タグ・カテゴリ・検索
  case "$url" in
    *"/tag/"*|*"/category/"*|*"/topics/"*|*"/search?"*|*"/?s="*|*"/search/"*)
      fail "タグ/カテゴリ/検索URL: $url" ;;
  esac

  # Hacker News トップ
  case "$url" in
    https://news.ycombinator.com|https://news.ycombinator.com/|\
https://news.ycombinator.com/news|https://news.ycombinator.com/newest)
      fail "HNトップURL: $url" ;;
  esac

  # ドメイン直下（スキーム+ドメインのみ）
  if echo "$url" | grep -qE '^https?://[^/]+/?$'; then
    fail "ドメイン直下URL: $url"
  fi
done <<< "$URLS"

# -----------------------------------------------------------------------------
# 4. クロス日重複チェック
# -----------------------------------------------------------------------------
# ドラフトのファイル名から日付を抽出（自身を除外するため）
DRAFT_BASENAME=$(basename "$DRAFT")
TODAY=$(echo "$DRAFT_BASENAME" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

# リポジトリルートを特定
REPO_ROOT=$(cd "$(dirname "$DRAFT")" && git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -z "$REPO_ROOT" ]; then
  # git 外の場合: ドラフトの親2階層を推定
  REPO_ROOT=$(cd "$(dirname "$DRAFT")/.." && pwd)
fi
POSTS_DIR="$REPO_ROOT/_posts"

if [ -d "$POSTS_DIR" ]; then
  # 自分自身のファイル名を除外してURLを集める
  POSTED=$(
    find "$POSTS_DIR" -type f -name "*.md" ! -name "${TODAY}-briefing.md" 2>/dev/null \
      | xargs -r grep -hoE 'https?://[^)[:space:]]+' 2>/dev/null \
      | sed 's/[.,;]*$//' \
      | sort -u
  )

  if [ -n "$POSTED" ]; then
    DUPES=$(comm -12 <(echo "$URLS") <(echo "$POSTED"))
    if [ -n "$DUPES" ]; then
      while IFS= read -r u; do
        [ -n "$u" ] && fail "クロス日重複(過去の_postsと同一URL): $u"
      done <<< "$DUPES"
    fi
  fi
else
  echo "WARN: _posts ディレクトリが見つかりません: $POSTS_DIR" >&2
fi

# -----------------------------------------------------------------------------
# 5. 評価語チェック（WARN）: 事実ベース原則（TEMPLATE.md）に反しやすい表現を検出
# -----------------------------------------------------------------------------
# DENYLIST.md の「## NG評価語」セクションのバッククォート囲み語をパースして検出する。
# 「重大な脆弱性（Critical訳）」「IPAが推奨（帰属あり）」など正当な用例があるため
# FAIL にはせず WARN にとどめ、保存前に文脈を手動確認する。
NG_EXPR=$(awk '/^## NG評価語/{f=1; next} /^## /{f=0} f' "$DENYLIST_MD" \
  | grep -oE '`[^`]+`' | tr -d '`' | paste -sd'|' -)
if [ -n "$NG_EXPR" ]; then
  while IFS= read -r hit; do
    [ -n "$hit" ] && warn "評価語の疑い（文脈を手動確認）: $hit"
  done < <(grep -nE "$NG_EXPR" "$DRAFT")
fi

# -----------------------------------------------------------------------------
# 過去URLキャッシュの更新（次回の収集で使う）
# -----------------------------------------------------------------------------
# PASS / FAIL に関係なく、_posts 配下の URL を `cowork/cache/past_urls.txt` に
# 常時保存しておく。Cowork の Step 1.5 サブエージェントが、収集した候補から
# このファイルにあるURLを `comm -23` で除外できるようにするための事前計算。
if [ -d "$POSTS_DIR" ]; then
  CACHE_DIR="$REPO_ROOT/cowork/cache"
  mkdir -p "$CACHE_DIR"
  find "$POSTS_DIR" -type f -name "*.md" 2>/dev/null \
    | xargs -r grep -hoE 'https?://[^)[:space:]]+' 2>/dev/null \
    | sed 's/[.,;]*$//' \
    | sort -u > "$CACHE_DIR/past_urls.txt"
fi

# -----------------------------------------------------------------------------
# 結果
# -----------------------------------------------------------------------------
if [ $FAILED -eq 0 ]; then
  echo "PASS"
  exit 0
else
  echo "FAIL (see errors above)" >&2
  exit 1
fi
