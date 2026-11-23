---
title: "📅 2026-11-23 デイリーブリーフィング（muse トライアル）"
date: 2026-11-23
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
医療画像ソフトMONAI LabelのゼロデイCVE-2026-133968 — 自律AIエージェントが見つけた欠陥で大学サーバーのroot権限が奪われ、修正版がまだ提供されていないため。（→ 🔒 セキュリティを参照）

**📰 ビジネス・経済**
SBエナジーの2026年1〜9月期の最終損益は約3050億円の赤字となり、ナスダック上場に向け目論見書を更新した。日商の調査では、中小企業の賃上げは平均4.52%で、約6割が人手不足対応の防衛的なものだった。

**🤖 AI最新動向**
SignalがOS統合のAIエージェントによる画面スキャンを理由に、モバイルアプリでのスクリーンショットを制限した。OpenAIのチーフサイエンティストがAI開発の速度制限の共通指標としてパープレキシティを提案し、小島秀夫氏はAIが創作の喜びを奪う恐れがあると語った。

**🚀 新サービス・ローンチ**
DOS上で動くAIコーディングエージェントClawDOS、ランタイムやGCなしでC#を使えるZero C#、mod_wsgi作者によるPythonアプリ向けRust製サーバーMuruが公開された。

**🇯🇵 国内技術・ツール**
AWS Agent Registryで、確認済みドメインに紐づけたレコードを組織外へ公開できるようになった。

**📋 開発組織・キャリア**
FinのCTOが、AIでR&Dの生産性を2倍にした際の文化とマインドセットの転換を語る講演動画が公開された。

**🔒 セキュリティ**
医療画像ソフトMONAI Labelのゼロデイ脆弱性CVE-2026-133968が公表され、CVSS 9.8が付いた。修正版はまだ提供されておらず、認証の有効化やネットワークの遮断が求められている。

---

<details markdown="block">
<summary>📰 ビジネス・経済（2件）</summary>

- **SBエナジー、1〜9月の最終赤字3050億円　上場に向け目論見書を更新**
  2026年1〜9月期の最終損益は19億1370万ドル（約3050億円）の赤字で、ワラント負債の減少により1〜6月期から約2000億円改善した。ナスダック上場に向け19日に目論見書を更新したが、上場日や公開価格は開示しなかった。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUC203260Q6A121C2000000/) <!-- pub:2026-11-20 -->

- **中小企業、賃上げ4.52%　「防衛的」6割も**
  日本商工会議所の調査で、今年度の中小企業の賃上げは9月時点でベアと定期昇給を合わせて3月比で平均4.52%上昇した。約6割の企業が人手不足への対応を目的とした防衛的な賃上げだった。
  → [NewsPicks](https://newspicks.com/news/17932518/) <!-- pub:2026-11-17 -->

</details>

<details markdown="block">
<summary>🤖 AI最新動向（3件）</summary>

- **Signal、AI監視の「実存的脅威」に対抗しモバイルのスクリーンショットを制限**
  SignalはOS統合のAIエージェントが画面をスキャンする問題を受け、モバイルアプリでのスクリーンショットを制限すると発表した。Windowsアプリでは既定で制限しており、AndroidとiOSにも広げる。利用者は設定で無効化できるが、その場合はプライバシー保証が崩れるとしている。
  → [TechCrunch](https://techcrunch.com/2026/11/21/signal-restricts-mobile-screenshots-as-it-confronts-existential-threat-of-ai-surveillance/) <!-- pub:2026-11-21 -->
  <details><summary>📖 詳しく読む</summary>
  OS統合のAIエージェントが画面の情報を読み取り、端末内や外部サーバーに保存する仕組みが、Signalのプライバシー保証を損なうとメレディス・ウィテカー社長が説明した。Windows版では既定でスクリーンショットをブロックしており、AndroidとiOSにも同様の制限を加える。設定で無効化できるが、ウィテカー氏は不完全な対策だと認めている。
  </details>

- **OpenAIのチーフサイエンティスト、AI開発の制限にパープレキシティを提案**
  OpenAIのチーフサイエンティスト、ヤクブ・パチョッキ氏が、AI開発の速度制限の共通指標としてパープレキシティを提案するブログを公開した。サム・アルトマンCEOはこの投稿を「OpenAIが最近公開した中で最も重要なもの」と評した。
  → [TechCrunch](https://techcrunch.com/2026/11/22/openais-chief-scientist-has-thoughts-on-how-to-limit-ai-development/) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  パープレキシティはモデルが次のトークンをどれだけ正確に予測できるかの指標で、値が低いほど予測が良い。GPT-4のパープレキシティは約0.91で、損失が0.8を下回ってからサイバーセキュリティや数学で変革的な能力が現れたとしている。企業は共通のしきい値を設け、監視能力が一定の水準に達するまでそれを超えないと約束する案だ。
  </details>

- **AIはビジネスに有益だが創作の喜びを奪う恐れ、ゲームクリエイター小島秀夫氏**
  ゲームクリエイターの小島秀夫氏が、日経創立150周年のイベントで、AIはビジネスには有益だが人々を受動的な消費者にし、創作の喜びを奪う恐れがあると語った。映画監督の押井守氏も同席し、AIが想像力のある仕事に与える影響を論じた。
  → [日経新聞](https://asia.nikkei.com/business/media-entertainment/ai-good-for-business-but-may-sap-joy-of-creation-game-creator-hideo-kojima) <!-- pub:2026-11-22 -->

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（3件）</summary>

- **ClawDOS、DOS上で動くAIコーディングエージェント**
  DOS上で動くAIコーディングエージェント「ClawDOS」が公開された。
  → [Hacker News](https://news.ycombinator.com/item?id=50586292) <!-- pub:2026-11-21 -->
  <details><summary>📖 詳しく読む</summary>
  DOS上で動くAIコーディングエージェントで、作者のサイトで公開された。HNでは古い端末での利用をめぐる議論が集まった。
  </details>

- **Zero C#、ランタイムやGCなしでC#を使える実装**
  ランタイムやガベージコレクション（GC）なしでC#を使える「Zero C#」が公開された。メモリ管理にアリーナを使い、既存の標準ライブラリには対応しない。
  → [Hacker News](https://news.ycombinator.com/item?id=50590279) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  C#をランタイムやGCなしで使う試みで、アリーナによるメモリ管理を採用する。既存のプログラムや標準ライブラリはそのまま使えず、メモリを手動で管理する前提の実装となっている。
  </details>

- **Muru、mod_wsgi作者によるPythonアプリ向けRust製サーバー**
  mod_wsgiの作者が、Pythonアプリ向けのRust製サーバー「Muru」を公開した。アプリを事前に読み込んでからワーカーをフォークする仕組みで、AIの支援を受けて作られた。
  → [Hacker News](https://news.ycombinator.com/item?id=50597959) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  Pythonアプリ向けのRust製サーバーで、アプリを事前に読み込んでワーカーをフォークする。AndroidのZygoteに似た仕組みで、ユーザーごとのワーカー分離にも応用できるとの指摘がある。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（1件）</summary>

- **AWS Agent Registry、ドメインに紐づけたレコードを組織外へ公開可能に**
  2026年11月20日に、AWS Agent Registryで確認済みのドメインをレコードに結び付け、組織の外へ公開できるようになった。公開したレコードは別のAWSアカウントからも検索でき、追加料金はなく、Registryが使える全リージョンで利用できる。
  → [DevelopersIO](https://dev.classmethod.jp/articles/aws-agent-registry-public-discovery/) <!-- pub:2026-11-22 -->

</details>

<details markdown="block">
<summary>📋 開発組織・キャリア（1件）</summary>

- **AIでR&D生産性を2倍に、FinのCTOが語る文化とマインドセットの転換**
  FinのCTOが、AIでR&Dの生産性を2倍にした際の文化とマインドセットの転換を語る講演動画が公開された。1日に数百回のデプロイを数千のホストとクラスタで回す体制を率いる立場から、速度と品質の両立を論じている。
  → [LeadDev](https://zephrcf.leaddev.com/leadership/acceleration-with-ai) <!-- pub:2026-11-17 -->
  <details><summary>📖 詳しく読む</summary>
  FinのCTOが、AIでR&Dの生産性を2倍にした取り組みを語る。1日に数百回のデプロイを数千のホストとクラスタで回す体制を率いており、文化とマインドセットの転換が中心の内容となっている。
  </details>

</details>

<details markdown="block">
<summary>🔒 セキュリティ（1件）</summary>

- **医療画像ソフトMONAI Labelのゼロデイ、AIエージェントが発見し大学サーバーでroot権限を奪取**
  中国系とみられる攻撃者が自律AIエージェントを使い、医療画像ソフトMONAI Labelの未知の欠陥を見つけ、大学のサーバーでroot権限を奪ったとAmazon Threat Intelligenceが報告した。欠陥はCVE-2026-133968でCVSSは9.8、修正はソースコードに取り込まれたが、インストールできる修正版はまだ提供されていない。
  → [The Hacker News](https://thehackernews.com/2026/11/attackers-ai-agents-found-zero-day-in.html) <!-- pub:2026-11-21 -->
  <details><summary>📖 詳しく読む</summary>
  MONAI Label 0.8.5以前に影響するパストラバーサルの欠陥で、アカウントなしの攻撃者が保存フォルダ外にファイルを書き込める。9月に約48時間かけて調査し、ファイル書き込みまで約11分で到達した。Pythonの起動時に読み込まれるファイルを仕込み、学習機能の実行でroot権限を得た。
  </details>

</details>
