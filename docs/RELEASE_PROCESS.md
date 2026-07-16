# リリース運用

このプロジェクトでは`dev`ブランチでバージョンを管理し、GitHub Actionsが`main`向けリリースPR、タグ、GitHub Releaseの作成を自動化します。release-pleaseは使用していません。

## リリースフロー

1. 通常の開発を`dev`ブランチで行います。
2. GitHub Actionsの`Prepare Release`を手動実行します。
   - `bump`: `patch`、`minor`、`major`
   - `preid`: プレリリースを使用しない場合は空
   - `dry_run`: 動作確認のみの場合は`true`
3. ワークフローが次の処理を行います。
   - `pubspec.yaml`の`version`を更新
   - `CHANGELOG.md`に対象バージョンの節を追加
   - `release/vX.Y.Z`ブランチを作成してpush
   - `main`向けのリリースPRを作成
4. PR上でCHANGELOGのプレースホルダーを実際の変更内容に編集します。
5. PRをマージすると`Publish Release`が実行されます。
   - `vX.Y.Z`タグを作成
   - CHANGELOGの対象節を使ってGitHub Releaseを作成
6. GitHub Releaseから配布用アーティファクトを取得します。

## コミット規約

Conventional Commits互換のメッセージを推奨します。

```text
feat(editor): テンプレ生成を高速化
fix(browser): 末尾スラッシュURLの解析不具合
chore(deps): ライブラリアップデート
refactor(ui): テーマ切替ロジック整理
```

## 運用ルール

- `dev`では`pubspec.yaml`のバージョンを手動変更せず、`Prepare Release`を使用する
- リリースPRの自動生成タイトルを維持する
- CHANGELOGの過去バージョンを変更しない
- 過去バージョンの修正が必要な場合は、目的を明記した別PRにする

## プレリリース

現在は常用していません。必要な場合は`preid`を指定すると、`1.2.3-beta.1`のような形式を使用できます。

## 今後の拡張候補

- コミットログからのCHANGELOG自動生成
- Androidなどの成果物の自動ビルド・アップロード
- 依存パッケージ差分の自動記載

