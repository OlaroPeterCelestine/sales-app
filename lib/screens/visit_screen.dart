import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/models.dart';

/// In-outlet visit + retail execution audit.
///
/// Hosts the visit timer (time-on-site vs tier budget), the SAFARI Coach tip,
/// the AI planogram audit, stock-on-hand capture, and competitor intel.
///
/// NOTE: planogram recognition and competitor OCR are simulated — production
/// needs an on-device vision model and a camera capture pipeline.
class VisitScreen extends StatefulWidget {
  const VisitScreen({super.key, required this.stop});

  final RouteStop stop;

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  late final Timer _timer;
  Duration _elapsed = Duration.zero;
  bool _scanning = false;
  bool _auditDone = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _runPlanogramScan() async {
    setState(() => _scanning = true);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _auditDone = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _completeVisit() {
    HapticFeedback.heavyImpact();
    setState(() => widget.stop.status = StopStatus.visited);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final budget = Duration(minutes: widget.stop.budgetMinutes);
    final overBudget = _elapsed > budget;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stop.customerName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.stop.tier.code} · geo-verified check-in',
              style: TextStyle(color: widget.stop.tier.color, fontSize: 13),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _visitTimer(budget, overBudget),
          const SizedBox(height: 16),
          _coachTip(),
          const SizedBox(height: 16),
          _planogramCard(),
          const SizedBox(height: 16),
          _stockCard(),
          const SizedBox(height: 16),
          _competitorCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _completeVisit,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01),
            label: const Text('Complete visit'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _visitTimer(Duration budget, bool overBudget) {
    String two(int n) => n.toString().padLeft(2, '0');
    final mins = two(_elapsed.inMinutes);
    final secs = two(_elapsed.inSeconds % 60);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              color: overBudget ? Colors.red : Colors.orange,
              size: 34,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$mins:$secs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: overBudget ? Colors.red : Colors.white,
                  ),
                ),
                Text(
                  overBudget
                      ? 'Over the ${budget.inMinutes} min budget'
                      : 'Budget: ${budget.inMinutes} min on-site',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coachTip() {
    final tip = SampleData.coachTips[widget.stop.customerName] ??
        'Confirm cold-shelf facings and offer the running BOGO promo.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAiBrain01,
              color: Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SAFARI Coach',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tip, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planogramCard() {
    const audit = SampleData.planogram;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
              HugeIcons.strokeRoundedGridView,
              'AI Planogram Audit',
            ),
            const SizedBox(height: 12),
            if (!_auditDone)
              Center(
                child: OutlinedButton.icon(
                  onPressed: _scanning ? null : _runPlanogramScan,
                  icon: _scanning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const HugeIcon(icon: HugeIcons.strokeRoundedCamera01),
                  label: Text(_scanning ? 'Scanning shelf…' : 'Scan shelf'),
                ),
              )
            else ...[
              _metricRow(
                'Facings detected',
                '${audit.detectedFacings} / ${audit.targetFacings}',
              ),
              _metricRow(
                'Compliance',
                '${(audit.compliance * 100).round()}%',
                valueColor:
                    audit.compliance >= 0.8 ? Colors.green : Colors.orange,
              ),
              _metricRow(
                'Competitor shelf share',
                '${(audit.competitorShare * 100).round()}%',
                valueColor: Colors.redAccent,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gap analysis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...audit.gaps.map(
                (g) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedAlert01,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(g)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stockCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
              HugeIcons.strokeRoundedPackage,
              'Stock on Hand (SOH)',
            ),
            const SizedBox(height: 8),
            ...SampleData.stockOnHand.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (line.isCritical)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedAlertCircle,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          Flexible(child: Text(line.sku)),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() {
                        if (line.onHand > 0) line.onHand--;
                      }),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedRemoveCircle,
                        size: 20,
                      ),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${line.onHand}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: line.isCritical ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => setState(() => line.onHand++),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedAddCircle,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _competitorCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
              HugeIcons.strokeRoundedSearchVisual,
              'Competitor Intel (OCR)',
            ),
            const SizedBox(height: 8),
            ...SampleData.competitorIntel.map(
              (intel) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${intel.brand} · ${intel.product}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          intel.price,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                    Text(
                      intel.note,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardHeader(List<List<dynamic>> icon, String title) {
    return Row(
      children: [
        HugeIcon(icon: icon, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _metricRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
