import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/driver_provider.dart';
import 'providers/ride_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => DriverProvider()),
      ],
      child: const DoudyApp(),
    ),
  );
}

class DoudyApp extends StatelessWidget {
  const DoudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دودي',
      debugShowCheckedModeBanner: false,
      theme: doudyTheme(),
      // عربي وواجهة من اليمين لليسار
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}