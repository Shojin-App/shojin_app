import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shojin_app/screens/recommend_screen.dart';
import 'package:shojin_app/screens/atcoder_clans_screen.dart';
import '../widgets/next_abc_contest_widget.dart';
import '../widgets/shared/custom_sliver_app_bar.dart';
import 'reminder_settings_screen.dart'; // Import reminder settings screen

class NewHomeScreen extends StatelessWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomSliverAppBar(isMainView: true, title: Text('ホーム')),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NextABCContestWidget(),
                  const SizedBox(height: 24),
                  ButtonM3E(
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('リマインダー設定'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReminderSettingsScreen(),
                        ),
                      );
                    },
                    style: ButtonM3EStyle.elevated,
                  ),
                  const SizedBox(height: 16),
                  ButtonM3E(
                    icon: const Icon(Icons.recommend),
                    label: const Text('おすすめ問題'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecommendScreen(),
                        ),
                      );
                    },
                    style: ButtonM3EStyle.elevated,
                  ),
                  const SizedBox(height: 16),
                  ButtonM3E(
                    icon: const Icon(Icons.web),
                    label: const Text('AtCoder Clans'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AtCoderClansScreen(),
                        ),
                      );
                    },
                    style: ButtonM3EStyle.elevated,
                  ),
                  const SizedBox(height: 16),
                  // 他のウィジェットをここに追加可能
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
