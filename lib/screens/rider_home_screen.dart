import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/ride.dart';
import '../providers/ride_provider.dart';
import '../widgets/doudy_logo.dart';
import '../widgets/map_placeholder.dart';
import '../widgets/primary_button.dart';

class RiderHomeScreen extends StatelessWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapPlaceholder()),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  DoudyLogo(size: 44),
                  SizedBox(width: 8),
                  Text(
                    'دودي',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: DoudyColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _RidePanel(),
          ),
        ],
      ),
    );
  }
}

class _RidePanel extends StatelessWidget {
  const _RidePanel();

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(blurRadius: 16, color: Color(0x22000000))],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: switch (ride.status) {
            RideStatus.idle => _IdlePanel(ride: ride),
            RideStatus.searching => _SearchingPanel(ride: ride),
            RideStatus.accepted ||
            RideStatus.arriving ||
            RideStatus.inTrip =>
              _ActivePanel(ride: ride),
            RideStatus.completed => _CompletedPanel(ride: ride),
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- idle

class _IdlePanel extends StatelessWidget {
  final RideProvider ride;
  const _IdlePanel({required this.ride});

  Future<void> _pickDestination(BuildContext context) async {
    final picked = await showModalBottomSheet<Place>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'وين رايح؟',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (final p in Places.destinations)
              ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(p.name),
                onTap: () => Navigator.pop(sheetContext, p),
              ),
          ],
        ),
      ),
    );
    if (picked != null) ride.setDropoff(picked);
  }

  @override
  Widget build(BuildContext context) {
    final fare = ride.fare;
    final km = ride.distanceKm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LocationRow(
          icon: Icons.my_location,
          label: 'من',
          value: ride.pickup.name,
        ),
        const SizedBox(height: 10),
        _LocationRow(
          icon: Icons.place,
          label: 'إلى',
          value: ride.dropoff?.name ?? 'اختار وجهتك',
          muted: ride.dropoff == null,
          onTap: () => _pickDestination(context),
        ),
        if (fare != null && km != null) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المسافة التقريبية: ${km.toStringAsFixed(1)} كم',
                style: const TextStyle(color: Colors.black54),
              ),
              Text(
                formatSdg(fare),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DoudyColors.green,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        SegmentedButton<PaymentMethod>(
          segments: const [
            ButtonSegment(
              value: PaymentMethod.cash,
              label: Text('كاش'),
              icon: Icon(Icons.payments_outlined),
            ),
            ButtonSegment(
              value: PaymentMethod.bankak,
              label: Text('بنكك'),
              icon: Icon(Icons.account_balance_outlined),
            ),
          ],
          selected: {ride.payment},
          onSelectionChanged: (s) => ride.setPayment(s.first),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'اطلب دودي',
          onPressed: ride.dropoff == null ? null : ride.requestRide,
        ),
      ],
    );
  }
}

// ----------------------------------------------------------- searching

class _SearchingPanel extends StatelessWidget {
  final RideProvider ride;
  const _SearchingPanel({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 16),
        const Text(
          'جاري البحث عن سائق قريب منك...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'إلغاء الطلب', outlined: true, onPressed: ride.cancel),
      ],
    );
  }
}

// -------------------------------------------------------------- active

class _ActivePanel extends StatelessWidget {
  final RideProvider ride;
  const _ActivePanel({required this.ride});

  String get _statusText => switch (ride.status) {
        RideStatus.accepted => 'السائق قبل طلبك',
        RideStatus.arriving => 'السائق في الطريق إليك',
        RideStatus.inTrip => 'أنت الآن في الرحلة',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final driver = ride.driver;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _statusText,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DoudyColors.green,
          ),
        ),
        const SizedBox(height: 12),
        if (driver != null) _DriverCard(driver: driver),
        const SizedBox(height: 12),
        _LocationRow(
          icon: Icons.place,
          label: 'الوجهة',
          value: ride.dropoff?.name ?? '',
        ),
        if (ride.fare != null) ...[
          const SizedBox(height: 10),
          Text(
            'الأجرة: ${formatSdg(ride.fare!)} (${ride.payment.label})',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
        if (ride.canCancel) ...[
          const SizedBox(height: 14),
          PrimaryButton(label: 'إلغاء الرحلة', outlined: true, onPressed: ride.cancel),
        ],
      ],
    );
  }
}

// ----------------------------------------------------------- completed

class _CompletedPanel extends StatelessWidget {
  final RideProvider ride;
  const _CompletedPanel({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'وصلت بالسلامة 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (ride.fare != null)
          Text(
            formatSdg(ride.fare!),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: DoudyColors.green,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'الدفع: ${ride.payment.label}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        const Text('قيّم السائق', textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                onPressed: () => ride.setRating(i),
                icon: Icon(
                  i <= ride.rating ? Icons.star : Icons.star_border,
                  color: DoudyColors.gold,
                  size: 34,
                ),
              ),
          ],
        ),
        PrimaryButton(label: 'تمام', onPressed: ride.finish),
      ],
    );
  }
}

// -------------------------------------------------------------- shared

class _DriverCard extends StatelessWidget {
  final Driver driver;
  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DoudyColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: DoudyColors.green,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${driver.car} • ${driver.plate}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: DoudyColors.gold, size: 18),
              const SizedBox(width: 2),
              Text(driver.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool muted;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: DoudyColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: DoudyColors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: muted ? Colors.black38 : DoudyColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
}
