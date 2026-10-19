import 'package:flutter/material.dart';

import '../core/theme.dart';

/// بديل مؤقت للخريطة (بدون مفاتيح API).
/// لاحقاً: استبدله بـ GoogleMap من حزمة google_maps_flutter
/// أو FlutterMap + OpenStreetMap لو عايز حل أرخص.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 160),
            child: Icon(Icons.location_on, size: 52, color: DoudyColors.green),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE6EEE8),
    );
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 8;
    for (double x = 30; x < size.width; x += 95) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
    for (double y = 60; y < size.height; y += 110) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.6),
      road..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
