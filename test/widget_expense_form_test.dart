import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inovola_techincal_task/presentation/screens/add_expense_screen.dart';

void main() {
  testWidgets('AddExpenseScreen form validation and Save button state', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: AddExpenseScreen())));

    // Find the Save button
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);

    // Ensure the Save button is visible before tapping
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();

    // Initially, the Save button should be enabled (since _isLoading is false)
    expect(tester.widget<ElevatedButton>(saveButton).onPressed != null, true);

    // Try to tap Save without entering an amount
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Should show validation error for amount
    expect(find.text('Please enter an amount'), findsOneWidget);

    // Enter invalid amount
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, 'abc');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid number'), findsOneWidget);

    // Enter valid amount
    await tester.enterText(amountField, '123.45');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    // No validation error should be shown
    expect(find.text('Please enter a valid number'), findsNothing);
    expect(find.text('Please enter an amount'), findsNothing);
  });
} 