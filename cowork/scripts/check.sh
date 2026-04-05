#!/usr/bin/env bash
# cowork/scripts/check.sh
# ブリーフィング下書き/正式版の機械検証スクリプト
#
# Usage:
#   bash cowork/scripts/check.sh drafts/tmp/2026-04-05-briefing.md
#   bash cowork/scripts/check.sh _posts/2026-04-05-briefing.md
#
# 検証内容:
#   1. ソース照合（SOURCES.md ホワイトリスト）
#   2. DENYLIST ドメイン照合
#   3. 個別記事URL パターン検証（一覧・ランキング・タグ等を検出）
#   4. クロス日重複（他の _posts/*.md と URL の重複を検出）
#
# 出力:
#   PASS → 全検証合格。exit 0
#   FAIL → 1件以上失敗。理由を stderr に列挙して exit 1
#
# NOTE:
#   - 7日以内ルール（鮮度）は元ページの公開日を必要とするため本スクリプトでは検証しない。
#     Cowork 側が収集段階で判断する。
#   - URL の抽出は Markdown リンク `→ [text](url)` 形式と生URLの両方をカバー。

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

# -----------------------------------------------------------------------------
# 定義: ホワイトリスト（SOURCES.md の15エントリ、ユニーク14ドメイン）
# -----------------------------------------------------------------------------
WHITELIST=(
  nikkei.com
  newspicks.com
  reuters.com
  techcrunch.com
  openai.com
  research.google
  anthropic.com
  news.ycombinator.com
  producthunt.com
  dev.classmethod.jp
  forest.watch.impress.co.jp
  leaddev.com
  thehackernews.com
  ipa.go.jp
)

# DENYLIST ドメイン（DENYLIST.md と同期）
DENYLIST=(
  cybernews.com
  fortune.com
  theregister.com
  news.crunchbase.com
  bloomberg.com
  markets.financialcontent.com
)

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

  # DENYLIST 先判定
  for dl in "${DENYLIST[@]}"; do
    case "$domain" in
      "$dl"|*".$dl") fail "DENYLISTドメイン: $url";;
    esac
  done

  # ホワイトリスト判定
  ok=0
  for wl in "${WHITELIST[@]}"; do
    case "$domain" in
      "$wl"|*".$wl") ok=1; break;;
    esac
  done
  [ $ok -eq 0 ] && fail "ソース定義外ドメイン($domain): $url"
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

  # タグ・カテゴリ・検索
  case "$url" in
    *"/tag/"*|*"/category/"*|*"/topics/"*|*"/search?"*|*"/?s="*)
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
# 結果
# -----------------------------------------------------------------------------
if [ $FAILED -eq 0 ]; then
  echo "PASS"
  exit 0
else
  echo "FAIL (see errors above)" >&2
  exit 1
fi
