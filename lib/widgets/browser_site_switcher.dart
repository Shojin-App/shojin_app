import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

class BrowserSiteSwitcher extends StatelessWidget {
  const BrowserSiteSwitcher({
    super.key,
    required this.scrollController,
    required this.siteButtons,
    required this.onAdd,
  });

  final ScrollController scrollController;
  final List<Widget> siteButtons;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.textScalerOf(context);
    // Keep the regular toolbar compact while reserving enough vertical room
    // for enlarged labels. The cap prevents this persistent control from
    // consuming an excessive portion of short phone screens.
    final barHeight = (42 + textScaler.scale(14)).clamp(56.0, 72.0).toDouble();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: barHeight,
        child: Row(
          children: [
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  children: siteButtons,
                ),
              ),
            ),
            Container(width: 1, height: 28, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButtonM3E(
                tooltip: 'サイトを追加',
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
