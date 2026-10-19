// اختبارات منطق حساب الأجرة (الاسم widget_test.dart عشان flutter create
// ما ينشئ اختبار افتراضي يتعارض مع المشروع).
import 'package:doudy/models/ride.dart';
import 'package:doudy/services/fare_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('الأجرة لا تقل عن الحد الأدنى', () {
    expect(FareService.estimate(0.5), FareService.minFare);
  });

  test('الأجرة مقرّبة لأقرب 100', () {
    final fare = FareService.estimate(7.3);
    expect(fare % 100, 0);
    expect(fare, greaterThan(FareService.minFare));
  });

  test('المسافة بين نفس النقطة صفر', () {
    expect(FareService.distanceKm(Places.current, Places.current), 0);
  });

  test('نصيب السائق بعد العمولة', () {
    expect(FareService.driverShare(10000), closeTo(8500, 0.001));
  });
}
