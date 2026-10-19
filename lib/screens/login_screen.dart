import 'package:flutter/material.dart';

import '../models/ride.dart';
import '../widgets/primary_button.dart';
import 'driver_home_screen.dart';
import 'rider_home_screen.dart';

/// تسجيل دخول برقم الهاتف + رمز تحقق (تجريبي).
/// لاحقاً: اربطه بـ Firebase Phone Auth أو أي مزوّد SMS.
class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _demoOtp = '1234';

  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpSent = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final p = _phone.text.trim();
    // أرقام الموبايل السودانية: 9 أرقام بعد +249 (تبدأ بـ 9 أو 1)
    if (!RegExp(r'^[19]\d{8}$').hasMatch(p)) {
      setState(() => _error = 'اكتب رقم صحيح من 9 أرقام');
      return;
    }
    setState(() {
      _otpSent = true;
      _error = null;
    });
  }

  void _verify() {
    if (_otp.text.trim() != _demoOtp) {
      setState(() => _error = 'الرمز غير صحيح');
      return;
    }
    final Widget next = widget.role == UserRole.rider
        ? const RiderHomeScreen()
        : const DriverHomeScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => next),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRider = widget.role == UserRole.rider;
    return Scaffold(
      appBar: AppBar(title: Text(isRider ? 'دخول الراكب' : 'دخول السائق')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                _otpSent ? 'اكتب رمز التحقق' : 'اكتب رقم هاتفك',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _otpSent
                    ? 'أرسلنا رمز لرقمك +249 ${_phone.text.trim()}  (للتجربة: $_demoOtp)'
                    : 'حنرسل ليك رمز تحقق برسالة نصية',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              if (!_otpSent)
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  maxLength: 9,
                  decoration: const InputDecoration(
                    hintText: '9XXXXXXXX',
                    prefixText: '+249  ',
                    counterText: '',
                  ),
                )
              else
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  decoration: const InputDecoration(counterText: ''),
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: _otpSent ? 'تأكيد' : 'إرسال الرمز',
                onPressed: _otpSent ? _verify : _sendOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
