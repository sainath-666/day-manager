// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillNoteAdapter extends TypeAdapter<BillNote> {
  @override
  final int typeId = 3;

  @override
  BillNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillNote()
      ..id = fields[0] as String
      ..rawText = fields[1] as String
      ..parsedAmount = fields[2] as double?
      ..parsedCategory = fields[3] as int?
      ..capturedAt = fields[4] as DateTime
      ..imagePath = fields[5] as String?
      ..linkedToExpense = fields[6] == null ? false : fields[6] as bool
      ..linkedExpenseId = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, BillNote obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rawText)
      ..writeByte(2)
      ..write(obj.parsedAmount)
      ..writeByte(3)
      ..write(obj.parsedCategory)
      ..writeByte(4)
      ..write(obj.capturedAt)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.linkedToExpense)
      ..writeByte(7)
      ..write(obj.linkedExpenseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
