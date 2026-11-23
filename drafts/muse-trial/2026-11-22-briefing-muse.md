---
title: "📅 2026-11-22 デイリーブリーフィング（muse トライアル）"
date: 2026-11-22
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
GPGMEの重大な脆弱性CVE-2026-129975 — メールクライアントなど多くのアプリが使うライブラリの欠陥で、修正版2.3.1への更新が必要なため。（→ 🔒 セキュリティを参照）

**📰 ビジネス・経済**
20日の米株式市場でナスダックが前日比5%安となり、半導体株指数はエヌビディアの急落で1割下げた。アンソロピックはグリーンシューの全額行使でIPO調達総額が約935億ドルとなり、史上最大のIPOとなった。

**🤖 AI最新動向**
OpenAIが創薬化学の推論ベンチマークMedChemBenchを公開し、GPT-6.2 Astraが最高成績を記録した。GoogleはDuplexをGeminiアプリのTasksで開始し、AIが発見・設計・検証した新CPUアーキテクチャFrostbiteも発表された。

**🚀 新サービス・ローンチ**
AI音声エージェントを調整なしで構築できるプラットフォームZeusと、実コードの上でエージェントと協働でデザインできるオープンソースツールOnlookが公開された。

**🇯🇵 国内技術・ツール**
BitriseのセキュリティインシデントとXcode 27.3 beta 2などをまとめたiOS開発の週次記事が出た。Microsoft Edge 158が公開され、Webページを作り変えるRemixが導入された。

**📋 開発組織・キャリア**
本日の更新なし

**🔒 セキュリティ**
GPGMEの重大な脆弱性CVE-2026-129975が公表され、修正版2.3.1が公開された。CISAはApache Rollerなど4件の脆弱性をKEVに追加し、11月23日までの対応を求めた。

---

<details markdown="block">
<summary>📰 ビジネス・経済（2件）</summary>

- **米国株急落で強まるリスク回避、日経平均株価「年内5万円接近」の声**
  20日の米株式市場で主要3指数が大きく下げ、ナスダック総合株価指数は前日比5%安、半導体株指数はエヌビディアの急落を受けて1割下げた。アンソロピックの大幅安を背景にAI関連が軒並み売られ、リスク回避姿勢が広がった。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUB211CX0R21C26A1000000/) <!-- pub:2026-11-21 -->

- **アンソロピックのIPO調達額、グリーンシュー行使で約935億ドルに**
  引受人のグリーンシュー（追加売出）が全額行使され、1億4700万株が追加で売り出された。IPOの調達総額は約935億ドルとなり、史上最大のIPOとなった。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOGN20CX50Q6A121C2000000/) <!-- pub:2026-11-21 -->

</details>

<details markdown="block">
<summary>🤖 AI最新動向（3件）</summary>

- **OpenAI、創薬化学の推論ベンチマークMedChemBenchを公開**
  創薬化学の研究課題99問でAIモデルを評価するベンチマークで、117本の論文・特許と761の分子構造を用いる。GPT-6.2 Astraが最高成績を記録し、分子構造の再構成では95.4%の得点を得た。
  → [OpenAI Blog](https://openai.com/index/introducing-medchembench/) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  99問の課題で分子構造の再構成、科学的推論、化合物の選定、物性予測の4つを評価する。GPT-6.2 Astraは分子構造の再構成で95.4%の得点を得たが、化合物の選定と数値予測では約半分の得点にとどまった。
  </details>

- **Google、DuplexをGeminiアプリのTasksで開始**
  約10年前に始まったDuplexの通話技術がGeminiアプリのTasksに組み込まれ、AIが企業へ電話して予約などの用事を代行する。通話スタックはGemini 4で統一され、電話の冒頭でAIによる自動通話であることを明示する。
  → [Google Research Blog](https://research.google/blog/how-google-duplex-evolved-to-also-call-businesses-for-you-in-gemini/) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  今週、GeminiアプリのTasksでDuplexの提供が始まった。店舗への電話で予約や問い合わせを代行し、Gemini 4のHydrogenとNeonを使う。通話はAIによる自動通話であることを冒頭で明示し、店舗は通話中の申し出やビジネスプロフィールの設定で拒否できる。
  </details>

- **Frostbite、AIが発見・設計・検証した新CPUアーキテクチャ**
  Architect Labsが、AIが発見・設計・検証した汎用CPUアーキテクチャFrostbiteを発表した。25のワークロードで、現行のスーパースカラコアと比べてワットあたり性能が4.59倍になったとしている。
  → [Hacker News](https://news.ycombinator.com/item?id=50572503) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  インタラクションネットの性質を利用した新しい命令セットのCPUで、コンパイラからRTL、検証、最終GDSまでAIが自律的に繰り返し改良した。25のワークロードのうち15は最終評価まで伏せてあり、現行のスーパースカラコア比でワットあたり性能4.59倍を記録した。
  </details>

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（2件）</summary>

- **Zeus、AI音声エージェントを調整なしで構築できるプラットフォーム**
  ThunderPhoneが、AI音声エージェント向けプラットフォームZeusを公開した。利用者が用途と目標を説明すると、Zeusが音声エージェントの構成を決め、模擬通話と実際の通話で評価しながら改善する。Big Bench Audioで99.4%を記録したとしている。
  → [Hacker News](https://news.ycombinator.com/item?id=50568763) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  従来の音声エージェントは聞き取り違いと指示通りに動かない問題があった。Zeusは複数の文字起こしモデルと速い・遅い複数のLLMを組み合わせ、通話ごとに最適な構成をAIが選ぶ。利用は当面無料で、通話料は原価に17〜25%を上乗せする課金体系としている。
  </details>

- **Onlook、実コードの上でエージェントと協働でデザインできる開発者ツール**
  Onlookが、実際のコードの上にキャンバスを重ね、エージェントと協働でデザインできるオープンソースの開発者ツールを再構築して公開した。Claude CodeやCodexを自分の契約で動かし、デザイン作業がそのまま出荷するコードになる。
  → [Hacker News](https://news.ycombinator.com/item?id=50562320) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  ブラウザウィンドウのキャンバス上で動くアプリを直接編集し、変更がそのまま実際のコードになる。Claude CodeやCodexを自分のサブスクリプションで動かし、MCPでFigmaなども接続できる。当面は無料で、クラウド機能などを将来の有料プランにする予定。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（2件）</summary>

- **iOSアプリ開発の気になる変更まとめ（2026/11/21）**
  Bitriseが11月14日にSEV-1のセキュリティインシデントを公表し、15のワークスペースでファイルへの不正アクセスがあった。Xcode 27.3 beta 2が11月17日に出て、CocoaPodsのtrunkは12月2日に読み取り専用になる。
  → [DevelopersIO](https://dev.classmethod.jp/articles/ios-dev-weekly-changes-20261121/) <!-- pub:2026-11-21 -->

- **Microsoft Edge 158を公開、Webページを作り変えるRemixを導入**
  Microsoftが11月19日（現地時間）にデスクトップ向けEdge 158.0.4370.33を安定版でリリースした。対応するWebページをプロンプトで好みに作り変えるRemixが導入され、変更は自分のブラウザーの表示だけに反映される。
  → [窓の杜](https://forest.watch.impress.co.jp/docs/news/2158136.html) <!-- pub:2026-11-20 -->

</details>

<details markdown="block">
<summary>🔒 セキュリティ（2件）</summary>

- **GPGMEの重大な脆弱性CVE-2026-129975、修正版2.3.1が公開**
  悪意あるOpenPGP鍵の異常に長いユーザーIDがGPGMEの二重解放の欠陥を引き起こし、アプリのデータが漏れるおそれがある。GPGME 2.3.0未満を使うソフトが対象で、修正版2.3.1への更新が呼びかけられている。悪用の報告はなく、リモートコード実行も否定できないとされる。
  → [The Hacker News](https://thehackernews.com/2026/11/gnupg-warns-critical-gpgme-flaw-could.html) <!-- pub:2026-11-21 -->
  <details><summary>📖 詳しく読む</summary>
  CVE-2026-129975は、GnuPGとやり取りするGPGMEの読み取り処理にある二重解放の欠陥で、メールクライアントやXMPPクライアント、Sambaなどが影響を受ける。修正版はGPGME 2.3.1で、Gpg4winは5.1.2に同梱した。旧版を使い続ける場合は1.24.4が用意されている。
  </details>

- **CISA、悪用確認済みの脆弱性4件をKEVに追加**
  CISAはApache Roller、VMware vCenter、Cisco Expressway、SAP NetWeaverの脆弱性4件をKEVに追加し、連邦機関に11月23日までの対応を求めた。VMware vCenterのCVE-2026-123890は、中国系とみられる諜報グループによる悪用と関連付けられている。
  → [The Hacker News](https://thehackernews.com/2026/11/hackers-exploit-critical-vmware-cisco.html) <!-- pub:2026-11-21 -->
  <details><summary>📖 詳しく読む</summary>
  追加されたのはApache RollerのCVE-2026-129448、VMware vCenterのCVE-2026-123890、Cisco ExpresswayのCVE-2026-76466、SAP NetWeaverのCVE-2025-42884の4件で、3件のCVSSは9.8。vCenterの欠陥はArmory Castleと呼ばれるグループがBeyondTrustの欠陥と組み合わせて悪用したとされる。
  </details>

</details>
