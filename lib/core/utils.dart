import 'package:intl/intl.dart';

class Utils {
  static String formatCurrency(num amount, {String symbol = ' 24'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }
} 