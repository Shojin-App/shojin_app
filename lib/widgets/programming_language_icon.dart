import 'package:flutter/material.dart';

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
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: spec.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: spec.color.withValues(alpha: 0.55)),
      ),
      child: Text(
        spec.label,
        style: TextStyle(
          color: spec.color,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }

  _LanguageIconSpec _specFor(String value) {
    switch (value.toLowerCase()) {
      case 'python':
        return const _LanguageIconSpec('Py', Color(0xFF3776AB));
      case 'c++':
      case 'cpp':
        return const _LanguageIconSpec('C++', Color(0xFF00599C));
      case 'rust':
        return const _LanguageIconSpec('Rs', Color(0xFFCE422B));
      case 'java':
        return const _LanguageIconSpec('J', Color(0xFFEA2D2E));
      default:
        return _LanguageIconSpec(
          value.isEmpty ? '?' : value.substring(0, 1).toUpperCase(),
          const Color(0xFF6B7280),
        );
    }
  }
}

class _LanguageIconSpec {
  const _LanguageIconSpec(this.label, this.color);

  final String label;
  final Color color;
}
