import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

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
    final opacity = context.watch<ThemeProvider>().navBarOpacity;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      title: title,
      leading: isMainView
          ? null
          : IconButtonM3E(
              tooltip: '戻る',
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  onBackButtonPressed ?? () => Navigator.of(context).pop(),
            ),
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: _TranslucentBarBackground(
        opacity: opacity,
        color: colorScheme.surface,
      ),
      actions: actions,
    );
  }
}

class TranslucentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const TranslucentAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final opacity = context.watch<ThemeProvider>().navBarOpacity;
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: _TranslucentBarBackground(
        opacity: opacity,
        color: colorScheme.surface,
      ),
    );
  }
}

class _TranslucentBarBackground extends StatelessWidget {
  const _TranslucentBarBackground({required this.opacity, required this.color});

  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: opacity * 24, sigmaY: opacity * 24),
        child: ColoredBox(color: color.withValues(alpha: opacity)),
      ),
    );
  }
}
