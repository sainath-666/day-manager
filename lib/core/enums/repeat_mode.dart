/// Schedule repeat modes.
enum RepeatMode {
  none(0, 'None'),
  daily(1, 'Daily'),
  weekdays(2, 'Weekdays'),
  weekly(3, 'Weekly');

  const RepeatMode(this.value, this.label);

  final int value;
  final String label;

  static RepeatMode fromInt(int value) =>
      RepeatMode.values.firstWhere((m) => m.value == value, orElse: () => RepeatMode.none);
}
