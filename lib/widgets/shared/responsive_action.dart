import 'package:flutter/widgets.dart';

/// Keeps a single primary action easy to tap on phones without letting it
/// dominate wide layouts.
class ResponsiveAction extends StatelessWidget {
  const ResponsiveAction({
    super.key,
    required this.child,
    this.breakpoint = 480,
    this.maxWidth = 240,
  });

  final Widget child;
  final double breakpoint;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) return child;

        final width = constraints.maxWidth < breakpoint
            ? constraints.maxWidth
            : maxWidth.clamp(0, constraints.maxWidth).toDouble();
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}
