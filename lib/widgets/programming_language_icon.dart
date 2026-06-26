import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

class ProgrammingLanguageIcon extends StatelessWidget {
  const ProgrammingLanguageIcon({
    super.key,
    required this.language,
    this.size = 32,
  });

  final String language;
  final double size;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(language);
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = spec.useAdaptiveMonochrome
        ? colorScheme.onSurface
        : spec.color ?? colorScheme.onSurfaceVariant;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: iconColor.withValues(alpha: 0.28)),
      ),
      child: Icon(
        spec.icon,
        color: iconColor,
        size: size * 0.62,
        semanticLabel: '$language logo',
      ),
    );
  }

  _LanguageIconSpec _specFor(String value) {
    switch (value.toLowerCase()) {
      case 'python':
        return _LanguageIconSpec(SimpleIcons.python, SimpleIconColors.python);
      case 'c++':
      case 'cpp':
        return _LanguageIconSpec(
          SimpleIcons.cplusplus,
          SimpleIconColors.cplusplus,
        );
      case 'rust':
        return _LanguageIconSpec(
          SimpleIcons.rust,
          SimpleIconColors.rust,
          useAdaptiveMonochrome: true,
        );
      case 'java':
        return _LanguageIconSpec(
          SimpleIcons.openjdk,
          SimpleIconColors.openjdk,
          useAdaptiveMonochrome: true,
        );
      default:
        return const _LanguageIconSpec(Icons.code, null);
    }
  }
}

class _LanguageIconSpec {
  const _LanguageIconSpec(
    this.icon,
    this.color, {
    this.useAdaptiveMonochrome = false,
  });

  final IconData icon;
  final Color? color;
  final bool useAdaptiveMonochrome;
}
