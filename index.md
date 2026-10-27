---
layout: default
title: デイリーブリーフィング
---

{% assign latest_post = site.posts.first %}
{% assign wdays = "日,月,火,水,木,金,土" | split: "," %}

{% if latest_post %}
{% assign d = latest_post.date | date: "%Y-%m-%d" %}
{% assign w = latest_post.date | date: "%w" | plus: 0 %}
{% assign pick_path = "/assets/img/picks/" | append: d | append: ".jpg" %}
{% assign pick_img = site.static_files | where: "path", pick_path | first %}
<article class="post post-home">
  <div class="post-frame">
    <header class="post-header post-header-compact">
      <p class="post-kicker">最新号</p>
      <h1 class="post-title-date"><a href="{{ latest_post.url | relative_url }}">{{ d }}<span class="post-title-wday">（{{ wdays[w] }}）</span></a></h1>
    </header>
    {% if pick_img %}
    <figure class="pick-figure"><img src="{{ pick_path | relative_url }}" alt="今日の1本のイメージ" loading="lazy"></figure>
    {% endif %}
    <div class="post-body">
{{ latest_post.content }}
    </div>
    <nav class="post-nav" aria-label="前後の号">
      {% if latest_post.previous %}
      <a class="post-nav-link post-nav-prev" href="{{ latest_post.previous.url | relative_url }}">
        <span class="post-nav-label">← 前号</span>
        <span class="post-nav-date">{{ latest_post.previous.date | date: "%Y-%m-%d" }}</span>
      </a>
      {% else %}
      <span class="post-nav-spacer" aria-hidden="true"></span>
      {% endif %}
      <a class="post-nav-home" href="#archive">一覧</a>
      <a class="post-nav-link post-nav-next" href="{{ latest_post.url | relative_url }}">
        <span class="post-nav-label">この号のページ →</span>
        <span class="post-nav-date">{{ d }}</span>
      </a>
    </nav>
  </div>
</article>
{% endif %}

<section id="archive" class="home-section">
  <div class="section-heading">
    <p class="section-kicker">アーカイブ</p>
    <h2>公開済みブリーフィング</h2>
    <p>新しい順に並んでいます。</p>
  </div>
  {% if site.posts.size > 0 %}
  {% assign posts_by_month = site.posts | group_by_exp: "post", "post.date | date: '%Y年%-m月'" %}
  <div class="archive-months">
    {% for month in posts_by_month %}
    <section class="archive-month">
      <h3 class="archive-month-label">{{ month.name }}<span class="archive-month-count">{{ month.items | size }}本</span></h3>
      <ol class="archive-days">
        {% for post in month.items %}
        {% assign pw = post.date | date: "%w" | plus: 0 %}
        <li>
          <a class="archive-day" href="{{ post.url | relative_url }}" title="{{ post.date | date: '%Y-%m-%d' }} のブリーフィング">
            <span class="archive-day-num">{{ post.date | date: "%-d" }}</span>
            <span class="archive-day-dow">{{ wdays[pw] }}</span>
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
