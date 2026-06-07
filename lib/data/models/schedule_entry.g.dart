// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleEntryAdapter extends TypeAdapter<ScheduleEntry> {
  @override
  final int typeId = 1;

  @override
  ScheduleEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleEntry()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..notes = fields[2] as String?
      ..date = fields[3] as DateTime
      ..startTime = fields[4] as String
      ..endTime = fields[5] as String
      ..repeatMode = fields[6] as int
      ..colorValue = fields[7] as int
      ..notifyEnabled = fields[8] as bool
      ..notifyMinutesBefore = fields[9] as int;
  }

  @override
  void write(BinaryWriter writer, ScheduleEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.repeatMode)
      ..writeByte(7)
      ..write(obj.colorValue)
      ..writeByte(8)
      ..write(obj.notifyEnabled)
      ..writeByte(9)
      ..write(obj.notifyMinutesBefore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
