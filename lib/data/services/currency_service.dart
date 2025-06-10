import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  static Future<double?> convertToUSD(double amount, String fromCurrency) async {
    try {
      final url = '$_baseUrl/$fromCurrency';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];
        final rate = rates['USD'];
        if (rate != null) {
          return amount * (rate as num);
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
} 