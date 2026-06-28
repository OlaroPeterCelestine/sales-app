import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';
import '../widgets/sync_status_button.dart';

/// Dashboard launchpad — KPIs, sales breakdown, weekly trend and quick actions
/// that flow into the rest of the sales workflow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSelectTab});

  /// Switches the root navigation to the given tab index.
  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final orders = SampleData.orders;
    final route = SampleData.route;

    final active = orders.where((o) => o.status != OrderStatus.cancelled);
    final totalSales = active.fold<double>(0, (sum, o) => sum + o.total);
    final ordersToday = orders.where((o) => _isToday(o.date)).length;
    final visited = route.where((s) => s.status == StopStatus.visited).length;
    final pendingStops =
        route.where((s) => s.status == StopStatus.pending).length;

    final delivered = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold<double>(0, (s, o) => s + o.total);
    final confirmed = orders
        .where((o) => o.status == OrderStatus.confirmed)
        .fold<double>(0, (s, o) => s + o.total);
    final pending = orders
        .where((o) => o.status == OrderStatus.pending)
        .fold<double>(0, (s, o) => s + o.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAFARI Field'),
        actions: const [SyncStatusButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Good day, Peter 👋',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Region North · Kampala · Sat 28 Jun',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          _quickActions(context),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                label: 'Total Sales',
                value: fmtUgx(totalSales),
                icon: HugeIcons.strokeRoundedDollarCircle,
                color: Colors.green,
              ),
              _StatCard(
                label: 'Orders Today',
                value: '$ordersToday',
                icon: HugeIcons.strokeRoundedInvoice01,
                color: Colors.blue,
              ),
              _StatCard(
                label: 'Stops Visited',
                value: '$visited / ${route.length}',
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: Colors.teal,
              ),
              _StatCard(
                label: 'Pending Stops',
                value: '$pendingStops',
                icon: HugeIcons.strokeRoundedClock01,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            title: 'Sales by Status',
            child: DonutChart(
              centerValue: _compactUgx(totalSales),
              centerLabel: 'booked',
              segments: [
                ChartSegment('Delivered', delivered, Colors.green),
                ChartSegment('Confirmed', confirmed, Colors.blue),
                ChartSegment('Pending', pending, Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            title: 'Booked Value — Last 7 Days',
            child: MiniBarChart(
              values: SampleData.weeklyBooked,
              labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => onSelectTab?.call(2),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...orders.take(3).map(
                (o) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: o.status.color.withValues(alpha: 0.15),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedInvoice01,
                        color: o.status.color,
                      ),
                    ),
                    title: Text(o.customerName),
                    subtitle: Text('${o.id} · ${o.itemCount} items'),
                    trailing: Text(
                      fmtUgx(o.total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          label: 'Start Route',
          icon: HugeIcons.strokeRoundedRoute01,
          onTap: () => onSelectTab?.call(1),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          label: 'New Order',
          icon: HugeIcons.strokeRoundedAddCircle,
          onTap: () => onSelectTab?.call(2),
        ),
        const SizedBox(width: 12),
        _QuickAction(
          label: 'Day Report',
          icon: HugeIcons.strokeRoundedAnalytics01,
          onTap: () => onSelectTab?.call(3),
        ),
      ],
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  static String _compactUgx(double v) {
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  static bool _isToday(DateTime date) {
    // App's "today" is the seeded demo date.
    final now = DateTime(2026, 6, 28);
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final HugeIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                HugeIcon(icon: icon, color: Colors.orange, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final HugeIconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HugeIcon(icon: icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
