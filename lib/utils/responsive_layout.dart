import 'package:flutter/widgets.dart';

class ResponsiveLayout {
  const ResponsiveLayout._();

  static const double maxContentWidth = 960;

  static double horizontalPadding(BuildContext context, {double minimum = 16}) {
    final centered = (MediaQuery.sizeOf(context).width - maxContentWidth) / 2;
    return centered > minimum ? centered : minimum;
  }

  static EdgeInsets listPadding(
    BuildContext context, {
    double top = 16,
    double bottom = 24,
    double minimumHorizontal = 16,
  }) {
    final horizontal = horizontalPadding(context, minimum: minimumHorizontal);
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom + safeBottom,
    );
  }
}
