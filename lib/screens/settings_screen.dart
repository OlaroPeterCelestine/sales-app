import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// App settings and profile. Toggles are local UI state for the demo.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _offlineSync = false;
  bool _darkMode = true;

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
          SwitchListTile(
            secondary: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh),
            title: const Text('Offline Sync'),
            subtitle: const Text('Cache data for areas with poor signal'),
            value: _offlineSync,
            onChanged: (v) => setState(() => _offlineSync = v),
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
            onTap: () {},
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedDollarCircle),
            title: const Text('Currency'),
            subtitle: const Text('USD (\$)'),
            trailing:
                const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: () {},
          ),
          ListTile(
            leading: const HugeIcon(icon: HugeIcons.strokeRoundedHelpCircle),
            title: const Text('Help & Support'),
            trailing:
                const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
            onTap: () {},
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out (demo)')),
              );
            },
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
