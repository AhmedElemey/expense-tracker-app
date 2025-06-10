import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/currency_service.dart';
 
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService();
}); 