<h1 align="center">Shojin_App</h1>


<p align="center">
  AtCoderの精進をスマホでも。
</p>


[<img src="https://github.com/machiav3lli/oandbackupx/blob/034b226cea5c1b30eb4f6a6f313e4dadcbb0ece4/badge_github.png"
alt="Get it on GitHub" height="80" align="center">](https://github.com/Shojin-App/shojin_app/releases)

<table>
  <tr>
    <td>
      <a href="https://github.com/Shojin-App/shojin_app/releases"><img src="https://img.shields.io/github/v/release/Shojin-App/shojin_app?include_prereleases" alt="Latest release"></a>
      <a href="https://github.com/Shojin-App/shojin_app/releases"><img src="https://img.shields.io/github/downloads/Shojin-App/shojin_app/total" alt="Downloads"></a>
    </td>
    <td>
      <a href="https://github.com/Shojin-App/shojin_app/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Shojin-App/shojin_app" alt="License"></a>
      <a href="https://github.com/Shojin-App/shojin_app"><img src="https://img.shields.io/github/repo-size/Shojin-App/shojin_app" alt="Repo Size"></a>
      <a href="https://github.com/Shojin-App/shojin_app"><img src="https://img.shields.io/github/languages/code-size/Shojin-App/shojin_app" alt="Code Size"></a>
      <a href="https://github.com/Shojin-App/shojin_app/actions/workflows/build.yaml"><img src="https://github.com/Shojin-App/shojin_app/actions/workflows/build.yaml/badge.svg" alt="Android Build"></a>
    </td>
    <td>
      <a href="https://github.com/Shojin-App/shojin_app/stargazers"><img src="https://img.shields.io/github/stars/Shojin-App/shojin_app" alt="GitHub Stars"></a>
      <a href="https://github.com/Shojin-App/shojin_app/network/members"><img src="https://img.shields.io/github/forks/Shojin-App/shojin_app" alt="Forks"></a>
      <a href="https://github.com/Shojin-App/shojin_app/issues"><img src="https://img.shields.io/github/issues/Shojin-App/shojin_app" alt="Issues"></a>
      <a href="https://deepwiki.com/Shojin-App/shojin_app"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
    </td>
  </tr>
</table>



> [!IMPORTANT]
> **`v1.1.0`でパッケージ名が変更されました。**<br>
> `v1.0.0`以前のリリースが既にインストールされている場合は別のアプリとしてインストールされます。<br>
> 設定等は引き継がれないのでお気をつけて。<br>
> (~~早く設定のエクスポート機能を実装しろ~~しました)

## 機能

### 🌐 ブラウザ機能
- **問題を探す**: NoviSteps、Problemsなどの精進に役立つサイトを統合ブラウザで閲覧
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
- **Material You対応**: 壁紙に連動したカラーテーマ
- **透明度調整**: ナビゲーションバーの透明度をカスタマイズ可能

### 🚀 提出機能
- **WebView提出**: AtCoderの提出ページをアプリ内で開いて提出

## ロードマップ
https://github.com/orgs/Shojin-App/projects/1

## インストール

### GitHubリリースから

ビルド済みのバイナリ（APKなど）は[GitHubリリースページ](https://github.com/Shojin-App/shojin_app/releases)からダウンロードできます。これが手っ取り早いです。

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

> 注記: F-Droid ビルドではオンラインから Google Fonts を取得せず、同梱フォント / システムフォントのみを使用します (ネットワークフォントアクセス無効化)。

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

## リリース運用 (dev 主導フロー)

`dev` ブランチでバージョンを上げ、GitHub Actions が main 向けリリース PR とタグ/Release を自動化します。release-please は廃止済みです。

### フロー概要
1. 通常開発は `dev` ブランチ。
2. リリースしたくなったら Actions > `Prepare Release` を手動実行:
   - bump: `patch` / `minor` / `major`
   - preid: （未使用の場合は空）
   - dry_run: テストしたい場合 true
3. ワークフローが以下を実施:
   - `pubspec.yaml` の `version:` を更新
   - `CHANGELOG.md` に対象バージョン節を挿入（プレースホルダ付き）
   - ブランチ `release/vX.Y.Z` を作成し push
   - `main` 向け PR (`chore(release): vX.Y.Z`) を作成
4. PR で CHANGELOG のプレースホルダを実際の変更内容に編集
5. マージすると `Publish Release` ワークフローが起動し:
   - タグ `vX.Y.Z` を作成
   - 該当 CHANGELOG 節を Release Notes にして GitHub Release 作成
6. Release から配布用アーティファクトを取得（今後自動添付 CI を追加する余地あり）

### コミット規約（推奨）
Conventional Commits 互換のメッセージを使うと CHANGELOG 編集が容易になります。
例:
```
feat(editor): テンプレ生成を高速化
fix(browser): 末尾スラッシュURLの解析不具合
chore(deps): ライブラリアップデート
refactor(ui): テーマ切替ロジック整理
```

### 運用ルール
- `dev` では手動で `pubspec.yaml` の version を書き換えない（必ず `Prepare Release` 経由）
- リリース PR のタイトルは自動生成形式を維持
- CHANGELOG の過去バージョン節は書き換えない（修正が必要なら別 PR で明示）

### よくある質問 (FAQ)
Q. プレリリース (beta 等) は？
A. 現状未運用。必要になったら `preid` を指定すれば `1.2.3-beta.1` のような形式で作成可能。

Q. CHANGELOG の箇条書きを自動生成したい。
A. 将来的にコミットログパースのステップ追加で対応可能です（要望歓迎）。

### 今後の拡張アイデア
- コミットログ自動要約による CHANGELOG 生成
- リリース時に Android / 他プラットフォーム成果物を自動ビルド & アップロード
- 依存パッケージ差分検出の自動挿入

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
