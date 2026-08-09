---
layout: default
title: デイリーブリーフィング
---

{% assign latest_post = site.posts.first %}

{% if latest_post %}
<section class="home-section">
  <div class="section-heading">
    <p class="section-kicker">最新号</p>
    <h2>まずは今日のブリーフィングから。</h2>
    <p>その日の重要トピックを、読み切れる分量で一覧できます。</p>
  </div>
  <a class="feature-brief" href="{{ latest_post.url | relative_url }}">
    <div class="feature-brief-top">
      <p class="feature-date">{{ latest_post.date | date: "%Y-%m-%d" }}</p>
      <span class="feature-chip">最新</span>
    </div>
    <h3>{{ latest_post.title | remove_first: "📅 " }}</h3>
    <p>AI、ビジネス、国内技術、開発組織・キャリア、セキュリティまで、固定6カテゴリで追えます。</p>
    <span class="feature-link">最新号を開く</span>
  </a>
</section>
{% endif %}

<section id="archive" class="home-section">
  <div class="section-heading">
    <p class="section-kicker">アーカイブ</p>
    <h2>公開済みブリーフィング</h2>
    <p>新しい順に並んでいます。</p>
  </div>
  {% if site.posts.size > 0 %}
  {% assign wdays = "日,月,火,水,木,金,土" | split: "," %}
  {% assign posts_by_month = site.posts | group_by_exp: "post", "post.date | date: '%Y年%-m月'" %}
  <div class="archive-months">
    {% for month in posts_by_month %}
    <section class="archive-month">
      <h3 class="archive-month-label">{{ month.name }}<span class="archive-month-count">{{ month.items | size }}本</span></h3>
      <ol class="archive-days">
        {% for post in month.items %}
        {% assign w = post.date | date: "%w" | plus: 0 %}
        <li>
          <a class="archive-day" href="{{ post.url | relative_url }}" title="{{ post.date | date: '%Y-%m-%d' }} のブリーフィング">
            <span class="archive-day-num">{{ post.date | date: "%-d" }}</span>
            <span class="archive-day-dow">{{ wdays[w] }}</span>
          </a>
        </li>
        {% endfor %}
      </ol>
    </section>
    {% endfor %}
  </div>
  {% else %}
  <p class="empty-state">まだ公開済みのブリーフィングはありません。最初の公開分がここに並びます。</p>
  {% endif %}
</section>
