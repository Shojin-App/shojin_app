# インストール・ビルドガイド

## GitHub Releasesからインストール

ビルド済みのAPKは[GitHub Releases](https://github.com/Shojin-App/shojin_app/releases)からダウンロードできます。

## ソースからビルド

### 前提

- [Flutter SDK](https://docs.flutter.dev/get-started/install)がインストール済みであること
- Android向けにビルドする場合はAndroid SDKが利用可能であること

### 手順

```bash
git clone https://github.com/Shojin-App/shojin_app.git
cd shojin_app
flutter pub get
flutter run
```

リリースAPKを作成する場合:

```bash
flutter build apk --release
```

その他のプラットフォームやオプションは[Flutter公式ビルドドキュメント](https://docs.flutter.dev/deployment)を参照してください。

## F-Droid対応版

F-Droidフレーバー（`fdroid`）では、F-Droid Inclusion Policyに合わせて次の機能を制限します。

| 機能 | 通常ビルド | F-Droidビルド |
| --- | --- | --- |
| アプリ内でのAPKダウンロード・自己更新 | 有効（ユーザー設定可） | 無効 |
| 起動時の自動更新チェック | 表示 | 非表示 |
| オンラインフォント | 利用可 | 無効 |
| 外部APKのダウンロード | 有効 | 無効 |

自己更新関連クラス（`AutoUpdateManager`、`UpdateManager`）はF-Droidビルドでは早期returnするため、APKを取得・実行しません。Google Fontsもオンラインから取得せず、同梱フォントまたはシステムフォントを使用します。

### ビルド手順

```bash
# 推奨
./build_fdroid.sh

# 手動
flutter build apk \
  --dart-define=FDROID_BUILD=true \
  --dart-define=ENABLE_SELF_UPDATE=false \
  --dart-define=ENABLE_ONLINE_FONTS=false \
  --flavor=fdroid \
  --release
```

### F-Droid申請前チェックリスト

- [ ] `git tag vX.Y.Z`と`pubspec.yaml`の`version`が一致している
- [ ] 「設定 > 更新設定」に自己更新UIが表示されない
- [ ] 不要な外部サービスへのネットワーク通信がない
- [ ] `flutter analyze`と`flutter test`が成功する
- [ ] `FONT_LICENSES.md`およびライセンス表示画面へアクセスできる

