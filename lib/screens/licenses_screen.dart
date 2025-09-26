import 'package:flutter/foundation.dart'
    show LicenseRegistry; // for potential custom additions
import 'package:flutter/material.dart';

import '../generated/oss_licenses.dart';

/// ライセンス一覧（生成データ利用）
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ライセンス'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '直接'),
              Tab(text: '全体'),
              Tab(text: '標準'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LicenseList(packages: dependencies),
            _LicenseList(packages: allDependencies),
            _StandardLicensePane(currentVersion: _extractAppVersion()),
          ],
        ),
      ),
    );
  }
}

class _LicenseList extends StatelessWidget {
  final List<Package> packages;
  const _LicenseList({required this.packages});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: packages.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final p = packages[index];
        return ExpansionTile(
          title: Text(p.name),
          subtitle: Text(p.version ?? ''),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          children: [
            if ((p.homepage ?? p.repository) != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    p.homepage ?? p.repository ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            SelectableText(
              p.license ?? '(No license text)',
              style: const TextStyle(fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

/// 標準 Flutter ライセンスページをタブ内に埋め込む簡易版
class _StandardLicensePane extends StatefulWidget {
  final String? currentVersion;
  const _StandardLicensePane({this.currentVersion});

  @override
  State<_StandardLicensePane> createState() => _StandardLicensePaneState();
}

class _StandardLicensePaneState extends State<_StandardLicensePane> {
  late Future<List<_CollectedLicense>> _future;

  @override
  void initState() {
    super.initState();
    _future = _collect();
  }

  Future<List<_CollectedLicense>> _collect() async {
    final entries = <_CollectedLicense>[];
    // LicenseRegistry は Stream でライセンスエントリを返す
    final stream = LicenseRegistry.licenses;
    await for (final l in stream) {
      final paragraphs = <String>[];
      for (final p in l.paragraphs) {
        paragraphs.add(p.text);
      }
      entries.add(
        _CollectedLicense(
          packages: l.packages.toList(),
          text: paragraphs.join('\n\n'),
        ),
      );
    }
    entries.sort((a, b) => a.packages.first.compareTo(b.packages.first));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_CollectedLicense>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('読み込み失敗: ${snapshot.error}'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(child: Text('標準ライセンスは登録されていません'));
        }
        return ListView.builder(
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '標準タブは Flutter / プラグインが LicenseRegistry に登録したライセンス一覧です。'
                  ' 直接/全体タブはビルド時スナップショットで、バージョンと完全本文を提供します。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }
            final lic = data[index - 1];
            return ExpansionTile(
              title: Text(lic.packages.join(', ')),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableText(
                    lic.text,
                    style: const TextStyle(fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CollectedLicense {
  final List<String> packages;
  final String text;
  _CollectedLicense({required this.packages, required this.text});
}

String? _extractAppVersion() {
  // 生成ファイルに自アプリのバージョンを持たせていないので暫定 null
  return null;
}
