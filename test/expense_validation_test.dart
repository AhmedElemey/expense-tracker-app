import 'package:flutter_test/flutter_test.dart';

// Simple validation function for amount (as in AddExpenseScreen)
String? validateAmount(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an amount';
  }
  if (double.tryParse(value) == null) {
    return 'Please enter a valid number';
  }
  return null;
}

void main() {
  group('Expense Validation', () {
    test('Empty amount returns error', () {
      expect(validateAmount(''), 'Please enter an amount');
    });
    test('Non-numeric amount returns error', () {
      expect(validateAmount('abc'), 'Please enter a valid number');
    });
    test('Valid amount returns null', () {
      expect(validateAmount('123.45'), null);
    });
  });

  group('Currency Calculation', () {
    test('Converts amount to USD using mock rate', () async {
      // Instead of real API, we mock the conversion logic
      double mockConvertToUSD(double amount, double rate) => amount * rate;
      expect(mockConvertToUSD(100, 0.5), 50.0);
      expect(mockConvertToUSD(200, 1.5), 300.0);
    });
  });
} 