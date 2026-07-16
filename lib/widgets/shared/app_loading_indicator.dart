import 'package:flutter/widgets.dart';
import 'package:m3e_collection/m3e_collection.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final String semanticsLabel;

  const AppLoadingIndicator({
    super.key,
    this.size = 40,
    this.semanticsLabel = '読み込み中',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      liveRegion: true,
      child: SizedBox.square(
        dimension: size,
        child: const LoadingIndicatorM3E(),
      ),
    );
  }
}
