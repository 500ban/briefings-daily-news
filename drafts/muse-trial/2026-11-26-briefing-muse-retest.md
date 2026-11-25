---
title: "📅 2026-11-26 デイリーブリーフィング（muse トライアル）"
date: 2026-11-26
layout: post
---

## 🎯 今日のまとめ

**⭐ 今日の1本**
GeoServerの2件の脆弱性が悪用され、未認証のリモートコード実行につながる — 悪用が確認されており、至急の更新が必要なため。（→ 🔒 セキュリティ）

**📰 ビジネス・経済**
日経平均株価は25日に一時2000円安となり、米半導体株安の流れが波及した。10月の企業向けサービス価格指数は前年同月比4.2%上昇し、36年ぶりの高水準となった。ベルシステム24HDは富士ソフトサービスビューロを67億円で買収すると発表し、M&A仲介会社への不正アクセスで最大数千社分の顧客情報が漏えいしたおそれがあると報じられた。

**🤖 AI最新動向**
GoogleはLLMアシスタントの社会的推論を測る評価枠組みを公開し、ユーザーの主観的な語りを介すると精度が下がることを示した。OpenAIが公開した数学論文では、行列乗算の指数が9/4と確定した。

**🚀 新サービス・ローンチ**
往年のNVIDIA・ATI製テクニカルデモをブラウザ上で再現したギャラリーがShow HNに登場した。

**🇯🇵 国内技術・ツール**
複数クラウドとオンプレミスのデータベースを一元管理する「Database Hub in Fabric」が正式リリースされた。

**📋 開発組織・キャリア**
本日の更新なし

**🔒 セキュリティ**
GeoServerの2件の脆弱性が実際に悪用されており、未認証のリモートコード実行につながる。WP Connect製プラグイン6件がバックドア化され、WordPressが悪意あるリリースの公開を阻止した。WHMCSのショッピングカートにはSQLインジェクションの脆弱性があり、顧客情報などが漏えいするおそれがある。

---

<details markdown="block">
<summary>📰 ビジネス・経済（4件）</summary>

- **日経平均が一時2000円安、半導体関連株が下落**
  25日の東京株式市場で日経平均株価は一時2000円安となった。米フィラデルフィア半導体株指数が8%安となり、アンソロピックが公開価格83ドルを割り込んだ流れが波及した。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUB250QT0V21C26A1000000/) <!-- pub:2026-11-25 -->

- **10月の企業向けサービス価格指数、4.2%上昇で36年ぶり高水準**
  日銀が25日に発表した10月の企業向けサービス価格指数は前年同月比4.2%上昇し、1990年3月以来の高水準となった。外航貨物輸送の大幅な上昇が全体を押し上げた。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUB244WI0U6A121C2000000/) <!-- pub:2026-11-25 -->

- **ベルシステム24HD、富士ソフトサービスビューロを67億円で買収**
  ベルシステム24HDは25日、富士ソフト傘下の富士ソフトサービスビューロを67億円で買収すると発表した。2027年2月2日付で議決権ベース100%の株式を取得し、公共領域を拡充する。
  → [日経新聞](https://www.nikkei.com/article/DGXZQOUC2568O0V21C26A1000000/) <!-- pub:2026-11-25 -->

- **M&A仲介会社に不正アクセス、最大数千社分の顧客情報漏えいのおそれ**
  MJS M&Aパートナーズは社内ネットワークが不正アクセスを受け、最大で数千社分の顧客情報が外部に漏えいしたおそれがあると発表した。
  → [NewsPicks](https://newspicks.com/news/17986045/) <!-- pub:2026-11-25 -->

</details>

<details markdown="block">
<summary>🤖 AI最新動向（2件）</summary>

- **Google、LLMアシスタントの社会的推論を検証する評価枠組みを公開**
  GoogleはLLMアシスタントの社会的推論を測る評価枠組みを公開した。マルチエージェントのシミュレーションで隠れた動機の推論を測り、ユーザーの主観的な語りを介すると精度が下がることを示した。枠組みと2万件超のデータセットをオープンソースで公開した。
  → [Google Research Blog](https://research.google/blog/verifiable-social-reasoning-for-llm-assistants/) <!-- pub:2026-11-25 -->
  <details><summary>📖 詳しく読む</summary>
  マルチエージェントのシミュレーションで、対象エージェントに隠れた動機を与えてユーザーがアシスタントに相談する設定で社会的推論を評価する。12のLLMで測ると、出来事を直接見た場合よりユーザー経由の相談の方が精度が下がり、ユーザーの偏った語りをそのまま受け入れる傾向があった。枠組みと2万件超のデータセットを公開した。
  </details>

- **OpenAIの数学論文、行列乗算の指数が9/4と確定**
  OpenAIが11月24日に公開した数学論文で、行列乗算の指数が9/4と確定し、未解決問題リストの8件が解決されたとHNで話題になっている。行列乗算の指数が2に等しいという予想は反証された。
  → [Hacker News](https://news.ycombinator.com/item?id=50637220) <!-- pub:2026-11-25 -->
  <details><summary>📖 詳しく読む</summary>
  OpenAIが公開した数学論文で、行列乗算の指数が9/4と確定し、2に等しいという予想が反証された。同じ論文は強多項式の線形計画法や平均利得ゲームなども扱い、未解決問題リストの8件が解決されたと報告されている。
  </details>

</details>

<details markdown="block">
<summary>🚀 新サービス・ローンチ（1件）</summary>

- **往年のNVIDIA・ATI製テクニカルデモをブラウザで再現するギャラリー**
  往年のNVIDIA・ATI製テクニカルデモをブラウザ上で再現したギャラリーがShow HNに登場した。
  → [Hacker News](https://news.ycombinator.com/item?id=50638503) <!-- pub:2026-11-25 -->
  <details><summary>📖 詳しく読む</summary>
  往年のNVIDIA・ATI製テクニカルデモをブラウザ上で再現したギャラリーが公開された。ブラウザ上で当時のデモを動かせる。
  </details>

</details>

<details markdown="block">
<summary>🇯🇵 国内技術・ツール（1件）</summary>

- **複数クラウドのデータベースを一元管理する「Database Hub in Fabric」が正式リリース**
  複数クラウドとオンプレミスのデータベースを一元管理する「Database Hub in Fabric」が正式リリースされた。
  → [Publickey](https://www.publickey1.jp/blog/26/database_hubai.html) <!-- pub:2026-11-19 -->

</details>

<details markdown="block">
<summary>🔒 セキュリティ（3件）</summary>

- **GeoServerの2件の脆弱性が悪用、未認証のリモートコード実行に**
  GeoServerの2件の脆弱性（CVE-2026-120705、CVSS 8.6、CVE-2026-129243、CVSS 8.8）が実際に悪用されており、未認証のリモートコード実行につながるため、至急の更新が必要とされている。
  → [The Hacker News](https://thehackernews.com/2026/11/hackers-exploit-two-geoserver-flaws-as.html) <!-- pub:2026-11-25 -->
  <details><summary>📖 詳しく読む</summary>
  GeoServerの2件の脆弱性は未認証のリモートコード実行につながる欠陥で、実際に悪用されている。CVE-2026-120705のCVSSは8.6、CVE-2026-129243は8.8。修正版への至急の更新が呼びかけられている。
  </details>

- **WP Connect製プラグイン6件がバックドア化、WordPressが公開を阻止**
  WP Connect製のプラグイン6件が11月22日にバックドア化され、WordPressが悪意あるリリースの公開を阻止した。バックドア化されたプラグインにはCVE-2026-135202（CVSS 9.8）が付与されている。
  → [The Hacker News](https://thehackernews.com/2026/11/wordpress-blocks-six-backdoored-wp.html) <!-- pub:2026-11-25 -->
  <details><summary>📖 詳しく読む</summary>
  WP Connect製のプラグイン6件が11月22日にバックドア化された。CVE-2026-135202のCVSSは9.8。WordPressは悪意あるリリースの公開を阻止した。
  </details>

- **WHMCSのSQLインジェクションで顧客情報などが漏えいするおそれ**
  WHMCSのショッピングカートにSQLインジェクションの脆弱性（CVE-2026-82981、CVSS 8.7）があり、ログインなしに顧客情報と管理者パスワードハッシュが漏えいするおそれがある。
  → [The Hacker News](https://thehackernews.com/2026/11/whmcs-sql-injection-flaw-could-expose.html) <!-- pub:2026-11-24 -->
  <details><summary>📖 詳しく読む</summary>
  WHMCSのショッピングカートのSQLインジェクション（CVE-2026-82981、CVSS 8.7）で、ログインなしに顧客情報と管理者のパスワードハッシュが漏えいするおそれがある。修正版への更新が必要とされている。
  </details>

</details>
