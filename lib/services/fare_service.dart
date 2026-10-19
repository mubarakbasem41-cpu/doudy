import 'dart:math';

import '../models/ride.dart';

/// حساب المسافة والسعر. غيّر الأرقام حسب السوق (الأسعار بالجنيه السوداني).
class FareService {
  static const double baseFare = 1500;
  static const double perKm = 600;
  static const double minFare = 3000;

  /// المسافة بالطريق أطول من الخط المستقيم، فنضرب في معامل تقريبي.
  static const double roadFactor = 1.3;

  /// نسبة عمولة دودي من كل رحلة.
  static const double commissionRate = 0.15;

  static double distanceKm(Place a, Place b) {
    const earthRadius = 6371.0;
    final dLat = _rad(b.lat - a.lat);
    final dLng = _rad(b.lng - a.lng);
    final h = pow(sin(dLat / 2), 2) +
        cos(_rad(a.lat)) * cos(_rad(b.lat)) * pow(sin(dLng / 2), 2);
    return 2 * earthRadius * asin(sqrt(h)) * roadFactor;
  }

  /// السعر المتوقع، مقرّب لأقرب 100 جنيه.
  static double estimate(double km) {
    final raw = max(minFare, baseFare + km * perKm);
    return (raw / 100).round() * 100.0;
  }

  /// نصيب السائق بعد خصم العمولة.
  static double driverShare(double fare) => fare * (1 - commissionRate);

  static double _rad(double deg) => deg * pi / 180;
}
