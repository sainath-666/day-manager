/// Payment method options for expenses.
enum PaymentMethod {
  cash(0, 'Cash'),
  upi(1, 'UPI'),
  card(2, 'Card'),
  other(3, 'Other');

  const PaymentMethod(this.value, this.label);

  final int value;
  final String label;

  static PaymentMethod fromInt(int value) => PaymentMethod.values.firstWhere(
        (m) => m.value == value,
        orElse: () => PaymentMethod.other,
      );
}
