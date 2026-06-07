import 'package:intl/intl.dart';

/// Currency formatting using intl NumberFormat.
abstract final class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);
}
