import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// The emergency "Action Button". A triple-tap within a short window sends a
/// distress alert (GPS + last-captured data) to dispatch.
///
/// NOTE: actual dispatch needs a backend channel and live GPS — here the
/// trigger and payload are simulated.
class DistressButton extends StatefulWidget {
  const DistressButton({super.key});

  @override
  State<DistressButton> createState() => _DistressButtonState();
}

class _DistressButtonState extends State<DistressButton> {
  int _taps = 0;
  DateTime? _firstTap;

  void _onTap() {
    HapticFeedback.selectionClick();
    final now = DateTime.now();
    if (_firstTap == null ||
        now.difference(_firstTap!) > const Duration(milliseconds: 1200)) {
      _firstTap = now;
      _taps = 1;
    } else {
      _taps++;
    }

    final remaining = 3 - _taps;
    if (_taps >= 3) {
      _taps = 0;
      _firstTap = null;
      _fireDistress();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 900),
          content: Text('Tap ${remaining}x more to send distress alert'),
        ),
      );
    }
  }

  void _fireDistress() {
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedAlert02,
          color: Colors.red,
          size: 40,
        ),
        title: const Text('Distress alert sent'),
        content: const Text(
          'Dispatch has been notified with your live GPS '
          '(0.3163° N, 32.5822° E) and last-captured visit data.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Acknowledged'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'distress',
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      onPressed: _onTap,
      tooltip: 'Emergency — triple-tap',
      child: const HugeIcon(
        icon: HugeIcons.strokeRoundedAlertCircle,
        color: Colors.white,
      ),
    );
  }
}
