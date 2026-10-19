import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../providers/driver_provider.dart';
import '../widgets/doudy_logo.dart';
import '../widgets/primary_button.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final d = context.watch<DriverProvider>();
    final isOnline = d.state != DriverState.offline;
    final canToggle =
        d.state == DriverState.offline || d.state == DriverState.online;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DoudyLogo(size: 32),
            SizedBox(width: 8),
            Text('دودي سائق'),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _OnlineCard(
              online: isOnline,
              enabled: canToggle,
              onChanged: d.setOnline,
            ),
            const SizedBox(height: 14),
            _EarningsCard(earnings: d.earningsToday, trips: d.tripsToday),
            const SizedBox(height: 20),
            _StateSection(d: d),
          ],
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  final bool online;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _OnlineCard({
    required this.online,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 14,
            color: online ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              online ? 'متصل' : 'غير متصل',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: online,
            onChanged: enabled ? onChanged : null,
            activeColor: DoudyColors.green,
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final double earnings;
  final int trips;
  const _EarningsCard({required this.earnings, required this.trips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DoudyColors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أرباح اليوم',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  formatSdg(earnings),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('الرحلات', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                '$trips',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: DoudyColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StateSection extends StatelessWidget {
  final DriverProvider d;
  const _StateSection({required this.d});

  @override
  Widget build(BuildContext context) {
    return switch (d.state) {
      DriverState.offline => const _Message(
          icon: Icons.power_settings_new,
          text: 'اتصل عشان تبدأ تستلم الطلبات',
        ),
      DriverState.online => const _Message(
          icon: Icons.radar,
          text: 'في انتظار طلب قريب منك...',
          loading: true,
        ),
      DriverState.offered => _OfferCard(d: d),
      DriverState.toPickup => _StepCard(
          title: 'توجّه لنقطة الركوب',
          detail: d.offer?.pickup.name ?? '',
          rider: d.offer?.riderName ?? '',
          buttonLabel: 'وصلت للراكب',
          onPressed: d.arrivedAtPickup,
        ),
      DriverState.waitingRider => _StepCard(
          title: 'في انتظار الراكب',
          detail: d.offer?.pickup.name ?? '',
          rider: d.offer?.riderName ?? '',
          buttonLabel: 'ابدأ الرحلة',
          onPressed: d.startTrip,
        ),
      DriverState.inTrip => _StepCard(
          title: 'الرحلة جارية',
          detail: 'الوجهة: ${d.offer?.dropoff.name ?? ''}',
          rider: d.offer?.riderName ?? '',
          buttonLabel: 'أنهِ الرحلة',
          onPressed: d.endTrip,
        ),
      DriverState.completed => _CompletedCard(d: d),
    };
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool loading;
  const _Message({required this.icon, required this.text, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          if (loading) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final DriverProvider d;
  const _OfferCard({required this.d});

  @override
  Widget build(BuildContext context) {
    final o = d.offer;
    if (o == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoudyColors.gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'طلب رحلة جديد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _line(Icons.my_location, 'من', o.pickup.name),
          const SizedBox(height: 8),
          _line(Icons.place, 'إلى', o.dropoff.name),
          const SizedBox(height: 8),
          Text(
            '${o.riderName} • ${o.distanceKm.toStringAsFixed(1)} كم',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Text(
            'ربحك: ${formatSdg(d.offerEarning)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DoudyColors.green,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'رفض',
                  outlined: true,
                  onPressed: d.decline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(label: 'قبول', onPressed: d.accept),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: DoudyColors.green),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  final String detail;
  final String rider;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _StepCard({
    required this.title,
    required this.detail,
    required this.rider,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DoudyColors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(detail, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text('الراكب: $rider', style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 16),
          PrimaryButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final DriverProvider d;
  const _CompletedCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'خلصت الرحلة 👏',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ربحك من الرحلة: ${formatSdg(d.offerEarning)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DoudyColors.green,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'متابعة', onPressed: d.nextRide),
        ],
      ),
    );
  }
}
