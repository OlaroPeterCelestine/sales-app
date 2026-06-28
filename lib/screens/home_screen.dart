import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';

/// Dashboard summarising the day's sales activity.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = SampleData.orders;
    final route = SampleData.route;

    final totalSales = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.total);
    final ordersToday = orders.where((o) => _isToday(o.date)).length;
    final visited =
        route.where((s) => s.status == StopStatus.visited).length;
    final pendingStops =
        route.where((s) => s.status == StopStatus.pending).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Good day, Peter 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's your sales summary for today.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),
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
                value: '\$${totalSales.toStringAsFixed(2)}',
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
          const SizedBox(height: 24),
          Text(
            'Recent Orders',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
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
                      '\$${o.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  static bool _isToday(DateTime date) {
    // App's "today" is the seeded demo date.
    final now = DateTime(2026, 6, 28);
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
