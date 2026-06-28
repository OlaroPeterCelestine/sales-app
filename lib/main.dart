import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'screens/clock_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/route_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/distress_button.dart';
import 'widgets/mobile_only.dart';

void main() {
  runApp(const SalesApp());
}

class SalesApp extends StatelessWidget {
  const SalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Colors.orange,
      onPrimary: Colors.black,
      secondary: Colors.orangeAccent,
      surface: Colors.black,
    );

    return MaterialApp(
      title: 'Sales App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: colorScheme,
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.orange,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.black,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.withValues(alpha: 0.35)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.black,
          indicatorColor: Colors.orange.withValues(alpha: 0.25),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? Colors.orange
                  : Colors.grey[500],
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? Colors.orange
                  : Colors.grey[500],
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MobileOnly(child: AppGate()),
    );
  }
}

/// Gates the app behind the Face-Match clock-in until the agent is verified.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _clockedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_clockedIn) {
      return ClockInScreen(
        onClockedIn: () => setState(() => _clockedIn = true),
      );
    }
    return const RootNavigation();
  }
}

/// Shell that hosts the main sections behind a bottom navigation bar.
class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    RouteScreen(),
    OrdersScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: const DistressButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01),
            label: 'Home',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedRoute01),
            label: 'Route',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedInvoice01),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics01),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
