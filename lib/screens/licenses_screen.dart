import 'package:flutter/material.dart';
import '../generated/oss_licenses.dart';

/// ライセンス一覧（生成データ利用）
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('サードパーティライセンス'),
          bottom: const TabBar(tabs: [
            Tab(text: '依存 (直接)'),
            Tab(text: '全て'),
          ]),
        ),
        body: TabBarView(
          children: [
            _LicenseList(packages: dependencies),
            _LicenseList(packages: allDependencies),
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
          childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
