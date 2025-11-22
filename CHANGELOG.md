## [Unreleased]

## [1.2.0] - 2025-11-22

__AUTO_CHANGELOG_PLACEHOLDER__


## [1.1.11] - 2025-09-28

- 🔧 chore: release.yamlのフォーマットを統一し、可読性を向上
- 🔧 chore: release.yamlのイベントトリガーを更新し、タグプッシュを追加
- 🐛 fix: CHANGELOGの生成ロジックを改善し、不要なコミットメッセージを除外
- ✨ feat: CHANGELOG.mdに自動生成された変更点を注入する機能を追加
- ✨ feat: FlutterのセットアップとOSSライセンスファイルの生成を追加
- 🔧 chore: バージョンを1.1.8に更新
- ♻️  refactor: PR作成ロジックを改善し、リモートブランチの存在確認を追加
- ♻️  refactor: PR作成ロジックを改善し、差分チェックを追加
- ♻️  refactor: code for improved readability and consistency
- ♻️  refactor: and enhance various components
- 🔧 chore: update shojin_app version to 1.1.3
- 🔧 chore: prepare release workflow with force update option
- 🔧 chore: 不要なブランチ指定を削除
- 🔧 chore: Gitユーザーの設定を追加
- 🔧 chore: share_plusのバージョンを12.0.0に更新
- 🔧 chore: release-pleaseワークフローを削除
- 🔧 chore: リリース運用のフローとコミット規約を更新
- 🔧 chore: prepare release workflowの整形とコメントの追加
- ✨ feat: リリース準備と公開ワークフローを追加 リリース準備と公開のための新しいGitHub Actionsワークフローを追加しました。これにより、バージョンの自動計算、CHANGELOGの更新、GitHubリリースの作成が可能になります。
- 🧱 build(deps): bump share_plus from 11.1.0 to 12.0.0


## [1.1.10] - 2025-09-28

- 🐛 fix: CHANGELOGの生成ロジックを改善し、不要なコミットメッセージを除外
- ✨ feat: CHANGELOG.mdに自動生成された変更点を注入する機能を追加
- ✨ feat: FlutterのセットアップとOSSライセンスファイルの生成を追加
- 🔧 chore: バージョンを1.1.8に更新
- ♻️  refactor: PR作成ロジックを改善し、リモートブランチの存在確認を追加
- ♻️  refactor: PR作成ロジックを改善し、差分チェックを追加
- ♻️  refactor: code for improved readability and consistency
- ♻️  refactor: and enhance various components
- 🔧 chore: update shojin_app version to 1.1.3
- 🔧 chore: prepare release workflow with force update option
- 🔧 chore: 不要なブランチ指定を削除
- 🔧 chore: Gitユーザーの設定を追加
- 🔧 chore: share_plusのバージョンを12.0.0に更新
- 🔧 chore: release-pleaseワークフローを削除
- 🔧 chore: リリース運用のフローとコミット規約を更新
- 🔧 chore: prepare release workflowの整形とコメントの追加
- ✨ feat: リリース準備と公開ワークフローを追加 リリース準備と公開のための新しいGitHub Actionsワークフローを追加しました。これにより、バージョンの自動計算、CHANGELOGの更新、GitHubリリースの作成が可能になります。
- 🧱 build(deps): bump share_plus from 11.1.0 to 12.0.0


## [1.1.9] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.8] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.7] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.6] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.5] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.4] - 2025-09-28

- (placeholder) Describe changes here


## [1.1.3] - 2025-09-28

- (placeholder) Describe changes here


# Changelog

All notable changes to this project will be documented in this file.
This file is maintained automatically by release-please (Conventional Commits).

## [1.1.2](https://github.com/Shojin-App/shojin_app/compare/v1.1.2...v1.1.2) (2025-09-27)


### Features

* add F-Droid flavor with self-update management and permissions adjustments ([05c136f](https://github.com/Shojin-App/shojin_app/commit/05c136fd9eb93c09c611e47e0c9c8909612489dd))
* add flavor input for APK builds and set default flavor to 'oss' ([76e2af3](https://github.com/Shojin-App/shojin_app/commit/76e2af33aadcb2e2a6f7ca672d9ac851467899d0))
* Add Gemini workflows for invoking, reviewing, scheduled triage, and issue triage ([4a794b4](https://github.com/Shojin-App/shojin_app/commit/4a794b4071d684103c2478169c8f2240dc5cbfe2))
* Add problem recommendation feature ([5633f49](https://github.com/Shojin-App/shojin_app/commit/5633f4969708f7d5f1334819f5f01d6e983a5f9c))
* analyzerパッケージのバージョンを追加 ([ba501a7](https://github.com/Shojin-App/shojin_app/commit/ba501a7970eaba103a5b61c03e234e1047a6b4da))
* AndroidManifest.xmlにrequestLegacyExternalStorage属性を追加し、ストレージアクセス権限を更新 ([2388b7c](https://github.com/Shojin-App/shojin_app/commit/2388b7ce447bd285619122b78fbf4f571c959d2d))
* AndroidManifest.xmlに新しいインテントフィルターを追加し、ストレージ管理の権限を更新 ([e63e494](https://github.com/Shojin-App/shojin_app/commit/e63e494a2cfad8920ebb9e6199df0d340e2bdb9c))
* Androidパッケージインストーラーとマネージャーを依存関係に追加し、インストール処理を改善 ([b364898](https://github.com/Shojin-App/shojin_app/commit/b364898f04eeb48851ba98348c8f44649fc91bd2))
* animationsパッケージを追加し、関連するインポートを更新 ([5cf269b](https://github.com/Shojin-App/shojin_app/commit/5cf269b1794ecaadf4da6d36db337948091d3c46))
* APKインストール機能をMethodChannelを通じて実装し、エラーハンドリングを強化 ([16323e8](https://github.com/Shojin-App/shojin_app/commit/16323e888e35962b6e33d8988a7ff6c18b09516a))
* APKインストール用のファイル処理を追加し、手動インストールガイダンスを実装 ([c422ba1](https://github.com/Shojin-App/shojin_app/commit/c422ba1a0385141175aea9d409987a0956a169db))
* AtCoderユーザー名の設定と保存機能を追加 ([0c608ee](https://github.com/Shojin-App/shojin_app/commit/0c608eeede80f8f096efc2f035fcf30e88a6d1e7))
* AtCoderレーティングに基づくテーマ色の適用機能を追加 ([ecdabc2](https://github.com/Shojin-App/shojin_app/commit/ecdabc2370b1b3f52cb7bdcaa8ce7b58aa70ab71))
* AtCoderレーティング情報の取得機能を追加し、レート表示を改善 ([15a668b](https://github.com/Shojin-App/shojin_app/commit/15a668b7afa7feed0c509b946d957aebb508e3f5))
* **ci:** APKのビルドタイプ（単一/分割）を選択可能に ([59a1d73](https://github.com/Shojin-App/shojin_app/commit/59a1d73e79af039dc9afdad93ae66d130452d679))
* Contestモデルにステータスフィールドを追加し、コンテストの状態を管理 ([80f341e](https://github.com/Shojin-App/shojin_app/commit/80f341e4bbeda6af7b7a8fcac5746689785b2d1e))
* coreLibraryDesugaringを有効にし、依存関係を追加 ([43e06b5](https://github.com/Shojin-App/shojin_app/commit/43e06b552cd7d2003966d03b29f35b11ec54ea18))
* EnhancedUpdateServiceを削除し、関連するクラスと機能を整理 ([f352674](https://github.com/Shojin-App/shojin_app/commit/f352674069f8184dd01f90a802a96a8345af5dcf))
* F-Droidビルドにおける自己アップデート機能の無効化と関連設定の追加 ([a86ac76](https://github.com/Shojin-App/shojin_app/commit/a86ac7604b8c7e02a4f2c502938f3693979b397f))
* flutter_local_notificationsパッケージを追加し、pubspec.yamlとpubspec.lockを更新 ([2a3114a](https://github.com/Shojin-App/shojin_app/commit/2a3114a8f621a61aaa493f7e40c295bf726dfcaa))
* GitHubアイコンを追加し、設定画面のソーシャルメディア項目を更新 ([45bb973](https://github.com/Shojin-App/shojin_app/commit/45bb97347b89d075f3e22b6819e5ccce535dc367))
* HackGenフォントファミリーを追加し、pubspec.yamlを更新 ([f68fd63](https://github.com/Shojin-App/shojin_app/commit/f68fd63b155df16950b52aa3c964bf19c780c7a5))
* Implement code history feature ([1957f38](https://github.com/Shojin-App/shojin_app/commit/1957f3854c9a5a7874d281e4097accb6a7825d5f))
* Implement GitHub Release Auto-Update Functionality ([b69e196](https://github.com/Shojin-App/shojin_app/commit/b69e1968ad0512671e986df51423bc857bc25d9b))
* MainActivityの完全修飾名を設定し、pubspec.yamlにホームページを追加 ([6d1a34d](https://github.com/Shojin-App/shojin_app/commit/6d1a34d6e4af25d90347db5e2294086a5a786486))
* MaterialYou使用時のコントラスト改善のため、テーマプロバイダーを利用して背景色とテキスト色を調整 ([2812125](https://github.com/Shojin-App/shojin_app/commit/281212583d636cf8177763ef0fa6d2450ce8fc2c))
* minutesBeforeをList&lt;int&gt;に変更し、複数の通知時間を指定可能に ([dbab52d](https://github.com/Shojin-App/shojin_app/commit/dbab52dc01d2183ca960dd3d29625ca54f9d885b))
* release-pleaseを用いたバージョン管理とCHANGELOG生成の自動化を追加 ([7feda7c](https://github.com/Shojin-App/shojin_app/commit/7feda7ca66312c76c6718f9dcff892d21bc66a36))
* **services:** Implement polite scraping with caching and User-Agent ([d0b92d7](https://github.com/Shojin-App/shojin_app/commit/d0b92d7285b7fd451511a7bd428dba5e3603e2d9))
* **services:** 丁寧なスクレイピングのためのキャッシュとUser-Agentを実装 ([355d790](https://github.com/Shojin-App/shojin_app/commit/355d79038f66dbeb8efe11dc633f0cb5569e03eb))
* SVGアイコンを追加し、設定画面のTwitterアイコンを更新 ([f2598ef](https://github.com/Shojin-App/shojin_app/commit/f2598ef1042bf02e73bd2e1b2bec39bef4ded9f4))
* TeX数式レンダリング機能を追加し、数式の自動検出を実装 ([aa96a79](https://github.com/Shojin-App/shojin_app/commit/aa96a799961dec5edc82391a1ccc31ceaa7fd2a4))
* UpdateManagerクラスを変更し、APKインストールプロセスを改善。エラーハンドリングとダウンロード進捗の通知を追加。 ([c15f54b](https://github.com/Shojin-App/shojin_app/commit/c15f54bc11518422a392445858f82a62cb35e713))
* webview_flutter_wkwebviewプラグインを生成されたプラグイン登録に追加 ([e6df96a](https://github.com/Shojin-App/shojin_app/commit/e6df96a56abb17941129bc53baaaa69dc76ef684))
* YouTubeアイコンを追加し、設定画面のソーシャルメディア項目を更新 ([dbf24ca](https://github.com/Shojin-App/shojin_app/commit/dbf24cac73bea33f93cb96ae9464e87fc7c19615))
* アダプティブアイコンのインセットを32%に変更し、関連するアイコンを更新 ([ece9306](https://github.com/Shojin-App/shojin_app/commit/ece9306a7aaab6d0df1503fe26b43991caee969a))
* アダプティブアイコンのモノクロームバージョンを追加し、関連する設定を更新 ([341c620](https://github.com/Shojin-App/shojin_app/commit/341c6202da381b46972a89b414d8268d0cfe1ee5))
* アップデートダイアログの初期化フラグを追加し、権限チェックの実装を改善 ([b34ff21](https://github.com/Shojin-App/shojin_app/commit/b34ff214263ce17d8ef445510cde604c67d1af86))
* アップデート試行の記録と手動インストールガイダンスを実装 ([83c817b](https://github.com/Shojin-App/shojin_app/commit/83c817b5d43c6f2eade3dd86f1127de0d49d1e2c))
* アプリケーションIDを変更し、APKインストール機能を強化 ([32fe9e1](https://github.com/Shojin-App/shojin_app/commit/32fe9e1d82bb01c613fc1f8814499b51d0bf71b9))
* アプリのアイコンとアダプティブアイコンの追加 ([a4bcf47](https://github.com/Shojin-App/shojin_app/commit/a4bcf47643b0049788525da350fe7054fd66a21e))
* アプリ情報を取得する機能を追加 ([2e36031](https://github.com/Shojin-App/shojin_app/commit/2e360312cc1812586cdb2b3d5c72711fa533af8f))
* インストール処理を追加し、APKファイルを開く機能を実装 ([efd7f89](https://github.com/Shojin-App/shojin_app/commit/efd7f8954341f9dd43203a73e590fcbc76b8380a))
* カスタムSliverAppBarを追加し、設定画面のUIを改善 ([99257ac](https://github.com/Shojin-App/shojin_app/commit/99257accd1a6e8df4f9ad7c7426f09744d1b6412))
* カスタムコードのフォントファミリーに対応し、フォント選択ロジックを改善 ([80e2146](https://github.com/Shojin-App/shojin_app/commit/80e21461eaba826aefa1774fb29e7946b3f3c930))
* カスタムテーマを追加し、設定画面のMaterial Youオプションの説明を改善 ([40bbcee](https://github.com/Shojin-App/shojin_app/commit/40bbceeae19a6c9b58e9261355ef47596a80532e))
* キャッシュ機能付きダウンロードサービスとアップデート情報クラスを追加 ([04aa22f](https://github.com/Shojin-App/shojin_app/commit/04aa22f703289d1fbec10be3217579d859cf3a36))
* キャッシュ機能付きダウンロードサービスを追加し、ストレージ権限を不要にする ([d58be88](https://github.com/Shojin-App/shojin_app/commit/d58be8832c3a9e8f807e46f65ec951d02d8eac9d))
* コンテスト名をProblemモデルに追加し、詳細画面に表示する処理を実装 ([2fee73e](https://github.com/Shojin-App/shojin_app/commit/2fee73ed248537d0f25a5b1329d24d59b517ca4f))
* コンテスト情報を取得するサービスを実装 ([29ccd5e](https://github.com/Shojin-App/shojin_app/commit/29ccd5eb0926a500f7d0e5f190e3b8fa51e0965b))
* コンテスト情報を管理するContestProviderを追加し、次回のABCコンテストや今後のコンテストを取得する機能を実装 ([80f341e](https://github.com/Shojin-App/shojin_app/commit/80f341e4bbeda6af7b7a8fcac5746689785b2d1e))
* コンテスト情報を表示するUpcomingContestsScreenを追加し、タブでABCとすべてのコンテストを切り替え可能に ([80f341e](https://github.com/Shojin-App/shojin_app/commit/80f341e4bbeda6af7b7a8fcac5746689785b2d1e))
* スタートアップおよび手動アップデートチェックのデバッグ出力を追加 ([1d4f14a](https://github.com/Shojin-App/shojin_app/commit/1d4f14ae8d0f2e1348f2c4ac55a8d2d67e8779e1))
* ストレージ権限の要求をダイアログ付きで実装し、ダウンロード処理を改善 ([3b28c54](https://github.com/Shojin-App/shojin_app/commit/3b28c547a6d172bd5038720854140b803bf7fa00))
* ダウンロードキャンセル機能を追加し、プログレス状態のリセットを実装 ([7100cf8](https://github.com/Shojin-App/shojin_app/commit/7100cf88aba837c5025484a71738bd46cd837b03))
* デバッグ情報を追加して進捗更新をログに記録 ([9f31550](https://github.com/Shojin-App/shojin_app/commit/9f3155094d877443849125a0f74cfaedcd7deec6))
* ナビゲーションバーのテーマを追加し、透明背景とカスタムスタイルを設定 ([a1a8340](https://github.com/Shojin-App/shojin_app/commit/a1a834077a2a6b9b95117dfe00d01e015eb781d4))
* パッケージ名をio.github.tsukuba-denden.shojin_appに変更 ([9077313](https://github.com/Shojin-App/shojin_app/commit/90773137e9be85b4a614472f11a16a6310c01a62))
* プライバシーポリシーと利用規約のセクションを設定画面に追加 ([b34a9ee](https://github.com/Shojin-App/shojin_app/commit/b34a9eec96fe65a039f96016879528ad7520b6ed))
* プログレスログのデバッグ出力をコメントアウト ([3e9eb6e](https://github.com/Shojin-App/shojin_app/commit/3e9eb6e2c0889d24ac5d61faa6e7b73b74adc56b))
* ホーム画面のリマインダー設定ボタンを追加し、UIを改善 ([0dc6f29](https://github.com/Shojin-App/shojin_app/commit/0dc6f2965aea3ab37b644bd3cb7d1e88523413c8))
* ボタンのレイアウトを改善し、横幅を均等に設定 ([3921033](https://github.com/Shojin-App/shojin_app/commit/3921033e48b5f55bb907dd95f9a4457417455199))
* ライセンススナップショットのチェックと自動更新ワークフローを追加 ([ec9ba8b](https://github.com/Shojin-App/shojin_app/commit/ec9ba8bd5c2b83224403a42e943c7b04bb8955b9))
* リマインダー機能を追加し、関連するプロバイダーとサービスを実装 ([3957dfb](https://github.com/Shojin-App/shojin_app/commit/3957dfbb15bb82c95a4f37968ac1d76f00ea45fd))
* リマインダー設定の保存処理を改善し、UIの更新を統合 ([742096b](https://github.com/Shojin-App/shojin_app/commit/742096bbfd5d9b2d12f1f04f2f347e0de30a31a6))
* リマインダー設定画面を追加し、通知サービスを初期化 ([b1e8058](https://github.com/Shojin-App/shojin_app/commit/b1e80584597cfb9778798f04b4d63e0f4bb86b59))
* リリースAPK用のワークフローを追加 ([2f13f4a](https://github.com/Shojin-App/shojin_app/commit/2f13f4a9f9f405a98bc6794630d50ef2c4d4295f))
* ロードマップセクションを追加 ([ce6da68](https://github.com/Shojin-App/shojin_app/commit/ce6da68a626bf3c0b03df0382968dc063ee689c9))
* 入出力エリアのデザインを統一し、エラーメッセージ表示を改善 ([4b240df](https://github.com/Shojin-App/shojin_app/commit/4b240df93caf1f5e617de28ad37c0716260e96a7))
* 入出力エリアのレイアウトを改善し、ボタン配置をリファクタリング ([05724ca](https://github.com/Shojin-App/shojin_app/commit/05724cab2cc9a0356dad402f2640abc021e40015))
* 入力セクションの内容をクリーンアップし、数式をTeX形式で表示する処理を追加 ([7177308](https://github.com/Shojin-App/shojin_app/commit/7177308c9185e2d06822f5475e2680a1063d9499))
* 問題詳細画面への遷移機能を追加し、レート表示を改善 ([b01071c](https://github.com/Shojin-App/shojin_app/commit/b01071cb6691f29570c28afb144365d3764776d5))
* 指定されたパスにソースコードを保存するように変更しました。 ([2498af3](https://github.com/Shojin-App/shojin_app/commit/2498af3bb84a2730824073b6d60de54d02062d02))
* 推薦条件の下限/上限を設定する入力フィールドを追加 ([a77a270](https://github.com/Shojin-App/shojin_app/commit/a77a2705ed96eedba66b915429d7684ff124b1a5))
* 新しいホーム画面を作成し、カスタムスライバーアプリバーを追加して次回のコンテスト情報を表示 ([cf2cfde](https://github.com/Shojin-App/shojin_app/commit/cf2cfde12accfef0fea72415e945c0e02b79052d))
* 新しいホーム画面を作成し、次回のコンテスト情報を表示するカードを追加 ([29ccd5e](https://github.com/Shojin-App/shojin_app/commit/29ccd5eb0926a500f7d0e5f190e3b8fa51e0965b))
* 次回のABCコンテストを表示するNextABCContestWidgetを追加 ([80f341e](https://github.com/Shojin-App/shojin_app/commit/80f341e4bbeda6af7b7a8fcac5746689785b2d1e))
* 現在のレートを表示する機能を追加 ([2d42596](https://github.com/Shojin-App/shojin_app/commit/2d4259670a9016dddf62bb5c06ea572a8129df7c))
* 現在のレート表示を改善し、レートバッジを追加 ([937ce4d](https://github.com/Shojin-App/shojin_app/commit/937ce4d66686a7c9dc778449a9c03cdcda919a20))
* 現在の問題のタイトルとコンテスト名を表示するUIを追加 ([8a1fe67](https://github.com/Shojin-App/shojin_app/commit/8a1fe6723a4ac879af7ee3a47c34bdf12dd7d643))
* 自動更新管理機能を追加し、関連するサービスとダイアログを実装 ([d700bd1](https://github.com/Shojin-App/shojin_app/commit/d700bd1f76a1c876d700d047bc72e22da5ce203b))
* 設定画面にエクスポート/インポート機能を追加し、アップデート通知の設定を実装 ([9979129](https://github.com/Shojin-App/shojin_app/commit/99791292df0560f8d73dc0fec71c7ad4ba0a5ccd))
* 設定画面に新しいセクションを追加し、アップデート機能を強化 ([c3ed7fc](https://github.com/Shojin-App/shojin_app/commit/c3ed7fc39f66962c46e5b6722dee0ef2bcb559fa))
* 設定画面のUIを改善し、Google Fontsを追加 ([da3d674](https://github.com/Shojin-App/shojin_app/commit/da3d674b1df463ca762ced32535fea8531a19250))
* 設定画面のフォントをGoogle Noto Sans JPに変更し、アプリ情報のコピー機能を追加 ([bf9d8e9](https://github.com/Shojin-App/shojin_app/commit/bf9d8e9e282990d221e7c4c0979b655f79988d69))
* 通知時間の管理を改善し、複数の通知時間を追加できるように変更 ([c4ecfd8](https://github.com/Shojin-App/shojin_app/commit/c4ecfd8df84acaa8a6fdff829cd9b250ceb8f4da))
* 通知時間の選択機能を追加し、カスタム入力をサポート ([640ef20](https://github.com/Shojin-App/shojin_app/commit/640ef20da1d061c5e8ccdafd60379bed23b8193b))
* 開始時刻の表示をローカルタイムに変更し、曜日付きの詳細表示を追加 ([6b9b0c3](https://github.com/Shojin-App/shojin_app/commit/6b9b0c322a4cd8c982d31218b6a06366cf8e30f3))


### Bug Fixes

* _imagePixelFuturesの型を変更し、リスナーの初期化を修正 ([70d8ea2](https://github.com/Shojin-App/shojin_app/commit/70d8ea29f9aa0bc482256b9d4b13e4f7528631bf))
* app_localizations.dartのインデントを修正し、コメントを整理 ([726eb4c](https://github.com/Shojin-App/shojin_app/commit/726eb4c83c3b16f605c1c335e41df5377083b6f6))
* browser_screen.dartの不要なインポートを削除 ([726eb4c](https://github.com/Shojin-App/shojin_app/commit/726eb4c83c3b16f605c1c335e41df5377083b6f6))
* **build.yaml:** 'flutter analyze'コマンドに'--no-fatal-warnings'オプションを追加 ([8ee4253](https://github.com/Shojin-App/shojin_app/commit/8ee4253094ab4805b06cbe467fff067cd742beb0))
* **build.yaml:** 'flutter analyze'コマンドのエラーを無視するオプションを追加 ([89439e7](https://github.com/Shojin-App/shojin_app/commit/89439e71f357badb8de745a57ecf1e546299e007))
* **build.yaml:** update workflow name and add analyze & test job with caching ([5199208](https://github.com/Shojin-App/shojin_app/commit/5199208e0ae961def54acaf7a5ae35b2c14b75af))
* Contest.fromYamlメソッドにnullチェックを追加し、必須フィールドが不足している場合にエラーをスローするように変更 ([60af59a](https://github.com/Shojin-App/shojin_app/commit/60af59a040af20264e96d05db48553138ed5fa20))
* correct indentation in AndroidManifest.xml for consistency ([af5f50b](https://github.com/Shojin-App/shojin_app/commit/af5f50ba94bb5805bf32110041e84b5484590f7a))
* dart.flutterSdkPathの設定を削除 ([2c45d20](https://github.com/Shojin-App/shojin_app/commit/2c45d20b30b2662e18c80e4279d59380f074707c))
* device_info_plusのバージョンを11.5.0から12.1.0に更新 ([8b83e4c](https://github.com/Shojin-App/shojin_app/commit/8b83e4ce4ba4162e3600716d52e41098b9b26017))
* **editor_screen:** close mismatched brackets and simplify error output block ([576fd5e](https://github.com/Shojin-App/shojin_app/commit/576fd5ed50b57327187c255025815259059ba483))
* **editor_screen:** remove 'runTests' action from toolbar menu ([66a76f1](https://github.com/Shojin-App/shojin_app/commit/66a76f157adce985ed9f97c06cf38eceb1ea02d2))
* **editor_screen:** 修正された括弧の不一致を解消し、コードの可読性を向上 ([ba43d71](https://github.com/Shojin-App/shojin_app/commit/ba43d71fa0ae99eef10b417fd8e3c6c0fe7acd1d))
* **editor_screen:** 標準入力と出力の表示を横並びにし、UIを改善 ([e0b5175](https://github.com/Shojin-App/shojin_app/commit/e0b51759f44cb996de9cd2ca83ebe69dcfae0e83))
* ensure APK installation is disabled for F-Droid builds ([d78050b](https://github.com/Shojin-App/shojin_app/commit/d78050bd3f8d74242973e938c10484869d4d456f))
* F-Droid版のフォント利用に関する説明を明確化 ([2e5bd57](https://github.com/Shojin-App/shojin_app/commit/2e5bd5705cba5c54033354a1f2c89e91e297f41c))
* flutter_lintsとlintsパッケージのバージョンを更新し、pubspec.lockを整理 ([726eb4c](https://github.com/Shojin-App/shojin_app/commit/726eb4c83c3b16f605c1c335e41df5377083b6f6))
* flutter_markdownをflutter_markdown_plusに更新し、バージョンを1.0.3に変更 ([be849bc](https://github.com/Shojin-App/shojin_app/commit/be849bc7eb8b07ff0de17c1a3a6f15f69138c7c9))
* flutter_markdownをflutter_markdown_plusに移行し、バージョンを更新 ([4282cb2](https://github.com/Shojin-App/shojin_app/commit/4282cb2e569993b876dfa749089853310873a2e3))
* Flutterフレーバー用のVS Code起動設定を追加 ([5a55806](https://github.com/Shojin-App/shojin_app/commit/5a55806f4cb03f06632d87776cefbd2a71cbbc90))
* format code and improve readability in multiple files ([9826861](https://github.com/Shojin-App/shojin_app/commit/9826861467f754ab46ae2d250b10ae28c2d104aa))
* GitHub Copilotのコミットメッセージ生成指示を日本語で追加 ([87bbbcb](https://github.com/Shojin-App/shojin_app/commit/87bbbcb438bc79ff7727b1fab42d41d665ac0bab))
* image_pixelsを追加し、palette_generatorを削除 ([14dd4f6](https://github.com/Shojin-App/shojin_app/commit/14dd4f601c1da0364d5d3a507ecaffdea2544f0c))
* intlパッケージのバージョンをflutter_localizationsとの競合を解決するために変更 ([72ce022](https://github.com/Shojin-App/shojin_app/commit/72ce022bfa057fe274b3a08f6b6d2117b0883b0f))
* palette_generatorを削除し、依存関係を整理 ([f9de975](https://github.com/Shojin-App/shojin_app/commit/f9de9757f46612115f16052d7ebf5d5edb47ecaa))
* pubspec.lockの依存関係を更新し、バージョンを最新にしました ([c577940](https://github.com/Shojin-App/shojin_app/commit/c5779401f725a174ce00b838a7c8ea31115cb42e))
* pubspec.yamlからtimezoneパッケージの依存関係を削除 ([21c479d](https://github.com/Shojin-App/shojin_app/commit/21c479d24f409e7ef82a55d999798969e45a325e))
* pubspec.yamlにyamlパッケージを追加 ([29ccd5e](https://github.com/Shojin-App/shojin_app/commit/29ccd5eb0926a500f7d0e5f190e3b8fa51e0965b))
* pubspec.yamlのhttpパッケージの依存関係を修正 ([80f341e](https://github.com/Shojin-App/shojin_app/commit/80f341e4bbeda6af7b7a8fcac5746689785b2d1e))
* pubspec.yamlのバージョンを0.4.0-Betaから0.6.0-Betaに更新し、依存関係のコメントを整理 ([f362993](https://github.com/Shojin-App/shojin_app/commit/f3629936361dee65c01462f9a4ea8a4eb85b8b27))
* pubspec.yamlの不要な空白を削除 ([0ef2651](https://github.com/Shojin-App/shojin_app/commit/0ef26515c8d60eb556d27619c8a6f77d9958be5f))
* README.mdにパッケージ名変更に関する重要な注意事項を追加し、ブラウザ機能の表現を修正 ([6d81060](https://github.com/Shojin-App/shojin_app/commit/6d810606be3bd3ed31da924a8742455b396c9b9c))
* README.mdに参考リポジトリのリンクを追加 ([6a7703c](https://github.com/Shojin-App/shojin_app/commit/6a7703c149aed88207cc0c90d32d5f855dbf308a))
* README.mdに商標に関するセクションを追加 ([4647ea2](https://github.com/Shojin-App/shojin_app/commit/4647ea2a125831154b70a771855fecf3d5a9bdbd))
* README.mdのリリース情報セクションのフォーマットを修正 ([2068317](https://github.com/Shojin-App/shojin_app/commit/2068317df949be79bf4bad8fe35bf1b41b14526b))
* README.mdの不要な空行を削除 ([e39d68e](https://github.com/Shojin-App/shojin_app/commit/e39d68ed10f1d3ab7f71d5ce6ce824c759c123c8))
* README.mdの内容を整理し、重複を削除 ([99e0578](https://github.com/Shojin-App/shojin_app/commit/99e05787b41839273c3b0fe19b512e057b08aca4))
* README.mdの表記を修正し、F-Droidビルドに関する説明を明確化 ([0bd888f](https://github.com/Shojin-App/shojin_app/commit/0bd888f80bfcc427d8d5bec99f8996f7196e0980))
* README.mdの重要な注意事項の表現を修正 ([fda1368](https://github.com/Shojin-App/shojin_app/commit/fda1368830befebe3d8578e2e10d88444002c66c))
* release-please-actionの使用をgoogle-github-actionsからgoogleapisに変更 ([7f64768](https://github.com/Shojin-App/shojin_app/commit/7f6476836a821ccc7d18dbad57f3d87c5552c6b9))
* remove AGENTS.md and GEMINI.md documentation files ([703456f](https://github.com/Shojin-App/shojin_app/commit/703456f14303e2e944698bbabf5afcaf3459acab))
* remove Ask DeepWiki badge from README ([6f4c536](https://github.com/Shojin-App/shojin_app/commit/6f4c5363b33cd22ae0fed68f92980e90bb97460a))
* remove Git dependencies for F-Droid compliance and replace with internal stub ([069f146](https://github.com/Shojin-App/shojin_app/commit/069f1466a2ae6e67ab12592bb4f0a5e2357cdcc7))
* set kotlin incremental compilation to false in gradle.properties ([76e2af3](https://github.com/Shojin-App/shojin_app/commit/76e2af33aadcb2e2a6f7ca672d9ac851467899d0))
* shojin_appのバージョンを1.1.0から1.1.2に更新 ([2b767fc](https://github.com/Shojin-App/shojin_app/commit/2b767fcd9964666a90cef490fa1914b75c88011c))
* timezoneパッケージの依存関係を修正し、notification_service.dart内のインポートを更新 ([77bbb3c](https://github.com/Shojin-App/shojin_app/commit/77bbb3c8c5813f4f817ace5f7190cbb57679b518))
* update dependencies to specific commits for stability and F-Droid compatibility ([c2a737a](https://github.com/Shojin-App/shojin_app/commit/c2a737a0d783707bad858429305c7218d1b16b24))
* update Flutter SDK path and Dart SDK version in configuration files ([205caa6](https://github.com/Shojin-App/shojin_app/commit/205caa6800fe72293530d7468cd32653e2d2772a))
* update Flutter SDK path in settings.json ([d6aaa0e](https://github.com/Shojin-App/shojin_app/commit/d6aaa0edfc10f3a777665facc3aeff0fe46ae934))
* Update intl package version to ^0.20.2 ([a6085da](https://github.com/Shojin-App/shojin_app/commit/a6085dad19217cce59e63bfeebaaca07cadfbf8c))
* update Kotlin plugin version and add build features in build.gradle.kts ([8f3044c](https://github.com/Shojin-App/shojin_app/commit/8f3044c033f9977e020513e37163cb22a37f5a25))
* update README layout for badge display ([15f823c](https://github.com/Shojin-App/shojin_app/commit/15f823c754685480f43e1b07e3af96ea4df59b1f))
* update README links to reflect repository name change ([acdfd08](https://github.com/Shojin-App/shojin_app/commit/acdfd08c1d92cbfedd7c6fe2f48b11c8ec1b7f44))
* Use CardThemeData instead of CardTheme in main.dart ([604528f](https://github.com/Shojin-App/shojin_app/commit/604528fa65b95357aa41c353c292d279aec83790))
* VSCode設定の整理とF5実行フレーバーの統一 ([7110e32](https://github.com/Shojin-App/shojin_app/commit/7110e328fbdc2b2d5fa06425e8652572bef9769b))
* アプリ内自己アップデート機能に関する説明を簡略化 ([fd7a181](https://github.com/Shojin-App/shojin_app/commit/fd7a18177c01503f4da2e1063ea597badb215d51))
* エラーハンドリングを改善し、例外を再スローするように修正 ([efd7f89](https://github.com/Shojin-App/shojin_app/commit/efd7f8954341f9dd43203a73e590fcbc76b8380a))
* コードのインデントを修正し、ローカライズのサポートを整理 ([e6df96a](https://github.com/Shojin-App/shojin_app/commit/e6df96a56abb17941129bc53baaaa69dc76ef684))
* コードの整形とローカライズのサポートを改善 ([96d98af](https://github.com/Shojin-App/shojin_app/commit/96d98af9cf685ce20e9d67c6de0286dda5f30415))
* コードの整形を行い、可読性を向上 ([f8d022d](https://github.com/Shojin-App/shojin_app/commit/f8d022d5984864633f4a9131a89dadee41aadabc))
* コードの整形を行い、可読性を向上 ([a04a334](https://github.com/Shojin-App/shojin_app/commit/a04a3343a84a80346d09d7562dbc19ba7eed31e5))
* コードの整形を行い、可読性を向上 ([4c04b2a](https://github.com/Shojin-App/shojin_app/commit/4c04b2a56267ca3e65461e30757fe2476707557b))
* コンテストタイプの判定ロジックを改善し、文字列マッチングを強化 ([cf2cfde](https://github.com/Shojin-App/shojin_app/commit/cf2cfde12accfef0fea72415e945c0e02b79052d))
* タイトル取得時にEditorialリンクを削除する処理を追加 ([3cf8bdd](https://github.com/Shojin-App/shojin_app/commit/3cf8bddc97133c596888562bada2ad5ea1c5e8ba))
* ナビゲーションバーの高さを動的に調整するロジックを修正 ([e78dfbf](https://github.com/Shojin-App/shojin_app/commit/e78dfbf050d9b676737dd3b6c96a3492ff21c22e))
* バージョン番号を0.1.0-Betaに修正 ([479fc3b](https://github.com/Shojin-App/shojin_app/commit/479fc3b3332e3a749358684a88f547eb9c5af313))
* バージョン番号を0.5.0-Betaに更新 ([c67e261](https://github.com/Shojin-App/shojin_app/commit/c67e261367b63d202d30717d63e0dd3d724eb165))
* バージョン番号を0.6.0-Betaから0.6.1-Betaに更新 ([cfa3779](https://github.com/Shojin-App/shojin_app/commit/cfa3779af5d4fdd8749ab684d224ea3486dfad22))
* バージョン番号を0.6.1-Betaから0.6.2-Betaに更新 ([42b2363](https://github.com/Shojin-App/shojin_app/commit/42b2363d23494f851c98a9a0e92b4e64f380c63a))
* バージョン番号を0.6.3-Betaから0.6.4-Betaに更新しました ([7d28a0b](https://github.com/Shojin-App/shojin_app/commit/7d28a0b21dce30f797f12bad6bb4ef872c2e059b))
* バージョン番号を1.2.0から1.1.2に変更しました ([e7149a8](https://github.com/Shojin-App/shojin_app/commit/e7149a8c025e520e5a8e37acd424b1850cc469d9))
* パッケージ名を修正 ([97babae](https://github.com/Shojin-App/shojin_app/commit/97babaed637d07fffd6da37a293ddcf6402ef0a1))
* ビルドワークフローからバージョン入力を削除し、pubspec.yamlからバージョンを読み取るように変更 ([201529a](https://github.com/Shojin-App/shojin_app/commit/201529a88ce8ecaffb6c64441ada259d8025517b))
* ビルドワークフローのリリースノート生成オプションを追加し、APKアーティファクトのダウンロード処理を改善 ([a661d20](https://github.com/Shojin-App/shojin_app/commit/a661d203fafb47b96366796ac5923082f6b64f85))
* ホームページのURLを正しいリポジトリに更新 ([a19ec7a](https://github.com/Shojin-App/shojin_app/commit/a19ec7a2aab4d76097500f11963b3210b3964ddf))
* ホームページのURLを正しいリポジトリに更新 ([3f657fa](https://github.com/Shojin-App/shojin_app/commit/3f657fa2daa52e546d66e1d8ba6d6408ff178943))
* ユーザー名の説明文を更新し、「問題推薦」を「おすすめ問題」に変更 ([2243445](https://github.com/Shojin-App/shojin_app/commit/2243445bdefa25bdd8fa222d61a796b834514ed1))
* ライセンス画面のタブを追加し、設定画面のライセンス表示を更新 ([3245906](https://github.com/Shojin-App/shojin_app/commit/32459060d4ab5bd8be0533e031e201a68d7f5dca))
* ライセンス画面の表示をタブ形式に変更し、データ取得方法を簡素化 ([6d6a9e5](https://github.com/Shojin-App/shojin_app/commit/6d6a9e58189a8721fb1b9e8af93effcc4e1dc8b3))
* ライセンス画面の表示を改善し、エラーハンドリングを追加 ([5cc3121](https://github.com/Shojin-App/shojin_app/commit/5cc3121cb29f7b93763c319ef8a895e0a058cd5a))
* リリースバージョンのデフォルト値を修正 ([a40888d](https://github.com/Shojin-App/shojin_app/commit/a40888d2b76230276b6879371bfe3b63cfe91b2d))
* リリース条件の比較を修正 ([7077149](https://github.com/Shojin-App/shojin_app/commit/7077149a1d1f73893c90a3a1c5da49c6d16a10a7))
* ワークフローのビルド設定を修正し、環境変数の使用を統一 ([d2e610d](https://github.com/Shojin-App/shojin_app/commit/d2e610d144723924bcab0c2e68129052dc6042ac))
* ワークフローの説明文を日本語から英語に変更し、コードの整形を行いました ([fd04485](https://github.com/Shojin-App/shojin_app/commit/fd04485f55234d83ba6d5bb5588aaaab03f060a7))
* 不要なインポートの整理とコメントの整形 ([85a168b](https://github.com/Shojin-App/shojin_app/commit/85a168be82ec0e38be6c75cba8fcb28e9e65ebf6))
* 依存関係のバージョンを更新し、flutter_localizationsとの競合を解決 ([9db46ef](https://github.com/Shojin-App/shojin_app/commit/9db46efbb9a6edc3bb1d6c9d21a43e9f3e37cd72))
* 修正されたアイコンの背景色のフォーマットとアダプティブアイコンの更新 ([01d8fcb](https://github.com/Shojin-App/shojin_app/commit/01d8fcbd92767c7edd864950a7009146662a31b1))
* 修正されたウィジェット状態のプロパティ名を更新 ([31b1c2a](https://github.com/Shojin-App/shojin_app/commit/31b1c2a29340fd852fe4089b2921c1e5d0770a7e))
* 修正されたコードのインデントとローカライズのサポートを整理 ([cd6c3b2](https://github.com/Shojin-App/shojin_app/commit/cd6c3b2ba7b97082d89a9932cfccee0a2b7c5bf3))
* 修正されたデフォルトバージョン値を 'v0.0.0-Beta' に更新 ([3834a38](https://github.com/Shojin-App/shojin_app/commit/3834a38d92f8e4072c0ecdce49b0636201be1dc1))
* 修正フラグのデフォルト値を設定 ([4d1f1e6](https://github.com/Shojin-App/shojin_app/commit/4d1f1e6b795d914970beb31e0563b305632556a9))
* 動的なボトムインセットを考慮したパディングの調整 ([e3cdded](https://github.com/Shojin-App/shojin_app/commit/e3cdded6470a6857ab2943258566abbe94544b65))
* 定数を使用してパフォーマンスを向上させ、UI要素の定義を明確化 ([6ecf734](https://github.com/Shojin-App/shojin_app/commit/6ecf7344e3363a8ced406f90103752ffa241fd29))
* 更新された依存関係のバージョンを反映 ([920a08f](https://github.com/Shojin-App/shojin_app/commit/920a08fc5eb44180f4b61b8ee50db427ee4520ea))
* 表示用レートの計算ロジックを修正 ([15a668b](https://github.com/Shojin-App/shojin_app/commit/15a668b7afa7feed0c509b946d957aebb508e3f5))
* 開発者セクションのExpansionTileの境界線を非表示にする ([1bb0852](https://github.com/Shojin-App/shojin_app/commit/1bb0852f350c8c10f1c1e434522bdc6e9bff65d2))


### Miscellaneous Chores

* override next release version ([39c1528](https://github.com/Shojin-App/shojin_app/commit/39c1528061d7a7d348c1c28d1ef3cf7c4b872219))

## [1.1.2](https://github.com/Shojin-App/shojin_app/compare/v1.1.1...v1.1.2) (2025-09-27)


### Features

* リリースAPK用のワークフローを追加 ([2f13f4a](https://github.com/Shojin-App/shojin_app/commit/2f13f4a9f9f405a98bc6794630d50ef2c4d4295f))


### Bug Fixes

* ワークフローの説明文を日本語から英語に変更し、コードの整形を行いました ([fd04485](https://github.com/Shojin-App/shojin_app/commit/fd04485f55234d83ba6d5bb5588aaaab03f060a7))

## [1.1.1](https://github.com/Shojin-App/shojin_app/compare/v1.1.0...v1.1.1) (2025-09-27)


### Bug Fixes

* device_info_plusのバージョンを11.5.0から12.1.0に更新 ([8b83e4c](https://github.com/Shojin-App/shojin_app/commit/8b83e4ce4ba4162e3600716d52e41098b9b26017))
* release-please-actionの使用をgoogle-github-actionsからgoogleapisに変更 ([7f64768](https://github.com/Shojin-App/shojin_app/commit/7f6476836a821ccc7d18dbad57f3d87c5552c6b9))

## [1.1.0](https://github.com/Shojin-App/shojin_app/compare/v1.0.0...v1.1.0) (2025-09-26)


### Features

* add F-Droid flavor with self-update management and permissions adjustments ([05c136f](https://github.com/Shojin-App/shojin_app/commit/05c136fd9eb93c09c611e47e0c9c8909612489dd))
* add flavor input for APK builds and set default flavor to 'oss' ([76e2af3](https://github.com/Shojin-App/shojin_app/commit/76e2af33aadcb2e2a6f7ca672d9ac851467899d0))
* Add Gemini workflows for invoking, reviewing, scheduled triage, and issue triage ([4a794b4](https://github.com/Shojin-App/shojin_app/commit/4a794b4071d684103c2478169c8f2240dc5cbfe2))
* F-Droidビルドにおける自己アップデート機能の無効化と関連設定の追加 ([a86ac76](https://github.com/Shojin-App/shojin_app/commit/a86ac7604b8c7e02a4f2c502938f3693979b397f))
* release-pleaseを用いたバージョン管理とCHANGELOG生成の自動化を追加 ([7feda7c](https://github.com/Shojin-App/shojin_app/commit/7feda7ca66312c76c6718f9dcff892d21bc66a36))
* **services:** Implement polite scraping with caching and User-Agent ([d0b92d7](https://github.com/Shojin-App/shojin_app/commit/d0b92d7285b7fd451511a7bd428dba5e3603e2d9))
* ライセンススナップショットのチェックと自動更新ワークフローを追加 ([ec9ba8b](https://github.com/Shojin-App/shojin_app/commit/ec9ba8bd5c2b83224403a42e943c7b04bb8955b9))
* ロードマップセクションを追加 ([ce6da68](https://github.com/Shojin-App/shojin_app/commit/ce6da68a626bf3c0b03df0382968dc063ee689c9))


### Bug Fixes

* correct indentation in AndroidManifest.xml for consistency ([af5f50b](https://github.com/Shojin-App/shojin_app/commit/af5f50ba94bb5805bf32110041e84b5484590f7a))
* ensure APK installation is disabled for F-Droid builds ([d78050b](https://github.com/Shojin-App/shojin_app/commit/d78050bd3f8d74242973e938c10484869d4d456f))
* F-Droid版のフォント利用に関する説明を明確化 ([2e5bd57](https://github.com/Shojin-App/shojin_app/commit/2e5bd5705cba5c54033354a1f2c89e91e297f41c))
* Flutterフレーバー用のVS Code起動設定を追加 ([5a55806](https://github.com/Shojin-App/shojin_app/commit/5a55806f4cb03f06632d87776cefbd2a71cbbc90))
* format code and improve readability in multiple files ([9826861](https://github.com/Shojin-App/shojin_app/commit/9826861467f754ab46ae2d250b10ae28c2d104aa))
* GitHub Copilotのコミットメッセージ生成指示を日本語で追加 ([87bbbcb](https://github.com/Shojin-App/shojin_app/commit/87bbbcb438bc79ff7727b1fab42d41d665ac0bab))
* README.mdにパッケージ名変更に関する重要な注意事項を追加し、ブラウザ機能の表現を修正 ([6d81060](https://github.com/Shojin-App/shojin_app/commit/6d810606be3bd3ed31da924a8742455b396c9b9c))
* README.mdに参考リポジトリのリンクを追加 ([6a7703c](https://github.com/Shojin-App/shojin_app/commit/6a7703c149aed88207cc0c90d32d5f855dbf308a))
* README.mdに商標に関するセクションを追加 ([4647ea2](https://github.com/Shojin-App/shojin_app/commit/4647ea2a125831154b70a771855fecf3d5a9bdbd))
* README.mdのリリース情報セクションのフォーマットを修正 ([2068317](https://github.com/Shojin-App/shojin_app/commit/2068317df949be79bf4bad8fe35bf1b41b14526b))
* README.mdの不要な空行を削除 ([e39d68e](https://github.com/Shojin-App/shojin_app/commit/e39d68ed10f1d3ab7f71d5ce6ce824c759c123c8))
* README.mdの内容を整理し、重複を削除 ([99e0578](https://github.com/Shojin-App/shojin_app/commit/99e05787b41839273c3b0fe19b512e057b08aca4))
* README.mdの表記を修正し、F-Droidビルドに関する説明を明確化 ([0bd888f](https://github.com/Shojin-App/shojin_app/commit/0bd888f80bfcc427d8d5bec99f8996f7196e0980))
* README.mdの重要な注意事項の表現を修正 ([fda1368](https://github.com/Shojin-App/shojin_app/commit/fda1368830befebe3d8578e2e10d88444002c66c))
* remove AGENTS.md and GEMINI.md documentation files ([703456f](https://github.com/Shojin-App/shojin_app/commit/703456f14303e2e944698bbabf5afcaf3459acab))
* remove Ask DeepWiki badge from README ([6f4c536](https://github.com/Shojin-App/shojin_app/commit/6f4c5363b33cd22ae0fed68f92980e90bb97460a))
* remove Git dependencies for F-Droid compliance and replace with internal stub ([069f146](https://github.com/Shojin-App/shojin_app/commit/069f1466a2ae6e67ab12592bb4f0a5e2357cdcc7))
* set kotlin incremental compilation to false in gradle.properties ([76e2af3](https://github.com/Shojin-App/shojin_app/commit/76e2af33aadcb2e2a6f7ca672d9ac851467899d0))
* update dependencies to specific commits for stability and F-Droid compatibility ([c2a737a](https://github.com/Shojin-App/shojin_app/commit/c2a737a0d783707bad858429305c7218d1b16b24))
* update Flutter SDK path and Dart SDK version in configuration files ([205caa6](https://github.com/Shojin-App/shojin_app/commit/205caa6800fe72293530d7468cd32653e2d2772a))
* update Flutter SDK path in settings.json ([d6aaa0e](https://github.com/Shojin-App/shojin_app/commit/d6aaa0edfc10f3a777665facc3aeff0fe46ae934))
* update Kotlin plugin version and add build features in build.gradle.kts ([8f3044c](https://github.com/Shojin-App/shojin_app/commit/8f3044c033f9977e020513e37163cb22a37f5a25))
* update README layout for badge display ([15f823c](https://github.com/Shojin-App/shojin_app/commit/15f823c754685480f43e1b07e3af96ea4df59b1f))
* update README links to reflect repository name change ([acdfd08](https://github.com/Shojin-App/shojin_app/commit/acdfd08c1d92cbfedd7c6fe2f48b11c8ec1b7f44))
* VSCode設定の整理とF5実行フレーバーの統一 ([7110e32](https://github.com/Shojin-App/shojin_app/commit/7110e328fbdc2b2d5fa06425e8652572bef9769b))
* アプリ内自己アップデート機能に関する説明を簡略化 ([fd7a181](https://github.com/Shojin-App/shojin_app/commit/fd7a18177c01503f4da2e1063ea597badb215d51))
* コードの整形を行い、可読性を向上 ([f8d022d](https://github.com/Shojin-App/shojin_app/commit/f8d022d5984864633f4a9131a89dadee41aadabc))
* コードの整形を行い、可読性を向上 ([a04a334](https://github.com/Shojin-App/shojin_app/commit/a04a3343a84a80346d09d7562dbc19ba7eed31e5))
* コードの整形を行い、可読性を向上 ([4c04b2a](https://github.com/Shojin-App/shojin_app/commit/4c04b2a56267ca3e65461e30757fe2476707557b))
* ホームページのURLを正しいリポジトリに更新 ([a19ec7a](https://github.com/Shojin-App/shojin_app/commit/a19ec7a2aab4d76097500f11963b3210b3964ddf))
* ホームページのURLを正しいリポジトリに更新 ([3f657fa](https://github.com/Shojin-App/shojin_app/commit/3f657fa2daa52e546d66e1d8ba6d6408ff178943))
* ライセンス画面のタブを追加し、設定画面のライセンス表示を更新 ([3245906](https://github.com/Shojin-App/shojin_app/commit/32459060d4ab5bd8be0533e031e201a68d7f5dca))
* ライセンス画面の表示をタブ形式に変更し、データ取得方法を簡素化 ([6d6a9e5](https://github.com/Shojin-App/shojin_app/commit/6d6a9e58189a8721fb1b9e8af93effcc4e1dc8b3))
* ライセンス画面の表示を改善し、エラーハンドリングを追加 ([5cc3121](https://github.com/Shojin-App/shojin_app/commit/5cc3121cb29f7b93763c319ef8a895e0a058cd5a))
* 不要なインポートの整理とコメントの整形 ([85a168b](https://github.com/Shojin-App/shojin_app/commit/85a168be82ec0e38be6c75cba8fcb28e9e65ebf6))

## [1.0.0] - 2025-09-26
### Added
- Initial public release.
- Core browsing of AtCoder related resources (problems list & detail view).
- Code editor with syntax highlighting & LaTeX/Markdown rendering.
- Sample test run integration (Wandbox API).
- Offline font integration (HackGen family) & multiple themes.
- F-Droid flavor with self-update disabled & offline fonts.
