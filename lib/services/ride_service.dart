import 'dart:math';

import '../models/ride.dart';

/// خدمة تجريبية بدون سيرفر.
/// لاحقاً: استبدل findDriver بطلب حقيقي (Firebase / Supabase / API خاص بيك).
class RideService {
  final _rand = Random();

  static const _drivers = <Driver>[
    Driver(
      name: 'محمد عثمان',
      phone: '+249900000001',
      car: 'تويوتا كورولا - أبيض',
      plate: 'خ ر 4821',
      rating: 4.8,
    ),
    Driver(
      name: 'عبد الله إبراهيم',
      phone: '+249900000002',
      car: 'هيونداي إلنترا - فضي',
      plate: 'خ ر 1377',
      rating: 4.6,
    ),
    Driver(
      name: 'يوسف حسن',
      phone: '+249900000003',
      car: 'كيا ريو - أسود',
      plate: 'خ ر 9054',
      rating: 4.9,
    ),
  ];

  Future<Driver> findDriver() async {
    await Future.delayed(Duration(seconds: 2 + _rand.nextInt(3)));
    return _drivers[_rand.nextInt(_drivers.length)];
  }
}
