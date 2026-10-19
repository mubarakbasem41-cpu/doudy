enum UserRole { rider, driver }

enum RideStatus { idle, searching, accepted, arriving, inTrip, completed }

enum PaymentMethod { cash, bankak }

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'كاش',
        PaymentMethod.bankak => 'بنكك',
      };
}

class Place {
  final String name;
  final double lat;
  final double lng;
  const Place(this.name, this.lat, this.lng);
}

/// أماكن تجريبية (الإحداثيات تقريبية للتجربة فقط).
/// لاحقاً: استبدلها بـ GPS حقيقي + بحث أماكن من خدمة الخرائط.
class Places {
  static const current = Place('موقعي الحالي', 15.5527, 32.5324);

  static const destinations = <Place>[
    Place('السوق العربي', 15.5997, 32.5322),
    Place('جامعة الخرطوم', 15.5899, 32.5336),
    Place('مطار الخرطوم', 15.5895, 32.5532),
    Place('المنشية', 15.5780, 32.5600),
    Place('سوق أم درمان', 15.6446, 32.4777),
    Place('الموردة - أم درمان', 15.6310, 32.4900),
    Place('الشعبية - بحري', 15.6700, 32.5400),
  ];
}

class Driver {
  final String name;
  final String phone;
  final String car;
  final String plate;
  final double rating;
  const Driver({
    required this.name,
    required this.phone,
    required this.car,
    required this.plate,
    required this.rating,
  });
}
