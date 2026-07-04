import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.viewInsets.bottom > 0) {
      // AndroidのIME表示中は入力領域を優先する。各画面の末尾余白も
      // 同じ条件でナビゲーション分を外すため、両者を必ず同期させる。
      return const SizedBox.shrink();
    }

    final showOnlySelectedLabel =
        mediaQuery.size.width < 360 || mediaQuery.textScaler.scale(1) > 1.3;

    return NavigationBarM3E(
      backgroundColor: Colors.transparent,
      elevation: 0,
      semanticLabel: 'メインナビゲーション',
      labelBehavior: showOnlySelectedLabel
          ? NavBarM3ELabelBehavior.onlySelected
          : NavBarM3ELabelBehavior.alwaysShow,
      onDestinationSelected: onDestinationSelected,
      selectedIndex: selectedIndex,
      destinations: const [
        NavigationDestinationM3E(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'ホーム',
        ),
        NavigationDestinationM3E(
          icon: Icon(Icons.public_outlined),
          selectedIcon: Icon(Icons.public),
          label: 'ブラウザ',
        ),
        NavigationDestinationM3E(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: '問題',
        ),
        NavigationDestinationM3E(
          icon: Icon(Icons.code_outlined),
          selectedIcon: Icon(Icons.code),
          label: 'エディタ',
        ),
        NavigationDestinationM3E(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: '設定',
        ),
      ],
    );
  }
}
