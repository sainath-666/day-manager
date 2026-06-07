import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

/// An expense record with category and optional receipt image.
@HiveType(typeId: 2)
class Expense extends HiveObject {
  Expense();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late int category;

  @HiveField(3)
  late String description;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late int paymentMethod;

  @HiveField(6)
  String? receiptNote;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  late DateTime createdAt;

  /// Creates a new expense with auto-generated id.
  factory Expense.create({
    required double amount,
    required int category,
    required String description,
    required DateTime date,
    int paymentMethod = 0,
    String? receiptNote,
    String? imagePath,
  }) {
    return Expense()
      ..id = const Uuid().v4()
      ..amount = amount
      ..category = category
      ..description = description
      ..date = date
      ..paymentMethod = paymentMethod
      ..receiptNote = receiptNote
      ..imagePath = imagePath
      ..createdAt = DateTime.now();
  }
}
