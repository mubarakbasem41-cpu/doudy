import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/ride_request.dart';
import '../services/fare_service.dart';

enum DriverState {
  offline,
  online,
  offered,
  toPickup,
  waitingRider,
  inTrip,
  completed,
}

/// منطق السائق: متصل/غير متصل، استلام طلب، مراحل الرحلة، الأرباح.
class DriverProvider extends ChangeNotifier {
  final _rand = Random();

  DriverState state = DriverState.offline;
  RideRequest? offer;
  double earningsToday = 0;
  int tripsToday = 0;

  int _token = 0;
  bool _disposed = false;

  double get offerEarning =>
      offer == null ? 0 : FareService.driverShare(offer!.fare);

  void setOnline(bool online) {
    _token++;
    if (online) {
      state = DriverState.online;
      notifyListeners();
      _scheduleOffer();
    } else {
      offer = null;
      state = DriverState.offline;
      notifyListeners();
    }
  }

  /// محاكاة: يوصل طلب بعد 4 ثواني، وينتهي بعد 15 ثانية لو ما اتقبل.
  /// في النسخة الحقيقية: اسمع لطلبات قريبة من السيرفر (Firestore / WebSocket).
  Future<void> _scheduleOffer() async {
    final token = ++_token;
    await Future.delayed(const Duration(seconds: 4));
    if (_disposed || token != _token || state != DriverState.online) return;

    offer = RideRequest.random(_rand);
    state = DriverState.offered;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 15));
    if (_disposed || token != _token || state != DriverState.offered) return;
    _backOnline();
  }

  void accept() {
    if (state != DriverState.offered) return;
    _token++;
    state = DriverState.toPickup;
    notifyListeners();
  }

  void decline() {
    if (state != DriverState.offered) return;
    _backOnline();
  }

  void arrivedAtPickup() {
    if (state != DriverState.toPickup) return;
    state = DriverState.waitingRider;
    notifyListeners();
  }

  void startTrip() {
    if (state != DriverState.waitingRider) return;
    state = DriverState.inTrip;
    notifyListeners();
  }

  void endTrip() {
    if (state != DriverState.inTrip) return;
    earningsToday += offerEarning;
    tripsToday += 1;
    state = DriverState.completed;
    notifyListeners();
  }

  void nextRide() => _backOnline();

  void _backOnline() {
    offer = null;
    state = DriverState.online;
    notifyListeners();
    _scheduleOffer();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
