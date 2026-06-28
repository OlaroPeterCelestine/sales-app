import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';
import 'visit_screen.dart';

/// Smart Beat Map: sequenced stops with tiering, geofenced check-in and ETAs.
class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  List<RouteStop> get _stops => SampleData.route;

  void _setStatus(RouteStop stop, StopStatus status) {
    HapticFeedback.selectionClick();
    setState(() => stop.status = status);
  }

  /// Simulates the agent arriving on-site so the geofence (50 m) unlocks.
  void _simulateArrival(RouteStop stop) {
    HapticFeedback.lightImpact();
    setState(() => stop.distanceMeters = 12);
  }

  Future<void> _checkIn(RouteStop stop) async {
    HapticFeedback.mediumImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VisitScreen(stop: stop)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visited =
        _stops.where((s) => s.status == StopStatus.visited).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Route"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$visited of ${_stops.length} stops completed',
              style: TextStyle(color: Colors.grey[200]),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stops.length,
        separatorBuilder: (_, _) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final stop = _stops[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    stop.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _TierBadge(tier: stop.tier),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stop.address,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            stop.eta,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          _StatusChip(status: stop.status),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _geofenceRow(stop),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _geofenceRow(RouteStop stop) {
    // Completed/skipped stops just show their resolved state.
    if (stop.status != StopStatus.pending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => _checkIn(stop),
            icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedNote01, size: 18),
            label: const Text('Open visit'),
          ),
        ],
      );
    }

    final dist = stop.distanceMeters;
    final within = stop.withinGeofence;
    final distLabel =
        dist >= 1000 ? '${(dist / 1000).toStringAsFixed(1)} km' : '${dist.round()} m';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            HugeIcon(
              icon: within
                  ? HugeIcons.strokeRoundedLocationCheck01
                  : HugeIcons.strokeRoundedLocation01,
              size: 16,
              color: within ? Colors.green : Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Text(
              within
                  ? 'Inside 50 m geofence · check-in unlocked'
                  : '$distLabel away · within 50 m to check in',
              style: TextStyle(
                fontSize: 12,
                color: within ? Colors.green : Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () => _setStatus(stop, StopStatus.skipped),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedMinusSignCircle,
                size: 18,
              ),
              label: const Text('Skip'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
            ),
            const SizedBox(width: 8),
            if (within)
              FilledButton.icon(
                onPressed: () => _checkIn(stop),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocationCheck01,
                  size: 18,
                ),
                label: const Text('Check in'),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _simulateArrival(stop),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedNavigation03,
                  size: 18,
                ),
                label: const Text('Simulate arrival'),
              ),
          ],
        ),
      ],
    );
  }
}

/// Small coloured chip showing an outlet's trade tier.
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final OutletTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tier.code,
        style: TextStyle(
          color: tier.color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StopStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: status.icon, size: 14, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
