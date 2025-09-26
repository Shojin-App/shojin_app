# Changelog

All notable changes to this project will be documented in this file.
This file is maintained automatically by release-please (Conventional Commits).

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
