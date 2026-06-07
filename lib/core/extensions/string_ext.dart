/// String utility extensions.
extension StringExt on String {
  bool get isBlank => trim().isEmpty;

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
