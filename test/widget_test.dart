// Basic smoke test for the SAFARI Field app shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sales_app/main.dart';

void main() {
  testWidgets('Clock-in gate unlocks the navigation shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SalesApp());

    // App opens on the Face-Match clock-in gate.
    expect(find.text('Face-Match Clock-in'), findsOneWidget);

    // Run the simulated face scan to clock in.
    await tester.tap(find.text('Clock in'));
    await tester.pump(); // start scanning
    await tester.pump(const Duration(milliseconds: 2300)); // matched
    await tester.pump(const Duration(milliseconds: 1000)); // onClockedIn
    await tester.pumpAndSettle();

    // The bottom navigation bar with all destinations is present.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Route'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Home dashboard renders its summary cards.
    expect(find.text('Total Sales'), findsOneWidget);

    // Tapping the Orders tab navigates to the orders list.
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('New Order'), findsOneWidget);
  });
}
