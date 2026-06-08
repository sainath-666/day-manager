// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 4;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..providerName = fields[2] as String?
      ..location = fields[3] as String?
      ..appointmentType = fields[4] as int
      ..date = fields[5] as DateTime
      ..time = fields[6] as String
      ..durationMinutes = fields[7] as int
      ..status = fields[8] as int
      ..notes = fields[9] as String?
      ..notifyEnabled = fields[10] as bool
      ..notifyMinutesBefore = fields[11] as int
      ..colorValue = fields[12] as int;
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.providerName)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.appointmentType)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.time)
      ..writeByte(7)
      ..write(obj.durationMinutes)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.notifyEnabled)
      ..writeByte(11)
      ..write(obj.notifyMinutesBefore)
      ..writeByte(12)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
