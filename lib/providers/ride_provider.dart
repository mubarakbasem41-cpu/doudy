import 'package:flutter/foundation.dart';

import '../models/ride.dart';
import '../services/fare_service.dart';
import '../services/ride_service.dart';

/// منطق الراكب: اختيار الوجهة، حساب السعر، طلب الرحلة، تتبّع حالتها.
class RideProvider extends ChangeNotifier {
  RideProvider({RideService? service}) : _service = service ?? RideService();

  final RideService _service;

  final Place pickup = Places.current;
  Place? dropoff;
  PaymentMethod payment = PaymentMethod.cash;
  RideStatus status = RideStatus.idle;
  Driver? driver;
  int rating = 0;

  // يتغير مع كل طلب/إلغاء عشان نوقف أي خطوات قديمة معلّقة.
  int _token = 0;
  bool _disposed = false;

  double? get distanceKm =>
      dropoff == null ? null : FareService.distanceKm(pickup, dropoff!);

  double? get fare {
    final km = distanceKm;
    return km == null ? null : FareService.estimate(km);
  }

  bool get canCancel =>
      status == RideStatus.searching ||
      status == RideStatus.accepted ||
      status == RideStatus.arriving;

  void setDropoff(Place place) {
    dropoff = place;
    notifyListeners();
  }

  void setPayment(PaymentMethod method) {
    payment = method;
    notifyListeners();
  }

  Future<void> requestRide() async {
    if (dropoff == null || status != RideStatus.idle) return;
    final token = ++_token;

    status = RideStatus.searching;
    notifyListeners();

    final found = await _service.findDriver();
    if (!_alive(token, RideStatus.searching)) return;
    driver = found;
    status = RideStatus.accepted;
    notifyListeners();

    // محاكاة تقدّم الرحلة. في النسخة الحقيقية تجي التحديثات من السيرفر.
    if (!await _advance(token, RideStatus.accepted, RideStatus.arriving, 3)) {
      return;
    }
    if (!await _advance(token, RideStatus.arriving, RideStatus.inTrip, 4)) {
      return;
    }
    await _advance(token, RideStatus.inTrip, RideStatus.completed, 6);
  }

  void cancel() {
    if (!canCancel) return;
    _token++;
    driver = null;
    status = RideStatus.idle;
    notifyListeners();
  }

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  /// بعد ما يخلّص الراكب ويقيّم: نرجّع الشاشة لوضع طلب جديد.
  void finish() {
    _token++;
    status = RideStatus.idle;
    driver = null;
    dropoff = null;
    rating = 0;
    notifyListeners();
  }

  bool _alive(int token, RideStatus expected) =>
      !_disposed && token == _token && status == expected;

  Future<bool> _advance(
    int token,
    RideStatus from,
    RideStatus to,
    int seconds,
  ) async {
    await Future.delayed(Duration(seconds: seconds));
    if (!_alive(token, from)) return false;
    status = to;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
