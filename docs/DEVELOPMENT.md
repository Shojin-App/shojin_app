# 開発・コントリビューションガイド

バグ報告、機能提案、プルリクエストを歓迎します。

## バグ報告・機能要望

[Issues](https://github.com/Shojin-App/shojin_app/issues)から報告してください。

## 開発への参加

1. リポジトリをフォークします。
2. 変更用ブランチを作成します。

   ```bash
   git checkout -b feature/your-feature-name
   # または
   git checkout -b bugfix/issue-number
   ```

3. 変更を実装し、テストします。
4. 本リポジトリの`dev`ブランチに対してプルリクエストを作成します。

プルリクエストには、変更内容、変更理由、関連Issue番号を記載してください。

## 開発環境のセットアップ

Flutter SDKは[mise](https://mise.jdx.dev/)の`http:flutter`バックエンドで管理しています。FVMは使用しません。

1. miseをインストールし、使用するシェルで有効化します。
2. リポジトリのルートでFlutter SDKをインストールします。
3. Dartパッケージを取得します。

```bash
mise install
flutter pub get
```

Flutterのバージョンは`mise.toml`で固定されています。miseをシェルで有効化していない場合は、次のように`mise exec --`を付けて実行できます。

```bash
mise exec -- flutter pub get
mise exec -- flutter analyze
mise exec -- flutter test
```

## コーディングと検証

- 既存のコードスタイルと設計に合わせてください。
- コードを変更した場合は`flutter analyze`を実行してください。
- 関連するテストを更新し、新機能には可能な限りテストを追加してください。

```bash
flutter analyze
flutter test
```

## fastlaneによるAndroidビルド

Android向けの解析、テスト、APK/AABビルドにfastlaneを使用できます。Google Playへの自動アップロード用laneは提供していません。

### 前提

- mise
- Ruby
- Bundler

WindowsではRubyInstallerまたはWSLの利用を推奨します。

### セットアップ

```bash
bundle install
```

### 主なlane

```bash
bundle exec fastlane android analyze
bundle exec fastlane android test
bundle exec fastlane android apk
bundle exec fastlane android apk flavor:fdroid build_type:release
bundle exec fastlane android aab
```

`flavor:`には`oss`または`fdroid`を指定できます。

### 環境変数

`ANDROID_PACKAGE_NAME`でパッケージ名を指定できます。省略時は`io.github.shojinapp.kyopro`です。Play Console関連の環境変数は不要です。

署名鍵は各自の環境に合わせて設定してください。リポジトリの標準設定ではDebug署名を使用します。
