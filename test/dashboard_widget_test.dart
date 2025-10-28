import 'package:finance_expense_app/ui/screens/dashboard_screen.dart' show DashboardScreen;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Dashboard renders balance text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));
    expect(find.textContaining('₹'), findsOneWidget);
  });
}