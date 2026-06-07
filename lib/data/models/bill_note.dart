import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'bill_note.g.dart';

/// OCR or manual bill note, optionally linked to an expense.
@HiveType(typeId: 3)
class BillNote extends HiveObject {
  BillNote();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String rawText;

  @HiveField(2)
  double? parsedAmount;

  @HiveField(3)
  int? parsedCategory;

  @HiveField(4)
  late DateTime capturedAt;

  @HiveField(5)
  String? imagePath;

  @HiveField(6, defaultValue: false)
  bool linkedToExpense = false;

  @HiveField(7)
  String? linkedExpenseId;

  /// Creates a new bill note.
  factory BillNote.create({
    required String rawText,
    double? parsedAmount,
    int? parsedCategory,
    String? imagePath,
  }) {
    return BillNote()
      ..id = const Uuid().v4()
      ..rawText = rawText
      ..parsedAmount = parsedAmount
      ..parsedCategory = parsedCategory
      ..capturedAt = DateTime.now()
      ..imagePath = imagePath
      ..linkedToExpense = false;
  }
}
