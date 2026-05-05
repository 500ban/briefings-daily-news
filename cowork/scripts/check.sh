#!/usr/bin/env bash
# cowork/scripts/check.sh
# ブリーフィング下書き/正式版の機械検証スクリプト
#
# Usage:
#   bash cowork/scripts/check.sh drafts/tmp/2026-04-05-briefing.md
#   bash cowork/scripts/check.sh _posts/2026-04-05-briefing.md
#
# 検証内容:
#   1. ソース照合（SOURCES.md 主要信頼ソース / 反応補助ソース）
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
warn() { echo "WARN: $1" >&2; }

# -----------------------------------------------------------------------------
# 定義: SOURCES.md の主要信頼ソース / 反応補助ソース
# -----------------------------------------------------------------------------
PRIMARY_SOURCES=(
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

REACTION_SOURCES=(
  reddit.com
  old.reddit.com
  github.com
  youtube.com
  youtu.be
  x.com
  twitter.com
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
# 結果
# -----------------------------------------------------------------------------
if [ $FAILED -eq 0 ]; then
  echo "PASS"
  exit 0
else
  echo "FAIL (see errors above)" >&2
  exit 1
fi
