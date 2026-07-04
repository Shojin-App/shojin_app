import 'package:flutter/material.dart';

class BrowserSiteFormFields extends StatelessWidget {
  const BrowserSiteFormFields({
    super.key,
    required this.titleController,
    required this.urlController,
    required this.onTitleChanged,
    required this.onUrlChanged,
    this.titleErrorText,
    this.urlErrorText,
  });

  final TextEditingController titleController;
  final TextEditingController urlController;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onUrlChanged;
  final String? titleErrorText;
  final String? urlErrorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          decoration: _decoration(
            context,
            labelText: 'タイトル',
            prefixIcon: Icons.label_outline,
            errorText: titleErrorText,
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          decoration: _decoration(
            context,
            labelText: 'URL',
            prefixIcon: Icons.link,
            errorText: urlErrorText,
          ),
          onChanged: onUrlChanged,
        ),
      ],
    );
  }

  InputDecoration _decoration(
    BuildContext context, {
    required String labelText,
    required IconData prefixIcon,
    String? errorText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: labelText,
      errorText: errorText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    );
  }
}
