# Shojin_App

| リリース | コードベース | その他 |
| --- | --- | --- |
| [![Latest release](https://img.shields.io/github/v/release/Shojin-App/shojin_app?include_prereleases)](https://github.com/Shojin-App/shojin_app/releases) [![Downloads](https://img.shields.io/github/downloads/Shojin-App/shojin_app/total)](https://github.com/Shojin-App/shojin_app/releases) | [![License](https://img.shields.io/github/license/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app/blob/main/LICENSE) [![Repo Size](https://img.shields.io/github/repo-size/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app) [![Code Size](https://img.shields.io/github/languages/code-size/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app) [![Android Build](https://github.com/Shojin-App/shojin_app/actions/workflows/build.yaml/badge.svg)](https://github.com/Shojin-App/shojin_app/actions/workflows/build.yaml) | [![GitHub Stars](https://img.shields.io/github/stars/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app/stargazers) [![Forks](https://img.shields.io/github/forks/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app/network/members) [![Issues](https://img.shields.io/github/issues/Shojin-App/shojin_app)](https://github.com/Shojin-App/shojin_app/issues) [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Shojin-App/shojin_app) |


[<img src="https://github.com/machiav3lli/oandbackupx/blob/034b226cea5c1b30eb4f6a6f313e4dadcbb0ece4/badge_github.png"
    alt="Get it on GitHub"
    height="80">](https://github.com/Shojin-App/shojin_app/releases)

AtCoderの精進をスマホでも。

## 機能

### 🌐 ブラウザ機能
- **AtCoder問題サイトの閲覧**: NoviSteps、AtCoder Problemsなど、精進に役立つサイトを統合ブラウザで閲覧
- **カスタムサイト追加**: お気に入りの問題集サイトを追加して、ワンタップでアクセス
- **問題へのスムーズな遷移**: AtCoder問題ページから直接エディタ画面に移動

### 📝 コードエディタ
- **シンタックスハイライト**: Python、C++、Rust、Javaに対応した見やすいコードハイライト
- **テンプレート機能**: 言語別のコードテンプレートをカスタマイズ可能
- **自動保存**: 問題ごと・言語ごとにコードを自動保存
- **リアルタイム実行**: Wandbox APIを使用してコードをその場で実行・テスト

### 🧪 テスト機能
- **サンプルケース自動テスト**: AtCoderのサンプル入出力でコードを自動テスト
- **詳細な結果表示**: AC/WA/RE/TLE/CEなど、詳細なジャッジ結果を表示
- **デバッグ支援**: 入力・期待される出力・実際の出力を比較表示

### 📋 問題管理
- **問題詳細表示**: 問題文、制約、入出力形式を見やすく整理
- **URL自動解析**: AtCoder問題URLから問題情報を自動取得
- **LaTeX記法対応**: 数式表示を含む問題文の適切な表示

### 🎨 カスタマイズ
- **テーマ選択**: ライト/ダーク/ピュアブラック/システム追従の4つのテーマ
- **Material You対応**: Android 12+の壁紙連動カラーテーマ
- **透明度調整**: ナビゲーションバーの透明度をカスタマイズ可能

### 🚀 提出機能
- **WebView提出**: AtCoderの提出ページをアプリ内で開いて提出

### 📱 モバイル最適化
- **レスポンシブデザイン**: スマートフォンでの操作に最適化されたUI
- **触覚フィードバック**: ボタン操作時の触覚フィードバック

## インストール

### GitHubリリースから

ビルド済みのバイナリ（APKなど）は[GitHubリリーズページ](https://github.com/Shojin-App/shojin_app/releases)からダウンロードできます。これが手っ取り早いです。

### F-Droid 対応版

このアプリは F-Droid Inclusion Policy に準拠したビルドが可能です。F-Droid フレーバー (`fdroid`) では以下が強制されます:

| 機能 | 通常ビルド | F-Droid ビルド |
|------|------------|----------------|
| 自己アップデート (アプリ内ダウンロード & APKインストール) | 有効 (ユーザー設定可) | 完全無効 (コードパス停止) |
| 起動時自動アプデチェック | 表示 | 非表示 |
| オンラインフォント (Google Fonts) | 利用可 | 無効 (同梱/システムフォント) |
| 外部APKダウンロード | 有効 | 無効 |

自己アップデート関連クラス (`AutoUpdateManager`, `UpdateManager`) は F-Droid ビルドでは早期 return するノーオペ実装になり、不用意に APK を取得・実行しません。

#### ビルド手順 (F-Droid フレーバー)

```bash
# 推奨: スクリプトで再現性確保
./build_fdroid.sh

# 手動:
flutter build apk \
    --dart-define=FDROID_BUILD=true \
    --dart-define=ENABLE_SELF_UPDATE=false \
    --dart-define=ENABLE_ONLINE_FONTS=false \
    --flavor=fdroid \
    --release
```

#### 確認ポイント (F-Droid 申請前チェックリスト)
- [ ] `git tag vX.Y.Z` が `pubspec.yaml` の `version` と一致
- [ ] 起動後「設定 > 更新設定」セクションに自己更新 UI が表示されない
- [ ] ネットワークトラフィックが AtCoder / コード実行 API / 静的リソース以外へ行かない
- [ ] `flutter analyze` と `flutter test` が成功
- [ ] `FONT_LICENSES.md` / LICENSE 表示画面から辿れる

### ソースからビルド

自身でアプリをビルドしたい場合や、開発に貢献したい場合は、ソースからビルドできます：

1.  **Flutter開発環境のセットアップ:**
    まず、Flutter開発環境がセットアップされていることを確認してください。まだの場合は、[Flutter公式インストールガイド](https://flutter.dev/docs/get-started/install)に従ってください。
2.  **リポジトリをクローン:**
    ```bash
    git clone https://github.com/Shojin-App/shojin_app.git
    ```
3.  **プロジェクトディレクトリに移動:**
    ```bash
    cd shojin_app
    ```
4.  **依存関係を取得:**
    ```bash
    flutter pub get
    ```
5.  **アプリをビルドして実行:**
    *   デバッグモードで実行:
        ```bash
        flutter run
        ```
    *   リリースAPKをビルド (Android):
        ```bash
        flutter build apk --release
        ```
    *   その他のプラットフォームやビルドオプションについては、[Flutter公式ビルドドキュメント](https://flutter.dev/docs/deployment)を参照してください。

## コントリビューション

このプロジェクトへの貢献を歓迎します！バグ報告、機能提案、プルリクエストなど、どのような形でも結構です。

### バグ報告や機能要望

*   バグ報告や機能要望は、GitHubの[Issuesページ](https://github.com/Shojin-App/shojin_app/issues)を利用して報告してください。

### 開発への参加

1.  **リポジトリをフォーク:**
    ご自身のGitHubアカウントにこのリポジトリをフォークします。
2.  **ブランチを作成:**
    変更内容に応じたブランチを作成します。
    ```bash
    # 機能追加の場合
    git checkout -b feature/your-feature-name
    # バグ修正の場合
    git checkout -b bugfix/issue-number
    ```
3.  **変更とコミット:**
    コードの変更を行い、分かりやすいコミットメッセージと共にコミットします。
4.  **プルリクエストを作成:**
    変更が完了したら、フォークしたリポジトリから本リポジトリの`dev`ブランチに対してプルリクエストを作成します。
    プルリクエストには、以下の情報を含めてください：
    *   変更内容の概要
    *   変更の理由や目的
    *   関連するIssue番号（もしあれば）

### コーディングスタイル

*   可能な限り、既存のコードスタイルや規約に従ってください。
*   コードを追加・修正した場合は、`flutter analyze` を実行して、静的解析エラーや警告がないことを確認してください。
*   関連するテストコードが存在する場合は更新し、新しい機能にはテストコードを追加することを推奨します。

ご協力ありがとうございます！

## ライセンス

このプロジェクトはGNU General Public License v3.0（GPLv3）のもとで公開されています。詳細はリポジトリ内の[LICENSE](LICENSE)をご覧ください。

## 参考にしたリポジトリ

https://github.com/inotia00/revanced-manager

## 免責事項

本プロジェクトおよびその内容は、AtCoder株式会社及びその関連会社とは一切関係がなく、資金提供、承認、支持、またはその他いかなる形での関連もありません。
本プロジェクトで使用されている商標、サービスマーク、商号、またはその他の知的財産権は、それぞれの所有者に帰属します。

GitHub ロゴ, YouTube ロゴ, X(Twitter) ロゴ は各社の登録商標/商標です。これらのロゴはリンク誘導/識別目的のみで使用されており、本アプリによる公式な提携・後援・保証を意味しません。

### 商標について

- **GitHub® および GitHub ロゴ** は GitHub, Inc. の米国およびその他の国における登録商標または商標です。
- **YouTube™ および YouTube ロゴ** は Google LLC の商標です。
- **X™（旧 Twitter）および X ロゴ** は X Corp. の商標です。
- 記載されている会社名・製品名・サービス名等は、各社の商標または登録商標であり、本文中では TM, ® を明示しない場合があります。
- 本アプリ内での各ロゴ・名称の使用は識別・説明のみを目的としており、いかなる公式な提携・承認・後援関係も示唆しません。
