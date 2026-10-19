# دودي (Doudy) 🚕

تطبيق مشاوير سوداني بـ Flutter. هذه النسخة الأولى: **واجهات كاملة + منطق تجريبي** (بدون سيرفر وبدون خرائط حقيقية).

## التشغيل

```bash
cd doudy
flutter create --org com.doudy --project-name doudy .   # ينشئ مجلدات android/ios (ما بيمسح ملفاتك)
flutter pub get
flutter run
```

## اللوغو

انسخ صورة اللوغو إلى `assets/images/logo.png`. لو ما موجودة بيظهر حرف "د" بديل.
لأيقونة التطبيق نفسها استخدم حزمة `flutter_launcher_icons`.

## الهيكل

```
lib/
  main.dart                 نقطة البداية، عربي + RTL
  core/                     theme.dart (الألوان) + format.dart (تنسيق الجنيه)
  models/                   ride.dart (أماكن، سائق، حالات) + ride_request.dart
  services/
    fare_service.dart       حساب المسافة والأجرة والعمولة  ← عدّل الأسعار هنا
    ride_service.dart       خدمة تجريبية ← استبدلها بالسيرفر
  providers/
    ride_provider.dart      منطق الراكب (طلب → قبول → وصول → رحلة → تقييم)
    driver_provider.dart    منطق السائق (اتصال، طلبات، مراحل الرحلة، الأرباح)
  screens/                  splash, role, login, rider_home, driver_home
  widgets/                  logo, button, map_placeholder
```

## للتجربة

- رقم الهاتف: أي رقم من 9 أرقام يبدأ بـ 9 أو 1، ورمز التحقق `1234`.
- الراكب: اختار وجهة ← اطلب دودي، والرحلة بتتقدم تلقائياً.
- السائق: فعّل "متصل" ← بعد ثواني بيجي طلب تجريبي.
- شاشة الراكب وشاشة السائق **ما مربوطتين ببعض** حالياً، كل واحدة بتحاكي الطرف الآخر.

## الخطوات الجاية

1. **الخرائط والموقع**: `google_maps_flutter` (أو `flutter_map` + OpenStreetMap لتكلفة أقل) و`geolocator`، وتستبدل `MapPlaceholder`.
2. **الباك إند**: Firebase (Auth برقم الهاتف + Firestore) أو Supabase، وتربط الراكب بالسائق في `RideService`.
3. **الإشعارات**: Firebase Cloud Messaging لطلبات السائقين.
4. **الدفع**: الكاش جاهز كخيار، وبنكك يحتاج تكامل فعلي مع مزوّد الدفع.
5. **التوثيق والسلامة**: التحقق من رخصة السائق وبيانات العربية، ومشاركة الرحلة وزر الطوارئ.

> الإحداثيات وأسماء السائقين وأرقام اللوحات في الكود تجريبية فقط.
