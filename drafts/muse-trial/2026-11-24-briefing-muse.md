---
title: "📅 2026-11-24 デイリーブリーフィング（muse トライアル）"
date: 2026-11-24
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
ScreenConnectの重大な欠陥CVE-2026-84869（CVSS 9.9）が悪用され、MSPの技術者PCが乗っ取られる事案が発生 — 修正版26.6.5以降への更新が求められるため。（→ 🔒 セキュリティを参照）

**📰 ビジネス・経済**
顧客体験AIのSierraがシリーズFで17.5億ドルを調達し、評価額は半年で2倍の300億ドルに達した。

**🤖 AI最新動向**
GoogleがTransformerの残差接続を改良するDeepCrossAttentionを発表し、パラメータを30〜40%削減しつつ同等以上の学習性能を達成した。OpenAIとCiscoは、パッチ適用までの間Linuxシステムを保護するオープンソースランタイムShirudoを公開した。

**🚀 新サービス・ローンチ**
LLMのサブエージェントになりきってタスクをこなすゲームworker755がShow HNに登場した。自社サイトの訪問者を確認しセッションを再生できるLetter VisitorsがProduct Huntで公開された。

**🇯🇵 国内技術・ツール**
Amazon EventBridgeにWebhook Eventsが追加され、外部サービスから直接イベントを受け取れるようになった。AWS Pricing CalculatorのAPIに、保存なしで料金を試算する機能が追加された。

**📋 開発組織・キャリア**
本日の更新なし

**🔒 セキュリティ**
ScreenConnectの重大な欠陥CVE-2026-84869（CVSS 9.9）が悪用され、MSPが標的になった。binary-parserのコードインジェクションCVE-2026-134814（CVSS 9.2）が修正された。インドの銀行・フィンテックでAI支援攻撃による不正送金が発生したとCERT-Inが警告し、OpenRouterはプロンプト窃取を受けて3社の推論プロバイダーを除外した。

---

<details markdown="block">
<summary>📰 ビジネス・経済（1件）</summary>

- **Sierra、シリーズFで17.5億ドルを調達し評価額300億ドルに**
  顧客体験AIのSierraがシリーズFで17.5億ドルを調達し、評価額は半年で2倍の300億ドルに達した。
  → [TechCrunch](https://techcrunch.com/2026/11/23/sierra-doubles-valuation-to-30b-within-six-months-as-demand-for-ai-in-cx-takes-off/) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  SierraはシリーズFで17.5億ドルを調達し、評価額は300億ドルに達した。評価額は半年で2倍になった。顧客体験向けAIへの需要拡大が調達の背景にある。
  </details>

</details>

<details markdown="block">
<summary>🤖 AI最新動向（2件）</summary>

- **Google、Transformerの残差接続を強化するDeepCrossAttentionを発表**
  各層がトークンごとに過去の層から特徴を動的に選択するDeepCrossAttentionにより、パラメータを30〜40%削減しつつ同等以上の学習性能を達成した。
  → [Google Research Blog](https://research.google/blog/supercharging-transformer-residual-connections/) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  DeepCrossAttentionは各層がトークンごとに過去の層から特徴を動的に選択する仕組みで、Transformerの残差接続の改良として提案された。パラメータを30〜40%削減しながら同等以上の学習性能を達成した。
  </details>

- **OpenAIとCisco、Linuxを守るオープンソースランタイム「Shirudo」を公開**
  eBPFシールドでパッチ適用までの間Linuxシステムを保護するオープンソースランタイムを、OpenAIとCiscoが共同で公開した。
  → [OpenAI Blog](https://openai.com/index/introducing-shirudo/) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  ShirudoはeBPFシールドでパッチ適用までの間Linuxシステムを保護するオープンソースのランタイム。OpenAIとCiscoが共同で公開した。
  </details>

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（2件）</summary>

- **LLMのサブエージェントになりきるゲーム「worker755」がShow HNに登場**
  プレイヤーがLLMのサブエージェントとしてタスクをこなすゲーム。GitHubでオープンソースとして公開され、ローカルLLMへの対応も追加された。
  → [Hacker News](https://news.ycombinator.com/item?id=50599762) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  プレイヤーはLLMのサブエージェントになりきり、指示されたタスクをこなすゲーム。GitHubでオープンソースとして公開された。コマンドのヒント表示を切る選択肢や、OllamaなどローカルLLMへの対応が追加された。
  </details>

- **Letter Visitors、自社サイトの訪問者を確認できるツールを公開**
  自社サイト上で訪問者（人物・企業・AIエージェント）を確認し、セッションを再生できる。
  → [Product Hunt](https://www.producthunt.com/products/visitors) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  Letter Visitorsは自社サイトの訪問者を確認できるツール。訪問者が人物か企業かAIエージェントかを判別し、セッションを再生できる。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（2件）</summary>

- **EventBridgeの新機能「Webhook Events」で外部サービスから直接イベントを受け取り可能に**
  Amazon EventBridgeにWebhook Eventsが追加され、外部サービスから直接イベントを受け取れるようになった。署名検証を行い、SQSへイベントが到達することを確認している。
  → [DevelopersIO](https://dev.classmethod.jp/articles/eventbridge-webhook-events/) <!-- pub:2026-11-23 -->

- **AWS Pricing CalculatorのAPIに料金試算機能が追加**
  GetUsageLinesEstimatedCostを使い、保存なしで料金を試算できるようになった。
  → [DevelopersIO](https://dev.classmethod.jp/articles/aws-pricing-calculator-api/) <!-- pub:2026-11-23 -->

</details>

<details markdown="block">
<summary>🔒 セキュリティ（4件）</summary>

- **ScreenConnectの重大な欠陥CVE-2026-84869が悪用され、MSPの技術者PCが乗っ取られる**
  ゲストが技術者のPCに悪意あるファイルを実行させられるScreenConnectの重大な欠陥（CVE-2026-84869、CVSS 9.9）が悪用され、MSPが標的になった。修正版26.6.5以降への更新が推奨されている。
  → [The Hacker News](https://thehackernews.com/2026/11/hackers-exploit-critical-screenconnect.html) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  CVE-2026-84869はCVSS 9.9のScreenConnectクライアントの欠陥で、ゲストが技術者のPCに悪意あるファイルを実行させられる。Huntressは11月12日にMSP技術者の端末で悪用を確認し、少なくとも118台の自社ホスト型サーバーで関連活動を観測した。修正版26.6.5以降への更新が推奨されている。
  </details>

- **binary-parserのコードインジェクションCVE-2026-134814を修正**
  パーサー定義を制御する攻撃者が任意のJavaScriptを実行できるbinary-parserの欠陥（CVE-2026-134814、CVSS 9.2）が修正された。
  → [The Hacker News](https://thehackernews.com/2026/11/critical-binary-parser-flaw-enables.html) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  CVE-2026-134814はbinary-parserのコードインジェクションの欠陥でCVSS 9.2。パーサー定義を制御できる攻撃者が任意のJavaScriptを実行できる。修正版が公開された。
  </details>

- **インドの銀行・フィンテックでAI支援攻撃による不正送金、CERT-Inが警告**
  AI支援攻撃によりインドの銀行・フィンテックで正規の決済経路を使った不正送金が発生したとCERT-Inが警告した。
  → [The Hacker News](https://thehackernews.com/2026/11/ai-assisted-cyberattacks-trigger.html) <!-- pub:2026-11-23 -->
  <details><summary>📖 詳しく読む</summary>
  CERT-InはAI支援攻撃によりインドの銀行・フィンテックで不正送金が発生したと警告した。攻撃は正規の決済経路を使って行われた。
  </details>

- **OpenRouter、プロンプト窃取を受け3社の推論プロバイダーを除外**
  約200万件のプロンプトにカナリアトークンを仕込んだ調査で、3社のAI推論プロバイダーにおける数か月にわたるプロンプト窃取が判明し、OpenRouterが3社を除外した。
  → [The Hacker News](https://thehackernews.com/2026/11/openrouter-drops-3-providers-after.html) <!-- pub:2026-11-22 -->
  <details><summary>📖 詳しく読む</summary>
  Dragosの調査で3社のAI推論プロバイダーから数か月にわたりプロンプトが盗まれていたことが判明した。調査では約200万件のプロンプトにカナリアトークンが仕込まれた。OpenRouterは3社を除外し、125エンドポイントをゼロデータ保持の対象から外した。
  </details>

</details>
