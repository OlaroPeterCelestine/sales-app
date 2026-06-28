import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// One slice of a [DonutChart] / row of a legend.
class ChartSegment {
  const ChartSegment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

/// A donut (ring) chart with a centered caption and a side legend.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
  });

  final List<ChartSegment> segments;
  final String centerValue;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                  sections: [
                    for (final seg in segments)
                      PieChartSectionData(
                        value: seg.value <= 0 ? 0.0001 : seg.value,
                        color: seg.color,
                        radius: 22,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    centerLabel,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final seg in segments)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: seg.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          seg.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        total == 0
                            ? '0%'
                            : '${(seg.value / total * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A compact vertical bar chart for a short series (e.g. weekly trend).
class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = Colors.orange,
  });

  final List<double> values;
  final List<String> labels;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b) * 1.2;
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxV,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 16,
                    color: i == values.length - 1
                        ? barColor
                        : barColor.withValues(alpha: 0.45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
