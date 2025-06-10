import 'package:dio/dio.dart';
import '../../core/dio_client.dart';

class CurrencyApiDataSource {
  final Dio _dio = DioClient().dio;

  Future<double> getConversionRateToUSD(String fromCurrency) async {
    if (fromCurrency == 'USD') return 1.0;
    final response = await _dio.get('https://open.er-api.com/v6/latest/$fromCurrency');
    if (response.statusCode == 200 && response.data['result'] == 'success') {
      final rates = response.data['rates'];
      if (rates != null && rates['USD'] != null) {
        return (rates['USD'] as num).toDouble();
      }
    }
    throw Exception('Failed to fetch conversion rate');
  }
} 