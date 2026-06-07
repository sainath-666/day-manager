/// Monthly expense total for analytics charts.
class MonthlyTotal {
  const MonthlyTotal({
    required this.year,
    required this.month,
    required this.total,
  });

  final int year;
  final int month;
  final double total;
}
