---
layout: default
title: デイリーブリーフィング
---

# デイリーブリーフィング

このサイトでは、Claude Cowork が生成して GitHub Pages に公開した日次ブリーフィングを一覧します。

{% if site.posts.size > 0 %}
## 最新記事

{% for post in site.posts %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%Y-%m-%d" }}
{% endfor %}
{% else %}
まだ公開済みのブリーフィングはありません。最初の `_posts/YYYY-MM-DD-briefing.md` が追加されると、ここに一覧が表示されます。
{% endif %}
