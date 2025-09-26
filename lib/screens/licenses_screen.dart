import 'package:flutter/material.dart';
import 'package:flutter_oss_licenses/flutter_oss_licenses.dart';

/// A dedicated screen to display aggregated OSS licenses.
/// This uses flutter_oss_licenses generated data.
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サードパーティライセンス')),
      body: const OssLicensesPage(
        title: 'サードパーティライセンス',
        // Optionally you can customize more parameters if needed.
      ),
    );
  }
}
