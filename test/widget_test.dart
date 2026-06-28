// Basic smoke test for the Sales App shell.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sales_app/main.dart';

void main() {
  testWidgets('App boots and shows the four navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SalesApp());

    // The bottom navigation bar with all four destinations is present.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Route'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Home dashboard renders its summary cards.
    expect(find.text('Total Sales'), findsOneWidget);

    // Tapping the Orders tab navigates to the orders list.
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('New Order'), findsOneWidget);
  });
}
