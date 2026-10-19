import 'dart:math';

import '../services/fare_service.dart';
import 'ride.dart';

/// طلب رحلة يظهر عند السائق.
class RideRequest {
  final Place pickup;
  final Place dropoff;
  final String riderName;
  final double distanceKm;
  final double fare;

  const RideRequest({
    required this.pickup,
    required this.dropoff,
    required this.riderName,
    required this.distanceKm,
    required this.fare,
  });

  static const _names = ['أحمد', 'مريم', 'عمر', 'سلمى', 'خالد', 'هدى'];

  /// طلب عشوائي للتجربة. في النسخة الحقيقية يجي من السيرفر.
  factory RideRequest.random(Random r) {
    final list = Places.destinations;
    final a = list[r.nextInt(list.length)];
    Place b;
    do {
      b = list[r.nextInt(list.length)];
    } while (identical(a, b));
    final km = FareService.distanceKm(a, b);
    return RideRequest(
      pickup: a,
      dropoff: b,
      riderName: _names[r.nextInt(_names.length)],
      distanceKm: km,
      fare: FareService.estimate(km),
    );
  }
}
