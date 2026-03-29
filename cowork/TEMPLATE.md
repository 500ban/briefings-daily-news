# ブリーフィングテンプレート

生成するMarkdownファイルは以下のフォーマットに従うこと。

```markdown
---
title: "📅 YYYY-MM-DD デイリーブリーフィング"
date: YYYY-MM-DD
layout: post
---

## 🎯 今日のまとめ

**📰 ビジネス・経済**
（このカテゴリの記事を2〜3行で要約）

**🤖 AI最新動向**
（このカテゴリの記事を2〜3行で要約）

**🚀 新サービス・ローンチ**
（このカテゴリの記事を2〜3行で要約）

**🇯🇵 国内技術・ツール**
（このカテゴリの記事を2〜3行で要約）

**📋 EM/PM**
（このカテゴリの記事を2〜3行で要約。更新がなければ「本日の更新なし」）

**🔒 セキュリティ**
（このカテゴリの記事を2〜3行で要約）

---

<details markdown="block">
<summary>📰 ビジネス・経済（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>

<details markdown="block">
<summary>🤖 AI最新動向（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>

<details markdown="block">
<summary>📋 EM/PM（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>

<details markdown="block">
<summary>🔒 セキュリティ（N件）</summary>

- **記事見出し**
  1行要約。
  → [ソース名](https://example.com/article-url)

</details>
```

## テンプレートルール

- `YYYY-MM-DD` は実行日の日付に置換する
- `N件` は各カテゴリの実際の記事数に置換する
- カテゴリ内に該当記事がない場合、まとめに「本日の更新なし」と記載し、detailsセクションは省略する
- カテゴリの順序は固定：ビジネス → AI → 新サービス → 国内技術 → EM/PM → セキュリティ
- リンクは必ずMarkdown形式 `[ソース名](URL)` で記述する。素のURL（`https://...` のみ）は `<details>` ブロック内でクリックできないため使用禁止
