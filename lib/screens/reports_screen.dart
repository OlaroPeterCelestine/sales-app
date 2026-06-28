import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';

/// Daily Sales Report (DSR) + gamified leaderboard.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = SampleData.orders;
    final route = SampleData.route;

    final booked = orders
        .where((o) => o.status != OrderStatus.cancelled)
        .fold<double>(0, (sum, o) => sum + o.total);
    final cashCollected = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold<double>(0, (sum, o) => sum + o.total);
    final productiveCalls =
        route.where((s) => s.status == StopStatus.visited).length;
    final totalCalls = route.length;
    final strikeRate =
        totalCalls == 0 ? 0.0 : productiveCalls / totalCalls;

    final me = SampleData.leaderboard.firstWhere((e) => e.isMe,
        orElse: () => SampleData.leaderboard.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Daily Sales Report',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'End-of-day summary · 28 Jun 2026',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _metric('Booked value', '\$${booked.toStringAsFixed(0)}',
                  HugeIcons.strokeRoundedDollarCircle, Colors.green),
              _metric('Cash collected', '\$${cashCollected.toStringAsFixed(0)}',
                  HugeIcons.strokeRoundedMoneyBag02, Colors.teal),
              _metric('Strike rate', '${(strikeRate * 100).round()}%',
                  HugeIcons.strokeRoundedTarget01, Colors.orange),
              _metric('Calls', '$productiveCalls / $totalCalls',
                  HugeIcons.strokeRoundedStore01, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedChampion,
                    color: Colors.orange,
                    size: 34,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Day Score',
                            style: TextStyle(color: Colors.white70)),
                        Text(
                          '${me.dayScore}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedFire,
                            color: Colors.deepOrange,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text('${me.streakDays}-day streak',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Keep it alive for your bonus',
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ..._rankedLeaderboard(),
        ],
      ),
    );
  }

  List<Widget> _rankedLeaderboard() {
    final entries = [...SampleData.leaderboard]
      ..sort((a, b) => b.dayScore.compareTo(a.dayScore));
    return [
      for (var i = 0; i < entries.length; i++)
        _LeaderRow(rank: i + 1, entry: entries[i]),
    ];
  }

  Widget _metric(String label, String value, List<List<dynamic>> icon,
      Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HugeIcon(icon: icon, color: color, size: 26),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.rank, required this.entry});

  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final medal = switch (rank) {
      1 => Colors.amber,
      2 => Colors.grey,
      3 => Colors.brown,
      _ => Colors.transparent,
    };
    return Card(
      color: entry.isMe ? Colors.orange.withValues(alpha: 0.12) : null,
      shape: entry.isMe
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.orange),
            )
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: medal == Colors.transparent
              ? Colors.white12
              : medal.withValues(alpha: 0.25),
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: medal == Colors.transparent ? Colors.white : medal,
            ),
          ),
        ),
        title: Text(
          entry.isMe ? '${entry.name} (you)' : entry.name,
          style: TextStyle(
            fontWeight: entry.isMe ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${entry.streakDays}-day streak'),
        trailing: Text(
          '${entry.dayScore}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
