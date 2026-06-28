import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../services/store.dart';

/// App settings and profile. Toggles are local UI state for the demo.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = true;
  String _currency = 'UGX (USh)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          const ListTile(
            leading: CircleAvatar(
              radius: 28,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUserCircle,
                size: 30,
              ),
            ),
            title: Text(
              'Peter Olaro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text('Sales Representative · Region North'),
          ),
          const Divider(),
          _sectionHeader(context, 'Preferences'),
          SwitchListTile(
            secondary:
                const HugeIcon(icon: HugeIcons.strokeRoundedNotification01),
            title: const Text('Push Notifications'),
            subtitle: const Text('Order updates and route reminders'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          ListenableBuilder(
            listenable: Store.instance,
            builder: (context, _) => SwitchListTile(
              secondary: HugeIcon(
                icon: Store.instance.online
                    ? HugeIcons.strokeRoundedCloudUpload
                    : HugeIcons.strokeRoundedCloudOff,
              ),
              title: const Text('Work Offline'),
              subtitle: Text(
                Store.instance.online
                    ? 'Online · ${Store.instance.pendingCount} queued for DMS'
                    : 'Offline · holding ${Store.instance.pendingCount} events to replay',
              ),
              value: !Store.instance.online,
              onChanged: (v) => Store.instance.setOnline(!v),
            ),
          ),
          SwitchListTile(
            secondary: const HugeIcon(icon: HugeIcons.strokeRoundedMoon02),
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
          ),
          const Divider(),
          _sectionHeader(context, 'Account'),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedStore01),
            title: const Text('Territory'),
            subtitle: const Text('Region North · 24 customers'),
            trailing:
                const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: _showTerritoryDialog,
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedDollarCircle),
            title: const Text('Currency'),
            subtitle: Text(_currency),
            trailing:
                const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: _showCurrencyDialog,
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedHelpCircle),
            title: const Text('Help & Support'),
            trailing:
                const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: _showHelpDialog,
          ),
          const Divider(),
          ListTile(
            leading: const HugeIcon(
              icon: HugeIcons.strokeRoundedLogout01,
              color: Colors.red,
            ),
            title: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _showSignOutDialog,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Sales App v1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showTerritoryDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedStore01,
          color: Colors.orange,
          size: 40,
        ),
        title: const Text('Region North'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned territory for your sales route.'),
            SizedBox(height: 12),
            _InfoRow(label: 'Customers', value: '24'),
            _InfoRow(label: 'Active routes', value: '3'),
            _InfoRow(label: 'Coverage', value: 'Downtown, Westside, Uptown'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    const options = ['USD (\$)', 'EUR (€)', 'GBP (£)', 'UGX (USh)'];
    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Currency'),
          content: RadioGroup<String>(
            groupValue: _currency,
            onChanged: (value) {
              if (value == null) return;
              setState(() => _currency = value);
              setDialogState(() {});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in options)
                  RadioListTile<String>(
                    value: option,
                    title: Text(option),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedHelpCircle,
          color: Colors.orange,
          size: 40,
        ),
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need a hand? Reach our support team.'),
            SizedBox(height: 12),
            _InfoRow(label: 'Email', value: 'support@salesapp.io'),
            _InfoRow(label: 'Phone', value: '+1 800 555 0199'),
            _InfoRow(label: 'Hours', value: 'Mon–Fri, 9am–6pm'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedLogout01,
          color: Colors.red,
          size: 40,
        ),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out (demo)')),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A label/value pair used inside the settings info dialogs.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
