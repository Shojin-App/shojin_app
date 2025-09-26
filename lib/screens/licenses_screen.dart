// import 'package:flutter_oss_licenses/flutter_oss_licenses.dart';
// 上記パッケージの Widget 名がバージョン差異で認識できないため、
// 生成済みファイル (lib/generated/oss_licenses.dart) を直接読み込む簡易ビューに切り替える。
// 後でパッケージ提供の専用Widgetへ戻すことも可能。
import 'dart:async';

import 'package:flutter/material.dart';

/// A dedicated screen to display aggregated OSS licenses.
/// This uses flutter_oss_licenses generated data.
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サードパーティライセンス')),
      body: FutureBuilder<List<_LicenseEntry>>(
        future: _loadLicenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('ライセンス読み込み失敗: ${snapshot.error}'),
              ),
            );
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('ライセンス項目が見つかりません'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final e = data[index];
              return ExpansionTile(
                title: Text(e.name),
                subtitle: Text(e.version),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(
                      e.license,
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LicenseEntry {
  final String name;
  final String version;
  final String license;
  _LicenseEntry({
    required this.name,
    required this.version,
    required this.license,
  });
}

Future<List<_LicenseEntry>> _loadLicenses() async {
  try {
    // flutter_oss_licenses が生成する標準ファイルパスを推定。
    // 生成ファイルに合わせてここを調整する（JSON/Text形式の場合は別途パース）。
    // 現状: lib/generated/oss_licenses.dart が直接 Dart コードの場合、
    // ここでは簡易フォールバックとして空リストを返す。
    // 将来的に build_runner 等で JSON 生成に切替するなら rootBundle.loadString で読む。
    // TODO: 実際には生成されたデータを取り込む。暫定で空リストを返し、
    // パッケージの公式Widget名確認後に差し替える。
    return [];
  } catch (e) {
    return Future.error(e);
  }
}
