---
layout: default
title: デイリーブリーフィング
---

{% assign latest_post = site.posts.first %}

{% if latest_post %}
<section class="home-section">
  <div class="section-heading">
    <p class="section-kicker">Latest Issue</p>
    <h2>まずは今日のブリーフィングから。</h2>
    <p>その日の重要トピックを、読み切れる分量で一覧できます。</p>
  </div>
  <a class="feature-brief" href="{{ latest_post.url | relative_url }}">
    <div class="feature-brief-top">
      <p class="feature-date">{{ latest_post.date | date: "%Y-%m-%d" }}</p>
      <span class="feature-chip">Today</span>
    </div>
    <h3>{{ latest_post.title | remove_first: "📅 " }}</h3>
    <p>AI、ビジネス、国内技術、EM/PM、セキュリティまで、固定6カテゴリで追えます。</p>
    <span class="feature-link">最新号を開く</span>
  </a>
</section>
{% endif %}

<section id="archive" class="home-section">
  <div class="section-heading">
    <p class="section-kicker">Archive</p>
    <h2>公開済みブリーフィング</h2>
    <p>新しい順に並んでいます。</p>
  </div>
  {% if site.posts.size > 0 %}
  <ol class="brief-list">
    {% for post in site.posts %}
    <li>
      <a class="brief-item" href="{{ post.url | relative_url }}">
        <div>
          <p class="brief-item-date">{{ post.date | date: "%Y-%m-%d" }}</p>
          <h3>{{ post.title | remove_first: "📅 " }}</h3>
        </div>
        <span class="brief-item-arrow" aria-hidden="true">読む</span>
      </a>
    </li>
    {% endfor %}
  </ol>
  {% else %}
  <p class="empty-state">まだ公開済みのブリーフィングはありません。最初の issue が公開されると、ここに並びます。</p>
  {% endif %}
</section>
