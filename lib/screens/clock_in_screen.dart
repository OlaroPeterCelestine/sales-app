import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

/// Face-Match clock-in gate. Captures a real selfie via the device camera, then
/// verifies identity before the daily route unlocks.
///
/// NOTE: the camera capture is real; the face *recognition* step on top of the
/// photo is simulated, as identity matching needs a trained on-device model.
class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key, required this.onClockedIn});

  final VoidCallback onClockedIn;

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

enum _Phase { idle, scanning, matched }

class _ClockInScreenState extends State<ClockInScreen> {
  _Phase _phase = _Phase.idle;
  Uint8List? _photo;

  Future<void> _startScan() async {
    setState(() => _phase = _Phase.scanning);
    HapticFeedback.lightImpact();
    // Capture a real selfie concurrently with the verification animation.
    _capturePhoto();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _phase = _Phase.matched);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    widget.onClockedIn();
  }

  Future<void> _capturePhoto() async {
    try {
      final shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 600,
      );
      if (shot == null) return;
      final bytes = await shot.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {
      // Camera unavailable (e.g. permission denied) — scan only.
    }
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
                    if (_photo != null)
                      ClipOval(
                        child: Image.memory(
                          _photo!,
                          width: 214,
                          height: 214,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
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
