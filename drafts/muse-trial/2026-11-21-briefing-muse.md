---
title: "📅 2026-11-21 デイリーブリーフィング（muse トライアル）"
date: 2026-11-21
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
Ruby、7件の脆弱性を修正 — うち1件はデフォルト設定のRailsアプリに認証なしで到達するRCEとされ、早急な更新が必要なため。（→ 🔒 セキュリティを参照）

**📰 ビジネス・経済**
アンソロピックがナスダックに上場し、初日の終値は97.17ドルで公開価格を17%上回った。ソフトバンクグループ株は一時17%安と急落し、AI・半導体関連株への売りが加速した。

**🤖 AI最新動向**
本日の更新なし

**🚀 新サービス・ローンチ**
MetaがInstagramのDMだけを使える単体アプリ「Direct by Instagram」をローンチし、トルコとタイでテストを開始した。音声をMIDIに変換するオープンソースモデルDettato、耳鳴りの周波数を特定するブラウザツール、自然言語で検索できる地図アプリHippoMaps、メッセージで仕事を依頼できるAIエージェントAnyaも登場した。

**🇯🇵 国内技術・ツール**
Amazon EMR Serverlessに余剰容量で最大60%のコスト削減をうたうFlex executionが加わり、EC2にはGraviton5搭載のT9gインスタンスが登場した。Amazon ECRは1つのグローバル認証トークンで複数リージョンを操作できるようになり、Windows 11の11月非セキュリティプレビューパッチも公開された。

**📋 開発組織・キャリア**
本日の更新なし

**🔒 セキュリティ**
Rubyが7件の脆弱性を修正し、うち3件はクリティカルで、CVE-2026-132825はデフォルト設定のRailsアプリに認証なしで到達するとされる。Linux KVMの欠陥CVE-2026-99312ではゲストVMからホストメモリへのアクセスが実証され、IPAはPHPの複数の脆弱性について修正版への更新を呼びかけた。

---

<details markdown="block">
<summary>📰 ビジネス・経済（2件）</summary>

- **アンソロピック、ナスダック上場で終値97.17ドル — 公開価格を17%上回る**
  IPOの発表に続き、ナスダックでの取引が始まり、初日の終値は97.17ドルで公開価格を17%上回った。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOGN18CL00Y6A111C2000000/) <!-- pub:2026-11-20 -->

- **ソフトバンクG株が一時17%安、AI・半導体関連株に売り**
  ソフトバンクグループ株が一時17%安と急落し、AI・半導体関連株への売りが加速した。
  → [NewsPicks](https://newspicks.com/news/17956750/) <!-- pub:2026-11-20 -->

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（5件）</summary>

- **Dettato、音声をMIDIに変換するオープンソースモデル**
  音声をMIDIに変換する2000万パラメータのオープンソースモデルで、既存モデルより60倍効率的としている。
  → [Hacker News](https://news.ycombinator.com/item?id=50526023) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  音声をMIDIに変換する、2000万パラメータのオープンソースモデル。既存モデルより60倍効率的としている。
  </details>

- **耳鳴りの周波数を約4分で特定し緩和するブラウザツール**
  耳鳴りの周波数を約4分で特定し、ノッチ音声で緩和する無料のブラウザツール。
  → [Hacker News](https://news.ycombinator.com/item?id=50541568) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  耳鳴りの周波数を約4分で特定し、ノッチ音声で緩和する無料のブラウザツール。
  </details>

- **HippoMaps、自然言語で検索できる地図アプリ**
  OpenStreetMapのデータに対し、高速で決定論的な自然言語検索を行える地図アプリ。
  → [Hacker News](https://news.ycombinator.com/item?id=50561199) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  OpenStreetMapのデータに対し、高速で決定論的な自然言語検索を行える地図アプリ。
  </details>

- **Direct by Instagram、DM専用の単体アプリをローンチ**
  InstagramのフィードなしでDMだけを使える単体メッセージアプリ。トルコとタイでiOSとAndroid向けにテスト中。
  → [Product Hunt](https://www.producthunt.com/products/instagram) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  フィードなしでInstagramのDMだけを使える単体メッセージアプリ。Instagramアカウントで既存の会話を同期でき、メールアドレスや電話番号だけでも利用できる。iOSとAndroid向けにトルコとタイでテスト中。
  </details>

- **Anya、メッセージを送ると仕事を返してくれるAIエージェント**
  WhatsAppとiMessageでメッセージを送ると、完了した仕事を返してくれるパーソナルAIエージェント。
  → [Product Hunt](https://www.producthunt.com/products/anya-4) <!-- pub:2026-11-19 -->
  <details><summary>📖 詳しく読む</summary>
  WhatsAppとiMessageでメッセージを送ると、完了した仕事を返してくれるパーソナルAIエージェント。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（4件）</summary>

- **Amazon EMR ServerlessにFlex execution、最大60%のコスト削減**
  Amazon EMR Serverlessの新機能Flex executionは、余剰容量でexecutorを動かし、最大60%のコスト削減をうたう実行オプション。
  → [DevelopersIO](https://dev.classmethod.jp/articles/amazon-emr-serverless-flex-execution/) <!-- pub:2026-11-21 -->

- **EC2にGraviton5搭載のT9gインスタンスが登場**
  AWS公式発表はないものの、料金ページとAPIにGraviton5搭載のEC2 T9gインスタンスが登場したことが確認された。
  → [DevelopersIO](https://dev.classmethod.jp/articles/update-amazon-ec2-graviton5-t9g-instance/) <!-- pub:2026-11-20 -->

- **Amazon ECR、1つのグローバル認証トークンで複数リージョンを操作**
  Amazon ECRのプライベートレジストリで、1つのグローバル認証トークンによる複数リージョンの操作を検証した。
  → [DevelopersIO](https://dev.classmethod.jp/articles/aws-ecr-global-authentication-token/) <!-- pub:2026-11-20 -->

- **Windows 11の11月非セキュリティプレビューパッチを公開**
  Microsoftが2026年11月のWindows 11非セキュリティプレビューパッチを公開し、新しいWindows Searchやモダンな［ファイル名を指定して実行］ダイアログを導入した。
  → [窓の杜](https://forest.watch.impress.co.jp/docs/news/2158070.html) <!-- pub:2026-11-20 -->

</details>

<details markdown="block">
<summary>🔒 セキュリティ（3件）</summary>

- **Ruby、7件の脆弱性を修正 — うち1件はデフォルトのRailsアプリに認証なしで到達**
  Rubyが正規表現エンジンと文字列の大文字小文字変換コードの7件の脆弱性を修正し、修正版はRuby 4.0.10、3.4.13、3.3.14。うち3件はクリティカルで、CVE-2026-132825（Ruby2Shell）はデフォルト設定のRailsアプリに認証なしで到達するとされる。
  → [The Hacker News](https://thehackernews.com/2026/11/ruby-releases-fixes-for-7-regex-and.html) <!-- pub:2026-11-19 -->
  <details><summary>📖 詳しく読む</summary>
  Rubyの正規表現エンジンと文字列の大文字小文字変換コードに7件の欠陥があり、うち3件がクリティカル。CVE-2026-132825は1バイトのヒープオーバーフローで、デフォルト設定のRailsアプリに認証なしで到達するとされる。修正版はRuby 4.0.10、3.4.13、3.3.14。
  </details>

- **Linux KVMの欠陥CVE-2026-99312、ゲストVMからホストメモリにアクセス可能**
  AMDホストでネスト仮想化が有効な場合、ゲストVMがホストのメモリにアクセスできる欠陥。DigitalOceanのサーバーで約127GBのメモリ読み取りが実証された。カーネル開発チームはCVSS 8.8を付け、修正済みカーネルを公開した。
  → [The Hacker News](https://thehackernews.com/2026/11/new-linux-kvm-flaw-cve-2026-99312-lets.html) <!-- pub:2026-11-20 -->
  <details><summary>📖 詳しく読む</summary>
  AMDホストでネスト仮想化が有効な場合、ゲストVMがホストのメモリにアクセスできる欠陥。DigitalOceanのサーバーで約127GBのメモリ読み取りが実証された。カーネル開発チームはCVE-2026-99312にCVSS 8.8を付け、修正済みカーネルを公開した。
  </details>

- **IPA、PHPの複数の脆弱性について注意喚起**
  PHPの複数の脆弱性を修正したPHP 8.2.36／8.3.37／8.4.28／8.5.13が公開され、IPAが利用環境の確認と修正版への更新を呼びかけた。
  → [IPA](https://www.ipa.go.jp/security/security-alert/2026/alert20261120.html) <!-- pub:2026-11-20 -->

</details>
