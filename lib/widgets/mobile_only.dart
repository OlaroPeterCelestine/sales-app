import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Gates the app so it only runs on mobile devices.
///
/// On Flutter web, [defaultTargetPlatform] reflects the visitor's OS, so a
/// desktop browser resolves to macOS/Windows/Linux and is shown a notice
/// instead of the app. Native iOS/Android builds always pass through.
class MobileOnly extends StatelessWidget {
  const MobileOnly({super.key, required this.child});

  final Widget child;

  bool get _isMobile {
    // Native mobile builds are always allowed.
    if (!kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android;
    }
    // On the web, only mobile browsers (iOS/Android) are allowed.
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    if (_isMobile) return child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSmartPhone01,
                color: Colors.orange,
                size: 72,
              ),
              SizedBox(height: 24),
              Text(
                'Mobile only',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'The Sales App is designed for phones.\n'
                'Please open this link on your mobile device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
