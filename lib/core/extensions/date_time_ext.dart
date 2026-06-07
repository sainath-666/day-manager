import 'package:intl/intl.dart';

/// DateTime formatting and comparison helpers.
extension DateTimeExt on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String get weekdayName => DateFormat('EEE').format(this);

  String formatDisplay() => DateFormat('dd MMM yyyy').format(this);

  String formatRelative() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return formatDisplay();
  }

  DateTime copyWithTime(int hour, int minute) =>
      DateTime(year, month, day, hour, minute);
}
