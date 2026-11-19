---
title: "📅 2026-11-20 デイリーブリーフィング（muse トライアル）"
date: 2026-11-20
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
アンソロピック、IPOで813億ドルを調達し評価額約1.5兆ドル — 過去最大のIPOでAI業界の資金調達の規模を塗り替えたため。（→ 📰 ビジネス・経済）

**📰 ビジネス・経済**
JTがロシア事業の経営権喪失で過去最大の最終赤字見通しを発表し、日本生命は最高益を更新した。アンソロピックはIPOで813億ドルを調達して評価額は約1.5兆ドルとなり、パロアルトネットワークスはAI新興を45億ドルで買収、Payhawkは2.8億ドルを調達した。

**🤖 AI最新動向**
OpenAIはコーディングエージェントが2〜4時間の研究タスクの46%を自律完了したと報告した。

**🚀 新サービス・ローンチ**
AIエージェント向けに永続マイクロVMとライフサイクル管理を提供するエージェントネイティブなクラウド「Maritime」が登場した。

**🇯🇵 国内技術・ツール**
LambdaのカスタマーマネージドランタイムでBashランタイムを自作できるようになり、AWS InterconnectのAzure接続がGAとなった。Windows PowerShell 5.1は非推奨となり、次期WindowsではPowerShell 7が標準搭載となる。

**📋 開発組織・キャリア**
11月14日のMicrosoft 365大規模障害は修正に起因する欠陥が発端だったと判明し、テスト環境と本番の乖離などの教訓が整理された。

**🔒 セキュリティ**
Drupalコアのインストーラーに未認証でサイトを乗っ取れる重大な脆弱性が見つかり修正版が公開された。IPAはNGINXの複数の脆弱性について注意喚起し、修正版への更新を呼びかけている。

---

<details markdown="block">
<summary>📰 ビジネス・経済（5件）</summary>

- **JT、ロシア事業の経営権喪失で過去最大の最終赤字見通し**
  ロシア事業の経営権喪失で1兆3860億円を下方修正し、7240億円の最終赤字見通しを発表した。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUB196SK0Z11C26A1000000/) <!-- pub:2026-11-19 -->

- **日本生命、4〜9月期は最高益を更新**
  グループ基礎利益は前年同期比22%増の7565億円で最高益を更新し、通期見通しを上方修正した。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUB186120Y6A111C2000000/) <!-- pub:2026-11-18 -->

- **アンソロピック、IPOで813億ドルを調達し評価額約1.5兆ドル**
  公開価格83ドルで813億ドルを調達し、評価額は約1.5兆ドルとなり過去最大のIPOとなった。
  → [NewsPicks](https://newspicks.com/news/17944970/body/) <!-- pub:2026-11-19 -->

- **パロアルトネットワークス、AI新興アプライド・コンピュートを45億ドルで買収**
  通期売上高見通しを引き上げるとともに、AI新興のアプライド・コンピュートを45億ドルで買収すると発表した。
  → [NewsPicks](https://newspicks.com/news/17947838/) <!-- pub:2026-11-19 -->

- **Payhawk、2.8億ドルを調達し評価額20億ドルに**
  英フィンテックのPayhawkがゴールドマン・サックス主導で2億8000万ドルのシリーズCを調達し、評価額は20億ドルとなった。
  → [TechCrunch](https://techcrunch.com/2026/11/19/spend-management-platform-payhawk-announces-280m-raise-2b-valuation/) <!-- pub:2026-11-19 -->
  <details><summary>📖 詳しく読む</summary>
  英フィンテックのPayhawkはゴールドマン・サックス主導のシリーズCで2億8000万ドルを調達し、評価額は20億ドルとなった。支出管理プラットフォームの拡大に充てる。
  </details>

</details>

<details markdown="block">
<summary>🤖 AI最新動向（1件）</summary>

- **OpenAI、コーディングエージェントによる研究加速の内部測定結果を報告**
  コーディングエージェントが2〜4時間の研究タスクの46%を自律完了するなど、AIによる研究加速の実測結果を報告した。
  → [OpenAI Blog](https://openai.com/index/research-acceleration-jagged-frontier/) <!-- pub:2026-11-18 -->
  <details><summary>📖 詳しく読む</summary>
  OpenAIの内部測定では、コーディングエージェントが2〜4時間の研究タスクの46%を自律完了した。研究加速の実測結果として報告された。
  </details>

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（1件）</summary>

- **Maritime、AIエージェント向けの永続マイクロVMクラウド**
  AIエージェント向けに永続マイクロVMとライフサイクル管理を提供するエージェントネイティブなクラウド。
  → [Hacker News](https://news.ycombinator.com/item?id=50549188) <!-- pub:2026-11-19 -->
  <details><summary>📖 詳しく読む</summary>
  MaritimeはAIエージェント向けに永続マイクロVMとライフサイクル管理を提供するエージェントネイティブなクラウド。11月19日にShow HNで紹介された。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（3件）</summary>

- **LambdaのカスタマーマネージドランタイムでBashランタイムを自作**
  Lambdaの新機能カスタマーマネージドランタイムでAWS CLI入りのBashランタイムを自作し、シェルスクリプト関数を実行できる。
  → [DevelopersIO](https://dev.classmethod.jp/en/articles/lambda-customer-managed-runtimes-bash-runtime/) <!-- pub:2026-11-20 -->

- **AWS Interconnect - multicloudのAzure接続がGAに**
  AWS Interconnect - multicloudのAzure接続が一般提供となり、帯域幅とAWS・Azure双方の料金をCLIで検証できる。
  → [DevelopersIO](https://dev.classmethod.jp/en/articles/aws-interconnect-multicloud-azure-ga/) <!-- pub:2026-11-18 -->

- **Windows PowerShell 5.1が非推奨に、次期WindowsではPowerShell 7が標準搭載へ**
  「Windows PowerShell 5.1」が非推奨となり、次期Windowsから「PowerShell 7」が標準搭載となる。
  → [窓の杜](https://forest.watch.impress.co.jp/docs/news/2157429.html) <!-- pub:2026-11-19 -->

</details>

<details markdown="block">
<summary>📋 開発組織・キャリア（1件）</summary>

- **Microsoft 365大規模障害、原因は修正に起因する欠陥と判明**
  11月14日の大規模障害は修正に起因する欠陥が発端で、テスト環境と本番の乖離やヘルスチェックの見直しなど教訓がまとめられた。
  → [LeadDev](https://leaddev.com/technical-direction/microsofts-outage-started-with-a-fix) <!-- pub:2026-11-17 -->
  <details><summary>📖 詳しく読む</summary>
  Microsoft 365の大規模障害は修正に起因する欠陥が発端だった。テスト環境と本番の乖離やヘルスチェックの見直しが教訓として挙げられた。
  </details>

</details>

<details markdown="block">
<summary>🔒 セキュリティ（2件）</summary>

- **Drupalコアのインストーラーに重大な脆弱性、修正版を公開**
  Drupalコアのインストーラーの重大な脆弱性により未認証の攻撃者がサイトを乗っ取れるおそれがあり、修正版が公開された。
  → [The Hacker News](https://thehackernews.com/2026/11/drupal-patches-critical-installer-flaw.html) <!-- pub:2026-11-19 -->
  <details><summary>📖 詳しく読む</summary>
  Drupalコアのインストーラーに重大な脆弱性があり、未認証の攻撃者がサイトを乗っ取れるおそれがある。修正版が公開された。
  </details>

- **IPA、NGINXの複数の脆弱性について注意喚起**
  NGINXの複数の脆弱性（CVE-2026-123007、CVE-2026-123633等）についてIPAが注意喚起し、修正版への更新を呼びかけている。
  → [IPA](https://www.ipa.go.jp/security/security-alert/2026/alert20261119.html) <!-- pub:2026-11-19 -->

</details>
