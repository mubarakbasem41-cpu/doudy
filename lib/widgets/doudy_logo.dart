import 'package:flutter/material.dart';

import '../core/theme.dart';

/// يعرض assets/images/logo.png، ولو الصورة ما موجودة يعرض شكل بديل.
class DoudyLogo extends StatelessWidget {
  final double size;
  const DoudyLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: DoudyColors.gold,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          'د',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.bold,
            color: DoudyColors.green,
          ),
        ),
      ),
    );
  }
}
