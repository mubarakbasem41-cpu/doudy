import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/doudy_logo.dart';
import 'role_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DoudyColors.green,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DoudyLogo(size: 140),
            SizedBox(height: 16),
            Text(
              'دودي',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'مشاويرك أسهل',
              style: TextStyle(fontSize: 18, color: DoudyColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
