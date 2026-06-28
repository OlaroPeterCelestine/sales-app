import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../services/store.dart';

/// App-bar action showing the offline sync-queue state. Tap to replay the
/// queue to the DMS (or hold it if currently offline).
class SyncStatusButton extends StatelessWidget {
  const SyncStatusButton({super.key});

  Future<void> _sync(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final synced = await Store.instance.sync();
    if (synced == -1) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Offline — queued events will retry when back online'),
      ));
    } else if (synced == 0) {
      messenger.showSnackBar(
          const SnackBar(content: Text('All caught up — nothing to sync')));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text('Synced $synced event${synced == 1 ? '' : 's'} to DMS'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Store.instance,
      builder: (context, _) {
        final pending = Store.instance.pendingCount;
        final online = Store.instance.online;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                tooltip: online ? 'Sync to DMS' : 'Offline — queue held',
                onPressed: () => _sync(context),
                icon: HugeIcon(
                  icon: online
                      ? HugeIcons.strokeRoundedCloudUpload
                      : HugeIcons.strokeRoundedCloudOff,
                  color: online ? Colors.orange : Colors.grey,
                ),
              ),
              if (pending > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$pending',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
