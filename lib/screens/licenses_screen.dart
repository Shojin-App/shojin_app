import 'package:flutter/foundation.dart'
    show LicenseEntry, LicenseRegistry; // for potential custom additions
import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../generated/manual_licenses.dart';
import '../generated/oss_licenses.dart';
import '../utils/responsive_layout.dart';
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/app_state_card.dart';
import '../widgets/shared/responsive_action.dart';

/// ライセンス一覧（生成データ利用）
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key, this.standardLicenseStreamBuilder});

  final Stream<LicenseEntry> Function()? standardLicenseStreamBuilder;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ライセンス'),
          bottom: const TabBar(
            indicatorPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            splashBorderRadius: BorderRadius.all(Radius.circular(12)),
            tabs: [
              Tab(text: '直接'),
              Tab(text: '全体'),
              Tab(text: '標準'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Direct dependencies + manual (e.g. fonts)
            _LicenseList(packages: [...dependencies, ...extraPackages]),
            // All (direct + transitive) + manual extras (kept separate from generator)
            _LicenseList(packages: [...allDependencies, ...extraPackages]),
            _StandardLicensePane(
              currentVersion: _extractAppVersion(),
              licenseStreamBuilder: standardLicenseStreamBuilder,
            ),
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
    return ListView.builder(
      padding: ResponsiveLayout.listPadding(context),
      itemCount: packages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _InfoCard(
            icon: Icons.rule_folder_outlined,
            title: '${packages.length} 件のライセンス',
            message: 'パッケージを開くとライセンス本文を確認できます。',
          );
        }
        final p = packages[index - 1];
        return _LicensePackageCard(package: p);
      },
    );
  }
}

class _LicensePackageCard extends StatelessWidget {
  final Package package;

  const _LicensePackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final link = package.homepage ?? package.repository;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.inventory_2_outlined,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          package.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          package.version?.isNotEmpty == true ? package.version! : 'バージョン不明',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          if (link != null && link.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  link,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: SelectableText(
              package.license ?? 'ライセンス本文がありません',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 標準 Flutter ライセンスページをタブ内に埋め込む簡易版
class _StandardLicensePane extends StatefulWidget {
  final String? currentVersion;
  final Stream<LicenseEntry> Function()? licenseStreamBuilder;

  const _StandardLicensePane({this.currentVersion, this.licenseStreamBuilder});

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
    // 再試行時にも新しいsingle-subscription streamを購読できるよう、
    // Streamそのものではなく生成関数を受け取る。
    final stream =
        widget.licenseStreamBuilder?.call() ?? LicenseRegistry.licenses;
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
          return const _CenteredStateCard(
            icon: Icons.rule_folder_outlined,
            title: '標準ライセンスを読み込み中',
            message: 'FlutterのLicenseRegistryから情報を収集しています。',
            child: Padding(
              padding: EdgeInsets.only(top: 16),
              child: AppLoadingIndicator(semanticsLabel: '標準ライセンスを読み込み中'),
            ),
          );
        }
        if (snapshot.hasError) {
          return _CenteredStateCard(
            icon: Icons.error_outline,
            title: '読み込みに失敗しました',
            message: '標準ライセンスを収集できませんでした。もう一度お試しください。',
            isError: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ResponsiveAction(
                child: ButtonM3E(
                  style: ButtonM3EStyle.tonal,
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                  onPressed: _reload,
                ),
              ),
            ),
          );
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const _CenteredStateCard(
            icon: Icons.rule_folder_outlined,
            title: '標準ライセンスは登録されていません',
            message: 'LicenseRegistryから表示できる項目が見つかりませんでした。',
          );
        }
        return ListView.builder(
          padding: ResponsiveLayout.listPadding(context),
          itemCount: data.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _InfoCard(
                icon: Icons.flutter_dash,
                title: '${data.length} 件の標準ライセンス',
                message: 'Flutter / プラグインが LicenseRegistry に登録したライセンス一覧です。',
              );
            }
            final lic = data[index - 1];
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final packageNames = lic.packages.join(', ');

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_outlined,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                title: Text(
                  packageNames,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${lic.packages.length} パッケージ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    child: SelectableText(
                      lic.text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _reload() {
    setState(() {
      _future = _collect();
    });
  }
}

class _CollectedLicense {
  final List<String> packages;
  final String text;
  _CollectedLicense({required this.packages, required this.text});
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppStateCard(
        margin: EdgeInsets.zero,
        icon: icon,
        title: title,
        message: message,
      ),
    );
  }
}

class _CenteredStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool isError;
  final Widget? child;

  const _CenteredStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.isError = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppStateCard(
          margin: EdgeInsets.zero,
          icon: icon,
          title: title,
          message: message,
          isError: isError,
          child: child,
        ),
      ),
    );
  }
}

String? _extractAppVersion() {
  // 生成ファイルに自アプリのバージョンを持たせていないので暫定 null
  return null;
}
