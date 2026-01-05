import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

class CustomSliverAppBar extends StatelessWidget {
  final bool isMainView;
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackButtonPressed;

  const CustomSliverAppBar({
    super.key,
    required this.isMainView,
    required this.title,
    this.actions,
    this.bottom,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBarM3E(
      pinned: true,
      variant: AppBarM3EVariant.medium,
      title: title,
      leading: isMainView
          ? null
          : IconButtonM3E(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBackButtonPressed ?? () => Navigator.of(context).pop(),
            ),
      backgroundColor: Colors
          .transparent, // Let SliverAppBarM3E handle its own surface coloring or transparency
      actions: actions,
    );
  }
}
