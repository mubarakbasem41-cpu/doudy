import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    return outlined
        ? OutlinedButton(onPressed: onPressed, child: text)
        : FilledButton(onPressed: onPressed, child: text);
  }
}
