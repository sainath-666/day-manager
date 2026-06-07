import '../utils/currency_formatter.dart';

/// Numeric formatting helpers.
extension DoubleExt on double {
  String toCurrency() => CurrencyFormatter.format(this);

  String toPercent() => '${(this * 100).toStringAsFixed(0)}%';
}
