import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// Face-Match clock-in gate. Verifies the agent's identity (simulated camera +
/// AI face match) before the daily route unlocks.
///
/// NOTE: Real biometric capture needs the device camera and an on-device face
/// recognition model — here the scan is simulated end-to-end.
class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key, required this.onClockedIn});

  final VoidCallback onClockedIn;

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

enum _Phase { idle, scanning, matched }

class _ClockInScreenState extends State<ClockInScreen> {
  _Phase _phase = _Phase.idle;

  Future<void> _startScan() async {
    setState(() => _phase = _Phase.scanning);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    setState(() => _phase = _Phase.matched);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    widget.onClockedIn();
  }

  @override
  Widget build(BuildContext context) {
    final scanning = _phase == _Phase.scanning;
    final matched = _phase == _Phase.matched;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                matched ? 'Identity verified' : 'Face-Match Clock-in',
                style: TextStyle(
                  color: matched ? Colors.green : Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                matched
                    ? 'Welcome back, Peter. Starting your route…'
                    : 'Verify your identity to start today’s route.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: matched
                        ? Colors.green
                        : (scanning ? Colors.orange : Colors.white24),
                    width: 3,
                  ),
                  color: Colors.white10,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    HugeIcon(
                      icon: matched
                          ? HugeIcons.strokeRoundedCheckmarkCircle01
                          : HugeIcons.strokeRoundedUserCircle,
                      color: matched ? Colors.green : Colors.white54,
                      size: 96,
                    ),
                    if (scanning)
                      const SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (scanning)
                const Text(
                  'Scanning facial geometry…',
                  style: TextStyle(color: Colors.orange),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _phase == _Phase.idle ? _startScan : null,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedFaceId),
                  label: Text(scanning ? 'Verifying…' : 'Clock in'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Geo-stamped • Kampala, Uganda',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
